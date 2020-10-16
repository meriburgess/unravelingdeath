class Segment {
 color sColor;
 float minDepth, maxDepth;
 
 PVector center;
 PVector centerOld;
 
 float xDiff;
 float yDiff;
 float zDiff;
 
 float velocity;
 int velocityAvgCtr;
 int velocityIdx; 
 float[] velocities;
 
 float oldTotalPixels;
 float totalPixelsInSeg;
 float totalPixelDiff;
 float totalXVals;
 float totalYVals;
 float totalZVals;
 
 LowYRecord topEdge;
 float curtainSideLeft;
 float curtainSideRight;
 float curtainSideTop;
 
 Record edges; //Deprecated

 Segment(color col, float min, float max) {
    sColor = col;
    minDepth = min;
    maxDepth = max;
   
    totalPixelsInSeg = 0;
    oldTotalPixels = 0;
    centerOld = new PVector(0,0);
    center = new PVector(0,0);
    xDiff = 0;
    yDiff = 0;
    zDiff = 0;
    totalPixelDiff = 0;
   
    velocity = 0;
    velocityAvgCtr = 50;
    velocityIdx = 0;
    velocities = new float[velocityAvgCtr];
    for (int i = 0; i < velocityAvgCtr; i++) {
      velocities[i] = 0; 
    }
    topEdge = new LowYRecord(true);
    curtainSideLeft = 0;
    curtainSideRight = 0;
    curtainSideTop = 0;
   
    edges = new Record(true); // Deprecated
  }
 
  void newFrame() {
    oldTotalPixels = totalPixelsInSeg;
    centerOld.set(center);
    totalPixelsInSeg = 0; 
    totalXVals = 0;
    totalYVals = 0;
    totalZVals = 0;
    topEdge.resetRecord();
  
    // Deprecated
    //edges.resetRecord();
  }
 
  void updateForFrame(float x, float y, float p) {
    if (x <= 400) {
      topEdge.check(x,y);
    }
    totalPixelsInSeg+=1;
    totalXVals += x;
    totalYVals += y;
    totalZVals += p;
   
    // Deprecated
    // edges.check(x,y);
  }
 
  void updateAfterWholeFrameChecked() {
    // Calculate center
    float cx = totalXVals / totalPixelsInSeg;
    float cy = totalYVals / totalPixelsInSeg;
    float cz = totalZVals / totalPixelsInSeg;
    center = new PVector(cx, cy, cz);
   
    // Velocities
    velocity = dist(center.x, center.y, center.z, centerOld.x, centerOld.y, centerOld.z); 
    velocities[velocityIdx] = velocity;
    if (velocityIdx == velocityAvgCtr-1) {
      velocityIdx = 0; 
    } else {
      velocityIdx++;
    } 
   
    xDiff = center.x - centerOld.x;
    yDiff = center.y - centerOld.y;
    zDiff = center.z - centerOld.z;
    totalPixelDiff = totalPixelsInSeg - oldTotalPixels;
  }
 
  void setColor(color col) {
    sColor = col; 
  }
 
  PVector getTop2() {
    return topEdge.lowestYPt; 
  }
 
  PVector getCenter() {
    return center;
  }
 
  float getXDiff() {
    return xDiff; 
  }
 
  float getTotalPixelDiff() {
    return totalPixelDiff; 
  }
 
  float getTotalPixels() {
    return totalPixelsInSeg; 
  }
 
  float getVelocity() {
    return velocity; 
  }
 
  float getVelocityAvg() {
    float total = 0;
     for (int i = 0; i < velocityAvgCtr; i++) {
       total += velocities[i];
     }
     return total/velocityAvgCtr;
  }
 
  void drawTopCurtain() {
    fill(0, 0, 0);
    rectMode(CORNER);
    PVector top = segs[activeSegment].getTop2();
    rect(0, 0,  kinect2.depthWidth*xScale, (top.y*yScale)); 
  }
 
  void drawCurtainWithSides() {
    noStroke();
    fill(0, 0, 0);
    rectMode(CORNER);
    
    PVector top = segs[activeSegment].getTop2();
    float diff = ((kinect2.depthWidth*xScale)-curtainSideRight)-curtainSideLeft;
    if (diff > 300) {
      rect(0, 0,  kinect2.depthWidth*xScale, (top.y*yScale)); 
      curtainSideTop = top.y*yScale;
    } else {
      rect(0,0, kinect2.depthWidth*xScale, curtainSideTop);
    }
    
    rect(0,0, curtainSideLeft, (kinect2.depthHeight*yScale));
    rect((kinect2.depthWidth*xScale)-curtainSideRight, 0, curtainSideRight, (kinect2.depthHeight*yScale));
    rect(curtainSideLeft,  (kinect2.depthHeight*yScale)-btmThres*xScale, diff, 0*xScale);
    
    curtainSideLeft += 0.75;
    curtainSideRight += 0.25;
    curtainSideTop += 0.5;
  }
  
  boolean curtainDone() {
    float diff = ((kinect2.depthWidth*xScale)-curtainSideRight)-curtainSideLeft;
    if (diff > 0) {
      return false;
    }
    return true;
  }
  
  void resetCurtainVals() {
    curtainSideLeft = 0;
    curtainSideRight = 0;
    curtainSideTop = 0;
  }

  //
  // Indicators for debugging
 //
  void drawActiveIndicator() {
    fill(sColor);
    ellipse(indicatorCenter.x, indicatorCenter.y, 30, 30);
  }
 
  void drawCenterIndicator() {
    noFill();
    strokeWeight(5);
    stroke(255);
    ellipse(center.x*xScale, center.y*yScale, 10, 10);
  }
 
  void drawMovingLeftIndicator() {
    if (xDiff > 5) {
      fill(350, 100, 100, 100);
     } else {
       noFill();
     }
     ellipse(indicatorCenter.x-50, indicatorCenter.y, 30, 30);
  }
 
  void drawMovingRightIndicator() {
    if (xDiff < -5) {
      fill(240, 100, 100, 100);
    } else {
      noFill();
    } 
    ellipse(indicatorCenter.x+50, indicatorCenter.y, 30, 30);
  }
 
  void drawMovingUpIndicator() {
    if (yDiff > 5) {
      fill(350, 100, 100, 100);
    } else {
      noFill(); 
    }
    ellipse(indicatorCenter.x, indicatorCenter.y-50, 30, 30);
  }
 
  void drawMovingDownIndicator() {
    if (yDiff < -5) {
      fill(240, 100, 100, 100);
    } else {
      noFill();
    }
    ellipse(indicatorCenter.x, indicatorCenter.y+50, 30, 30);
  }
 
  void drawMovingFwdIndicator() {
    if (zDiff > 10) {
      fill(350, 100, 100, 100);
    } else {
      noFill(); 
    }
    ellipse(1300, 50, 50, 50);
    ellipse(indicatorCenter.x, indicatorCenter.y-100, 30, 30);
  }
 
  void drawMovingBackIndicator() {
    if (zDiff < -10) {
      fill(240, 100, 100, 100);
    } else {
      noFill();
    }
    ellipse(indicatorCenter.x, indicatorCenter.y+100, 30, 30);
  }
 
  void drawRelativeVelocityIndicator() {
    noFill(); 
    if (velocity < 3) {
      ellipse(indicatorCenter.x+100, indicatorCenter.y, 10, 10);
    } else {
       ellipse(indicatorCenter.x+100, indicatorCenter.y, 5*velocity, 5*velocity);
    }
  }
 
 // Deprecated
  void drawBox() {
    PVector top = segs[activeSegment].getTop();
    PVector btm = segs[activeSegment].getBtm();
    
    PVector left = segs[activeSegment].getLeft();
    PVector right = segs[activeSegment].getRight();
    
    noFill();  
    rectMode(CORNER);
    rect(left.x*xScale, top.y*yScale, right.x*xScale-left.x*xScale, btm.y*yScale-top.y*yScale); 
  }
 
  PVector getTop() {
    return edges.lowestYPt; 
  }
 
  PVector getBtm() {
    return edges.highestYPt; 
  }
 
  PVector getRight() {
    return edges.highestXPt; 
  }
 
  PVector getLeft() {
    return edges.lowestXPt; 
  }

}
