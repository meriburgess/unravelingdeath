
class DripNode {
  PVector p, pOld;
  float strokeWidth;
  boolean reachedEdge = false;  
  color nCol;
  color originalColor;
  color prevColor;
  float downwardStepSize;
  float originalX;
  float originalStroke;
  float lastStroke;
  float hueIncr;
  float hueGoal;
   
  DripNode() {
    PVector newOrigin = startOnTopEdge();
    p = new PVector(newOrigin.x, newOrigin.y);
    pOld = new PVector(newOrigin.x, newOrigin.y);
    originalX = newOrigin.x;
    strokeWidth = random(1, 5);
    originalStroke = strokeWidth;
    lastStroke = strokeWidth;
    downwardStepSize = random(0.1, 3);
    int grey = floor(random(0,100));
    nCol = color(0, 0, grey);
    originalColor = nCol;
    prevColor = nCol;
    
    int whichCol = floor(random(0,4));
    if (whichCol == 0) {
      hueIncr = 90;
      hueGoal = 360;
    } else if (whichCol == 1) {
      hueIncr = 64;
      hueGoal = 255;
    } else if (whichCol == 2) {
      hueIncr = 30; 
      hueGoal = 120;
    } else {
      hueIncr = 15;
      hueGoal = 60;
    }
  }
  
  void setColorWhite() {
    nCol = color(0, 0, 100); // // HSB: 0, 0, 100 RGB: 255, 255, 255 
  }
  
  void setColorBlack() {
    nCol = color(0, 0, 0);
  }
  
  void setColorRandomGrey() {
    int grey = floor(random(0,100));
    nCol = color(0, 0, grey);
  }
  
  void setColorRandomRGB() {
    int whichCol = floor(random(0,4));
    if (whichCol == 0) {
      nCol = color(360, 100, 100);
    } else if (whichCol == 1) {
      nCol = color(120, 100, 100); 
    } else if (whichCol == 2) {
      nCol = color(255, 100, 100); 
    } else {
      nCol = color(60, 100, 100); 
    }
  }
  
  void update() {
    stroke(nCol, 100);
    p.x = random(pOld.x-1, pOld.x+1);
    if (p.x > originalX+5) {
     p.x = pOld.x-0.1; 
    } else if (p.x < originalX-5) {
     p.x = pOld.x+0.1; 
    }
    p.y = pOld.y + downwardStepSize;
   
    if(p.y>height+10) reachedEdge = true;
   
    strokeWidth = random(lastStroke-1, lastStroke+1);
    if (strokeWidth < originalStroke-4 || strokeWidth <= 0) {
       strokeWidth = lastStroke+0.1; 
    } else if (strokeWidth > originalStroke+6) {
       strokeWidth =  lastStroke-0.1;
    }
    lastStroke = strokeWidth;
    strokeWeight(strokeWidth);

    line(pOld.x, pOld.y, p.x, p.y);
    pOld.set(p);
    
    if (reachedEdge == true) {
      PVector newOrigin = startOnTopEdge();
      p.set(newOrigin);
      pOld.set(newOrigin);
      reachedEdge = false;
      updateColor();
    }
  }
  
  void updateColor(){
    prevColor = nCol;
    
    float newHue = hue(prevColor)+hueIncr;
    if (newHue >= hueGoal) {
     newHue = hueGoal; 
    }
    float newSat = saturation(prevColor)+25;
    if (newSat >= 100) {
     newSat = 100; 
    }
    float newBright = brightness(prevColor)+(100-brightness(originalColor)/4);
    if (newBright >= 100) {
     newBright = 100; 
    }
    nCol = color(hueGoal, newSat, newBright);
    
  }
  
  PVector startOnTopEdge() {
    PVector newOrigin = new PVector(random(0,width), 0);
    originalX = newOrigin.x;
    return newOrigin;
  }
  
}
