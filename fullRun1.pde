import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;

void setup() {
  background(255);
  fullScreen(P2D, 1);
  drawSil = false;

  // Init kinect
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  depthImg = new PImage(kinect2.depthWidth, kinect2.depthHeight, ARGB);

  meri = new Meri();
  stLines = new StaticLines(stLineCt, lineShiftMax);

  // Set up segments
  float thresMin = segThresStart;
  int tIdx = 0;
  int colIdx = 0;
  for (int i = 0; i < segCt; i++) {
    if (i >= segCols.length) {
       colIdx = 0;
    } 
    segs[i] = new Segment(segCols[colIdx], thresMin, thresMin+segThresIncr);
    segThres[tIdx] = thresMin;
    segThres[tIdx+1] = thresMin+segThresIncr;
    thresMin += segThresIncr;
    tIdx += 2;
    colIdx++;
  }
  activeSegment = 0;
  
  // Neuron/node stuff
  colorMode(HSB, 360, 100, 100);
  saturationLevel = 1.0;
  brightnessLevel = 1.0;
  speedModulator = 1.0;
  
  bgNodeColor = color(225, 0*saturationLevel, 80*brightnessLevel);
  brainBgBrightness = 0;
  
  for (int i = 0; i < topNodeCt; i++) {
     topNodes[i] = new Node("top"); 
  }
  for (int i = 0; i < midNodeCt; i++) {
     midNodes[i] = new Node("mid"); 
  }
  for (int i = 0; i < btmNodeCt; i++) {
     btmNodes[i] = new Node("btm"); 
  }

  for (int i = 0; i < clusterCt; i++) {
   clusters[i] = new Cluster(random(0, width), random(0,height), random(20,60), floor(random(5,10)));
  }
  
  for (int i = 0; i < dripCt; i++) {
    drips[i] = new DripNode();  
  }

}

void draw() {
  Segment body = segs[activeSegment];
  buttons(body);
  if (!freeze) {
    drawFrameBG();
  }
  updateDepthFrame();
 
  // STAGE 0: slow and sad
  if (!meri.firstEntrance) {
    int enter = checkEntrance1(body);
    if (enter >= 0) {
      meri.firstEntrance = true;
    } else {
      overlayAlpha = 5;
      btmAgentsAlpha = 20;
      speedModulator = 0.1;
      brainBgBrightness = 10;
      saturationLevel = 0;
      brightnessLevel = 0;
      updateAndDrawBrain();
    }
  }
  
  // STAGE 1: Brain, hopping!
  if (meri.firstEntrance && meri.curtainTriggered == false) {
    if (meri.stops >= meri.stopCtr) {
      overlayAlpha = 20;
      meri.curtainTriggered = true; 
    } else {
      meri.firstEnterFreezeCtr++;
      overlayAlpha = agentOverlayAlpha;
      btmAgentsAlpha = 20;

      PVector cent = body.getCenter();
      float velocity = body.getVelocityAvg();
      if (meri.firstEnterFreezeCtr > meri.firstEnterFreezeMin &&
        meri.firstEnterFreezeCtr <  meri.firstEnterFreezeMax) {
        freeze = true; 
      } else if ( meri.firstEnterFreezeCtr >= meri.firstEnterFreezeMax ) {
        if (velocity > 3 && !meri.doneFreeze) {
          freeze = false; 
          meri.doneFreeze = true;
        }
      }
      
      if (velocity/(cent.z/1000) < 1 && meri.firstEnterFreezeCtr > meri.firstEnterFreezeMax ) {
        meri.stops++; 
      }
      

      if (velocity == velocity && !freeze) { // prevent NaN error
        brainBgBrightness = (int)map(velocity, 0, 10, 0, 99);
        speedModulator = map(velocity, 1, 10, 0.05, 4);
        saturationLevel = map(velocity, 0, 5, 0, 1);
        brightnessLevel = map(velocity, 0, 5, 0, 1);
      } else {
        brainBgBrightness = 100;
        speedModulator = 0.5;
        saturationLevel = 1.0;
        brightnessLevel = 1.0;
      }
      updateAndDrawBrain();
    }
  }
   
   // STAGE 2: Curtain/box
   if (meri.curtainTriggered && !meri.curtainFinished) {
     if (body.curtainDone()) {
       overlayAlpha = 100;
       meri.curtainFinished = true;
     } else {
       updateAndDrawBrain();
       body.drawCurtainWithSides();  
     }
   }
   
   
   // STAGE 3: Lines
   if (meri.curtainFinished && !meri.secondExit) {
      PVector cent = body.getCenter();
      float velocity = body.getVelocityAvg();
      if (meri.waitBeforeLines < meri.waitBeforeLinesStop) {
        meri.waitBeforeLines++;
      } else {
        if (frameCount % 100 == 0 && stLines.linesToDraw < stLines.lineNum) {
          stLines.linesToDraw++; 
        }
      }
      if (velocity/(cent.z/1000) > 1) {
        stLines.shiftLines();
      } 
      stLines.drawLines();
      
      if (checkExit(body) >= 0)  {
        meri.secondExit = true;  
      }
   }
   
   // STAGE 4: Meri is over in the web
   if (meri.secondExit && !meri.secondEntrance) {
     //lines COULD keep going?
     if (frameCount % 100 == 0 && stLines.linesToDraw < stLines.lineNum) {
          stLines.linesToDraw++; 
     }
     
     stLines.drawLines();
     meri.enterBackOrFront  = checkEntrance2(body);
     if (meri.enterBackOrFront  >= 0)  {
        meri.secondEntrance = true; 
        freeze = true;
        
        if (meri.enterBackOrFront == 1) {
          stLines.invertColors();
        } else if (meri.enterBackOrFront == 0 ) {
          freeze = true; 
          for(int i = 0; i < dripCt; i++) {
            drips[i].setColorRandomGrey();
          }
        }
       
      }
   }
   
   
   // STAGE 5: Meri returns for the end
   if (meri.secondEntrance) {
      if (meri.enterBackOrFront == 0) {
        //front (have light) = 0 stays dark
        // add particle system ?? dripping?? glowing lights??
        // I'M GETTING RID OF THIS THING  
        for(int i = 0; i < dripCt; i++) {
          drips[i].update();
        }
      } else {
        // back (don't have light)  = 1
        // inverted colors, shadow selves -- DISSOCIATION
        //stLines.drawLines();
        overlayAlpha = 100;
        drawShadowSelves();
        for(int i = 0; i < dripCt; i++) {
          drips[i].update();
        }
      }
   }
   
   if (drawSil) {
    drawSilFrame();
    body.drawCenterIndicator();
  }
  
}


void updateDepthFrame() {
  //colorMode(RGB, 255, 255, 255, 1.0);
 // Update segment variables
  for (int i=0; i < segs.length; i++){
    segs[i].newFrame(); 
  }
  
  depthImg.loadPixels();
  int[] rawDepth = kinect2.getRawDepth();
    for (int x = 0; x < kinect2.depthWidth; x++) {
      for (int y = 0; y < kinect2.depthHeight; y++) {
        int index = x + y * kinect2.depthWidth;
        int p = rawDepth[index];
        
        if (x <= leftSideThres || x >= kinect2.depthWidth-rightSideThres 
        || y >= kinect2.depthHeight-btmThres || y <= topThres) {
          depthImg.pixels[index] = thresColorRGB;
        } else {
          int segIdx = 0;
          boolean setColor = false;
          for (int j = 0; j < (segCt*2); j+=2) {
            if (p >= segThres[j] && p < segThres[j+1]) {
              segs[segIdx].updateForFrame(x,y,p);
              depthImg.pixels[index] = segs[segIdx].sColor;  
              setColor = true;
            }
            segIdx++;
          }
          if (!setColor) {
            depthImg.pixels[index] = bgKinectColorRGB;  
          }
        } 
     
      }
    }
    
    for (int i=0; i < segs.length; i++){
      segs[i].updateAfterWholeFrameChecked(); 
    }
    
    depthImg.updatePixels();
    
    activeSegment = findMaxIdx(segs); 
}

void updateAndDrawBrain() {
  colorMode(HSB, 360, 100, 100, 100);
  if (!freeze) {
    noStroke();
    fill(0, 0, brainBgBrightness, agentOverlayAlpha);
    rect(0,0,width,height);
    
    for (int i = 0; i < btmNodeCt; i++) {
       btmNodes[i].update(); 
    }
    for (int i = 0; i < midNodeCt; i++) {
       midNodes[i].update(); 
    }
    for (int i = 0; i < topNodeCt; i++) {
       topNodes[i].update();   
       for (int j = 0; j < clusterCt; j++) {
          if (clusters[j].isPassing(topNodes[i].p)) {
            clusters[j].drawShapeWithGlow(); 
          }
       }
    }
  }

}

void drawShadowSelves() {
  imageMode(CORNER);
  // flip and mirror
  pushMatrix();
  scale(1.0, -1.0);

//  tint(360, 100, 100); //red
// tint(60, 100, 100); //yellow
// tint(255, 100, 100); //blue
//tint(120, 100, 100); //green
  
   tint(360, 100, 100); //red
  image(depthImg, -200, -depthImg.height-30, depthImg.width*1.25, depthImg.height*1.25);
   tint(255, 100, 100); //blue
  image(depthImg, 25, -depthImg.height-30, depthImg.width*1.25, depthImg.height*1.25);
  tint(120, 100, 100); //green
  image(depthImg, 250, -depthImg.height-30, depthImg.width*1.25, depthImg.height*1.25);
  tint(60, 100, 100); //yellow
  image(depthImg, 475, -depthImg.height-30, depthImg.width*1.25, depthImg.height*1.25);
  popMatrix();
  
  pushMatrix();
  scale(1.0, 1.0);
  //noTint();
  tint(60, 100, 100); // yellow
  image(depthImg, -200, depthImg.height-100, depthImg.width*1.25, depthImg.height*1.25);
  tint(120, 100, 100); //green
  image(depthImg, 25, depthImg.height-100, depthImg.width*1.25, depthImg.height*1.25);
  tint(255, 100, 100); //blue
  image(depthImg, 250, depthImg.height-100, depthImg.width*1.25, depthImg.height*1.25);
  tint(360, 100, 100); //red
  image(depthImg, 475, depthImg.height-100, depthImg.width*1.25, depthImg.height*1.25);
  popMatrix();
}

void drawSilFrame() {
  imageMode(CENTER);
  pushMatrix();
  if (flip && mirror) {
    scale(1.0, -1.0);
    image(depthImg, depthImg.width, -depthImg.height, depthImg.width*xScale, depthImg.height*yScale);
  }
  if (flip && !mirror) {
    scale(-1.0, -1.0);
    image(depthImg, -depthImg.width, -depthImg.height, depthImg.width*xScale, depthImg.height*yScale);
  }
  if (!flip && mirror) {
    scale(1.0, 1.0);
    image(depthImg, depthImg.width, depthImg.height, depthImg.width*xScale, depthImg.height*yScale);
  } 
  if (!flip && !mirror) {
    scale(-1.0, 1.0);
   // image(depthImg, -depthImg.width-150, depthImg.height+btmThres, depthImg.width*2.5, depthImg.height*2);
    image(depthImg, -depthImg.width, depthImg.height, depthImg.width*xScale, depthImg.height*yScale);
  }
  popMatrix(); 
}


// First entrance thresholds, can be at any depth
int checkEntrance1(Segment body) {
  float pixelDiff = body.getTotalPixelDiff();
  if (pixelDiff >= meri.firstEntranceThres && frameCount > 500) {
    return 0; 
  } 
  return -1;
}

int checkExit(Segment body) {
  PVector cent = body.getCenter();
  if (cent.x > meri.firstExitThres && body.totalPixelsInSeg > pixelCountValidThres) {
   return 1; 
  }
  return -1;
}

// Second entrance thresholds (at end)
int checkEntrance2(Segment body) {
  // if cent.z is > 2000 and cent.x 
  PVector cent = body.getCenter();
  if (cent.z < 1800 && cent.x < meri.secondEnterThres && body.totalPixelsInSeg > pixelCountValidThres) {
    return 0; // Front entrance
  } else if ( cent.z > 1800 &&  cent.x < meri.secondEnterThres && body.totalPixelsInSeg > pixelCountValidThres) {
    return 1;  // back entrance
  } 
  return -1;
}
 
int findMaxIdx(Segment[] segs) {
 float max = segs[0].getTotalPixels();
 int maxIdx = 0;
 
 for (int i=1; i < segs.length; i++){
   float num = segs[i].getTotalPixels();
   if (num > max) {
    max = num;
    maxIdx = i;
   }
 }
 return maxIdx;
}

void drawFrameBG() {
  fill(255, overlayAlpha);
  rect(0,0,width,height); 
}

void drawFrameBGFull() {
  fill(255, 100);
  rect(0,0,width,height); 
}

void buttons(Segment body) {
  if (keyPressed == true) {
    
    // Show or hide silhouette
    if (key == 's') {
      if (drawSil == true){
        drawSil = false;
      }
      else {
        drawSil = true;
      }
    }
    // Reset to very begginning 
    if (key == 'r') {
      body.resetCurtainVals();
      stLines.linesToDraw = 0;
      drawFrameBGFull();
      meri.resetMeri();
    }
    // Frozen entrance
    if (key == 'q') {
      body.resetCurtainVals();
      drawFrameBGFull();
      stLines.linesToDraw = 0;
      meri.setToAlmost1();
    }
    // Hopping around
    if (key == '1') {
      body.resetCurtainVals();
      drawFrameBGFull();
      stLines.linesToDraw = 0;
      meri.setTo1();
    }
    // Curtain
    if (key == '2') {
      //33drawFrameBGFull();
      body.resetCurtainVals();
      stLines.linesToDraw = 0;
      meri.setTo2();
    }
    // Lines
    if (key == '3') {
      stLines.resetColors();
      stLines.linesToDraw = 0;
      meri.setTo3();
    }
    // Lines complete, have left screen
    if (key == '4') {
      stLines.resetColors();
      stLines.linesToDraw = stLines.lineNum;
      meri.setTo4();
    }
    // Return in back -- shadows
    if (key == '5') {
      //stLines.invertColors();
      for(int i = 0; i < dripCt; i++) {
        drips[i].setColorRandomGrey();
      }
      stLines.drawLines();
      stLines.linesToDraw = stLines.lineNum;
      meri.setTo5Back();
    }
    // Return in front -- drips
    if (key == '6') {
      for(int i = 0; i < dripCt; i++) {
        drips[i].setColorRandomGrey();
      }
      stLines.resetColors();
      stLines.drawLines();
      stLines.linesToDraw = stLines.lineNum;
      meri.setTo5Front();
    }
  }
}
