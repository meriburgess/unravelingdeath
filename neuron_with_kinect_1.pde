import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;

Kinect2 kinect2;
PImage depthImg;
boolean useKinect = true;
boolean showKinect = false;
boolean flipKinect = false;
boolean showNodes = true;

// Threshold
int minDepth = 60;
int maxDepth = 800;

boolean freeze = false;

float overlayAlpha = 10;
float topAgentsAlpha = 100;
float midAgentsAlpha = 50;
float btmAgentsAlpha = 10;

int topNodeCt = 60;
Node[] topNodes = new Node[topNodeCt];
int midNodeCt = 40;
Node[] midNodes = new Node[midNodeCt];
int btmNodeCt = 100;
Node[] btmNodes = new Node[btmNodeCt];

int clusterCt = 5;
Cluster[] clusters = new Cluster[clusterCt];

//red green blue yellow magenta cyan
//color[] mycolours = {#ff0000, #00ff00, #0000ff, #ffff00, #ff00ff, #00ffff};
//{70,70,70}, {200,100,255}, {20, 215,0}
// {0,0,27}, {277,60,99},  {114, 99,83}
color[] colors = {#464646, #C864FF, #14D700};

color bgNodeColor, midNodeColor, topNodeColor;
int topHue;
int bgSaturation, midSaturation, topSaturation;
int bgBright, midBright, topBright;

float saturationLevel;
float brightnessLevel;
float speedModulator;


void setup() {
  size(1024, 848, P2D);
  if (useKinect) {
    kinect2 = new Kinect2(this);
    kinect2.initDepth();
    kinect2.initDevice();
    
    depthImg = new PImage(kinect2.depthWidth, kinect2.depthHeight, ARGB);
  }
  background(0);
  colorMode(HSB, 360, 100, 100);
  
  saturationLevel = 1.0;
  brightnessLevel = 1.0;
  speedModulator = 1.0;
  
  topHue = 114;
  bgSaturation = 0;
  midSaturation = 60;
  topSaturation = 99;
  bgBright = 27;
  midBright = 99;
  topBright = 83;
  bgNodeColor = color(0, bgSaturation*saturationLevel, bgBright*brightnessLevel);
  midNodeColor = color(277, midSaturation*saturationLevel, midBright*brightnessLevel);
  topNodeColor = color(topHue, topSaturation*saturationLevel, topBright*brightnessLevel);
  
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
   clusters[i] = new Cluster(random(0, width), random(0,height), random(20,60), floor(random(5,10)), 5);
  }
  
  
  
}

void draw(){
  depthImg.loadPixels();
  if (keyPressed == true) {
    if (key == 'a') {
      freeze = !freeze;
    }
    if (key == 's') {
      if (saturationLevel >= 0) {
        saturationLevel = saturationLevel - 0.01;
        brightnessLevel -= 0.005;
      }
    }
    if (key == 'd') {
      if (saturationLevel <= 1.0) {
        saturationLevel = saturationLevel + 0.01;
        brightnessLevel += 0.005;
      }
    }
    if (key == 'q') {
      if (speedModulator >= 0.05 ) {
        speedModulator -= 0.01;
      }
    }
    if (key == 'w') {
     if (speedModulator <= 2.0) {
      speedModulator += 0.01; 
     }
    }
  }
  bgNodeColor = color(0, bgSaturation*saturationLevel, bgBright*brightnessLevel);
  midNodeColor = color(277, midSaturation*saturationLevel, midBright*brightnessLevel);
  topNodeColor = color(114, topSaturation*saturationLevel, topBright*brightnessLevel);
  
  if (useKinect) {
    float sumX = 0;
    float sumY = 0;
    float totalPixels = 0;
     
    int[] rawDepth = kinect2.getRawDepth();
    for (int x = 0; x < kinect2.depthWidth; x++) {
      for (int y = 0; y < kinect2.depthHeight; y++) {
        int index = x + y * kinect2.depthWidth;
        int p = rawDepth[index];
   
        if (p > minDepth && p < maxDepth) {
          depthImg.pixels[index] = color(180, 0, 80, 10); //Silhouette color
          
          sumX += x;
          sumY += y;
          totalPixels++;
        } else {
          depthImg.pixels[index] = color(0, 0, 0, 0); // background color
        }
      }
    }
    
    //float avgX = sumX/totalPixels;
    //float avgY = sumY/totalPixels;
    fill(150, 150, 140, 50);
    //ellipse(avgX, avgY, 50, 50);
    if (showKinect) {
      depthImg.updatePixels();
      imageMode(CENTER);
      
      if (flipKinect) {
        pushMatrix();
        //currently flipped
        scale(1.0, -1.0);
        image(depthImg, depthImg.width, -depthImg.height, depthImg.width*2, depthImg.height*2);
        popMatrix();
      } else {
        image(depthImg, depthImg.width, depthImg.height, depthImg.width*2, depthImg.height*2);
      }
    }
  }

  if (!freeze) {
    fill(0, overlayAlpha);
    noStroke();
    rect(0,0,width,height);
  }

  if (showNodes && !freeze) {
    stroke(hue(bgNodeColor), saturation(bgNodeColor), brightness(bgNodeColor), btmAgentsAlpha);
    for (int i = 0; i < btmNodeCt; i++) {
       btmNodes[i].update(); 
    }
    stroke(hue(midNodeColor), saturation(midNodeColor), brightness(midNodeColor), midAgentsAlpha);
    for (int i = 0; i < midNodeCt; i++) {
       midNodes[i].update(); 
    }
    stroke(hue(topNodeColor), saturation(topNodeColor), brightness(topNodeColor), topAgentsAlpha);
    for (int i = 0; i < topNodeCt; i++) {
       topNodes[i].update();   
       for (int j = 0; j < clusterCt; j++) {
          if (clusters[j].isPassing(topNodes[i].p)) {
            clusters[j].drawShapeWithGlow(); 
          }
       }
    }
  }
  
  
  // TODO: draw a few lines (at random) to completion at all times
  // or vary which ones? 

  


}



// -----------------------------------------------------------------------------------


class Node {
  PVector p, pOld;
  float noiseScale, noiseStrength;
  float defaultStepSize;
  float stepSize;
  float strokeWidth;
  boolean reachedEdge = false;  
   
  Node(String type) {
    PVector newOrigin;
    switch(type){ 
      case "top":
        newOrigin = startOnEdge();
        p = new PVector(newOrigin.x, newOrigin.y);
        pOld = new PVector(newOrigin.x, newOrigin.y);
        noiseScale = random(15, 75);
        noiseStrength = random(-10, 10);
        stepSize = random(0.5, 3);
        defaultStepSize = stepSize;
        strokeWidth = random(5, 10);
        break;
      case "mid":
        newOrigin = startOnEdge();
        p = new PVector(newOrigin.x, newOrigin.y);
        pOld = new PVector(newOrigin.x, newOrigin.y);
        noiseScale = random(15, 75);
        noiseStrength = random(-10, 10);
        stepSize = random(1, 6);
        defaultStepSize = stepSize;
        strokeWidth = random(1, 5);
        break;
      case "btm":
        newOrigin = new PVector(random(0, width), random(0, height));
        p = new PVector(newOrigin.x, newOrigin.y);
        pOld = new PVector(newOrigin.x, newOrigin.y);
        noiseScale = random(15, 75);
        noiseStrength = random(-10, 10);
        stepSize = random(0.5);
        defaultStepSize = stepSize;
        strokeWidth = 20;
        break;
       case "line":
         newOrigin = startOnEdge();
        p = new PVector(newOrigin.x, newOrigin.y);
        pOld = new PVector(newOrigin.x, newOrigin.y);
        noiseScale = random(15, 75);
        noiseStrength = random(-10, 10);
        stepSize = random(0.5, 3);
        defaultStepSize = stepSize;
        strokeWidth = random(5, 10);
       
    }
  }
  
  void update() {
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

class Cluster {
 
  boolean active = false;
  
  PVector center;
  float radius; 
  int complexity;
  PVector[] endpoints;
  PShape cShape;
  
  int lineCt;
  ClusterNode[] lines;
  int activeLineIdx;
  
  Cluster(float centerX, float centerY, float rad, int complex, int line) {
    center = new PVector(centerX, centerY);
    radius = rad;
    complexity = complex;
    endpoints = new PVector[complexity]; 
    
    lineCt = line;
    lines = new ClusterNode[lineCt];
    activeLineIdx = -1;
    
    for (int i=0; i < complexity; i++) {
      float length;
       // TODO: only allow change from previous to be within a certain range
      float likelyRange = random(1);
      if (likelyRange > 0.4) {
        length = random(radius/2,(radius/2)+(radius*5/8));
      } else if (likelyRange > 0.2) {
       length = random((radius/2)+(radius*3/8),radius/2); 
      } else if (likelyRange > 0.05) {
       length = random((radius/2)+(radius*5/8), (radius*3)/4); 
      } else {
       length = random((radius/2)+(radius*7/8), radius); 
      }
    
       float angle=TWO_PI/(float)complexity;
       float x2 = center.x+(length*sin(angle*i)); 
       float y2 = center.y+(length*cos(angle*i)); 
       endpoints[i] = new PVector(x2, y2);
    }
    
    // make PShape object 
    cShape = createShape();
    cShape.beginShape();
    //shape.fill(topNodeColor, 100);
    for (int i=0; i < complexity; i++) {
      cShape.vertex(endpoints[i].x-center.x, endpoints[i].y-center.y);
    }
    cShape.endShape(CLOSE); 
    
    // TODO: have cluster own it's own nodes, send off when activated
    for (int l= 0; l < lineCt; l++) {
      lines[l] = new ClusterNode(center.x, center.y);
    }
  }
  
  void drawClusterStatic() {
    ellipse(center.x, center.y, radius, radius);
    //shape(cShape, center.x, center.y);
  }
  
  void drawCircleWithGlow() {
    stroke(topHue, topBright, topSaturation, 20);
    strokeWeight(5);
    ellipse(center.x, center.y, 5, 5);
    noFill();
    stroke(topHue, topBright, topSaturation, 15);
    ellipse(center.x, center.y, 15, 15);
    stroke(topHue, topBright, topSaturation, 10);
    ellipse(center.x, center.y, 25, 25);
    stroke(topHue, topBright, topSaturation, 5);
    ellipse(center.x, center.y, 35, 35);
  }
  
  void drawShapeWithGlow() {
    color cColor = color(topHue, topBright, topSaturation, 1);
    cShape.setFill(cColor);
    cShape.setStroke(false);
    shape(cShape, center.x, center.y);
    
    cShape.scale(0.9);
    shape(cShape, center.x, center.y);
    //reset
    cShape.scale(1.11111);
    
    cShape.scale(0.8);
    shape(cShape, center.x, center.y);
    //reset
    cShape.scale(1.25);
    
    cShape.scale(0.7);
    shape(cShape, center.x, center.y);
    //reset
    cShape.scale(1.42857);
    
    cShape.scale(0.6);
    shape(cShape, center.x, center.y);
    //reset
    cShape.scale(1.666667);
    
    cShape.scale(0.5);
    shape(cShape, center.x, center.y);
    //reset
    cShape.scale(2.0);
    
    cShape.scale(0.4);
    shape(cShape, center.x, center.y);
    //reset
    cShape.scale(2.5);
    
    cShape.scale(0.3);
    shape(cShape, center.x, center.y);
    //reset
    cShape.scale(3.33333334);
    
    cShape.scale(0.2);
    shape(cShape, center.x, center.y);
    //reset
    cShape.scale(5);
    
    //if (activeLineIdx >= (lineCt - 1)) {
    //  activeLineIdx = 0;
    //} else {
    //  activeLineIdx++; 
    //}
  }
  
  void drawClusterPulse() {
     float adjustedRadius = radius/8;
     ellipse(center.x, center.y, adjustedRadius, adjustedRadius); 
     float difference = radius - adjustedRadius;
     for(int i = floor(adjustedRadius); i < radius; i+= 2){
        stroke(255,255.0*(1-i/difference));
        ellipse(center.x,center.y,i,i);
      }
  }
  
  boolean isPassing(PVector point) {
   // ellipse implementation 
  
   float adjustedRadius = radius/2; //radius/8;
   float dx = abs(point.x-center.x);
   float dy = abs(point.y-center.y);
   if (dx + dy <= adjustedRadius) return true;
   else if (dx > adjustedRadius) return false;
   else if (dy > adjustedRadius) return false;
   else if (pow(dx,2) + pow(dy,2) <= pow(adjustedRadius, 2)) return true;
   else return false;
   
   // polygon implementation
   /*
   int i, j;
   boolean passing = false;
   
    for (i = 0, j = complexity-1; i < complexity; j = i++) {
      if ( ((endpoints[i].y>point.y) != (endpoints[j].y>point.y)) &&
       (point.x < (endpoints[j].x-endpoints[i].x) * (point.y-endpoints[i].y) / (endpoints[j].y-endpoints[i].y) + endpoints[i].x) )
         passing = !passing;
    }
    return passing;
    */
    
  }
  
}

//---------------------------
class ClusterNode {
  PVector p, pOld, pOrigin;
  float noiseScale, noiseStrength;
  float stepSize;
  boolean reachedEdge = false;
  int strokeWidth;
  
 
  ClusterNode(float startX, float startY) {
    pOrigin = new PVector(startX, startY);
    p = new PVector(startX, startY);
    pOld = new PVector(startX, startY);
    noiseScale = random(15, 75);
    noiseStrength = random(-10, 10);
    stepSize = random(0.5, 3);
    strokeWidth = floor(random(1,3));
  }
  
  void update() {
    float angle = noise(pOld.x/noiseScale, pOld.y/noiseScale) * noiseStrength;
    p.x =  pOld.x + cos(angle) * stepSize;
    p.y = pOld.y + sin(angle) * stepSize;
   
    if(p.x<-10) reachedEdge = true;
    else if(p.x>width+10) reachedEdge = true;
    else if(p.y<-10) reachedEdge = true;
    else if(p.y>height+10) reachedEdge = true;
   
    strokeWeight(strokeWidth*stepSize);

    line(pOld.x, pOld.y, p.x, p.y);
    pOld.set(p);
    
    if (reachedEdge == true) {
      p.set(pOrigin);
      pOld.set(pOrigin);
      reachedEdge = false;
    }
  }
  
  boolean isDone() {
   return reachedEdge; 
  }
}





// -----------------------------------------------------------------------------------
// Utility functions 
