
class Node {
  PVector p, pOld;
  float noiseScale, noiseStrength;
  float defaultStepSize;
  float stepSize;
  float strokeWidth;
  boolean reachedEdge = false;  
  String type;
  color nCol;
   
  Node(String typ) {
    PVector newOrigin;
    switch(typ){ 
      case "top":
        newOrigin = startOnEdge();
        p = new PVector(newOrigin.x, newOrigin.y);
        pOld = new PVector(newOrigin.x, newOrigin.y);
        noiseScale = random(15, 75);
        noiseStrength = random(-10, 10);
        stepSize = random(0.5, 3);
        defaultStepSize = stepSize;
        strokeWidth = random(20, 30);
        type = "top";
        nCol = color(floor(random(0, 360)), floor(random(80, 100)), floor(random(80, 100))); 
        break;
      case "mid":
        newOrigin = startOnEdge();
        p = new PVector(newOrigin.x, newOrigin.y);
        pOld = new PVector(newOrigin.x, newOrigin.y);
        noiseScale = random(15, 75);
        noiseStrength = random(-10, 10);
        stepSize = random(1, 6);
        defaultStepSize = stepSize;
        strokeWidth = random(10, 15);
        type = "mid";
        nCol = color(floor(random(0, 360)), floor(random(80, 100)), floor(random(80, 100))); 
        break;
      case "btm":
        newOrigin = new PVector(random(0, width), random(0, height));
        p = new PVector(newOrigin.x, newOrigin.y);
        pOld = new PVector(newOrigin.x, newOrigin.y);
        noiseScale = random(15, 75);
        noiseStrength = random(-10, 10);
        stepSize = random(0.5);
        defaultStepSize = stepSize;
        strokeWidth = 45;
        type = "btm";
        nCol = bgNodeColor;
        break;
       
    }
  }
  
  void update() {
    switch(type){ 
      case "top":
        stroke(hue(nCol), saturation(nCol)*saturationLevel, brightness(nCol)*brightnessLevel, topAgentsAlpha);
        break;
      case "mid":
        stroke(hue(nCol), saturation(nCol)*saturationLevel, brightness(nCol)*brightnessLevel, topAgentsAlpha);
        break;
      case "btm":
        stroke(hue(bgNodeColor), saturation(bgNodeColor)*saturationLevel, brightness(bgNodeColor)*brightnessLevel, btmAgentsAlpha);
        break;
    }
    
    float angle = noise(pOld.x/noiseScale, pOld.y/noiseScale) * noiseStrength;
    p.x =  pOld.x + cos(angle) * (stepSize*speedModulator);
    p.y = pOld.y + sin(angle) * (stepSize*speedModulator);
   
    if(p.x<-10) reachedEdge = true;
    else if(p.x>width+10) reachedEdge = true;
    else if(p.y<-10) reachedEdge = true;
    else if(p.y>height+10) reachedEdge = true;
   
    strokeWeight(strokeWidth);

    line(pOld.x, pOld.y, p.x, p.y);
    pOld.set(p);
    
    if (reachedEdge == true) {
      PVector newOrigin = startOnEdge();
      p.set(newOrigin);
      pOld.set(newOrigin);
      reachedEdge = false;
      nCol = color(floor(random(0, 360)), floor(random(80, 100)), floor(random(80, 100))); 
    }
  }
  
  PVector startOnEdge() {
    PVector newOrigin = new PVector(0,0);
    int axis = floor(random(1,4));
    switch(axis) {
      case 0:
        newOrigin = new PVector(0, random(0,height));
        break;
      case 1: 
        newOrigin = new PVector(random(0,width), 0);
        break;
      case 2: 
        newOrigin = new PVector(width, random(0, height));
        break;
      case 3:
        newOrigin = new PVector(random(0,width), height);
        break;
    } 
    return newOrigin;
  }
  
}
