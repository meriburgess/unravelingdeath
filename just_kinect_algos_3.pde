import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;

Kinect2 kinect2;
PImage depthImg;

int segCt = 1;
float segThresStart = 500;
float segThresIncr = 300;
float[] segThres = new float[segCt*2];
Segment[] segs = new Segment[segCt];
color[] segCols  = { 
  color(255, 0, 0, 100), 
  color(255, 175, 0, 100), 
  color(255, 255, 0, 100), 
  color(0, 255, 0, 100),
  color(0, 255, 255, 100),
  color(0, 55, 255, 100),
  color(135, 0, 255, 100)
};

int activeSegment;

void setup() {
  background(255);
  size(1024, 848, P2D);
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  
  depthImg = new PImage(kinect2.depthWidth, kinect2.depthHeight, ARGB);
  
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
}


void draw(){
  fill(255, 100);
  rect(0,0,width,height);
  
  for (int i=0; i < segs.length; i++){
    segs[i].newFrame(); 
  }

  depthImg.loadPixels();
  int[] rawDepth = kinect2.getRawDepth();
    for (int x = 0; x < kinect2.depthWidth; x++) {
      for (int y = 0; y < kinect2.depthHeight; y++) {
        int index = x + y * kinect2.depthWidth;
        int p = rawDepth[index];
        
         int segIdx = 0;
         boolean setColor = false;
         for (int j = 0; j < (segCt*2); j+=2) {
           if (p >= segThres[j] && p < segThres[j+1]) {
             segs[segIdx].updateForFrame(x,y);
             depthImg.pixels[index] = segs[segIdx].sColor;  
             setColor = true;
           }
           segIdx++;
         }
         if (!setColor) {
           depthImg.pixels[index] = color(255, 0);  
         }
     
      }
    }
    
    for (int i=0; i < segs.length; i++){
      segs[i].updateAfterWholeFrameChecked(); 
    }
    
    depthImg.updatePixels();
    imageMode(CORNER);
    image(depthImg, 0, 0, depthImg.width*2, depthImg.height*2);
    
    activeSegment = findMaxIdx(segs);
    fill(segs[activeSegment].sColor);
    ellipse(200, 200, (activeSegment+1)*10, (activeSegment+1)*10);
         
    PVector top = segs[activeSegment].getTop();
    PVector btm = segs[activeSegment].getBtm();
    
    PVector left = segs[activeSegment].getLeft();
    PVector right = segs[activeSegment].getRight();
    
  
    noFill();
   //quad(top.x, top.y, right.x, right.y, btm.x, btm.y, left.x, left.y);
    //draw box
   rectMode(CORNER);
   rect(left.x*2, top.y*2, right.x*2-left.x*2, btm.y*2-top.y*2); 
   
   PVector center = segs[activeSegment].getCenter();
   ellipse(center.x*2, center.y*2, 10, 10);
   
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

class Segment {
 color sColor;
 float minDepth, maxDepth;
 Record edges;
 PVector center;
 PVector centerOld;
 float xDiff;
 float yDiff;
 float velocity;
 boolean isActive;
 float totalPixelsInSeg;
 
 Segment(color col, float min, float max) {
   sColor = col;
   minDepth = min;
   maxDepth = max;
   edges = new Record();
   isActive = false;
   totalPixelsInSeg = 0;
   centerOld = new PVector(0,0);
   center = new PVector(0,0);
   xDiff = 0;
   yDiff = 0;
   velocity = 0;
 }
 
 void newFrame() {
   totalPixelsInSeg = 0; 
   centerOld.set(center);
   edges.resetRecord();
 }
 
 void updateForFrame(float x, float y) {
   edges.check(x,y);
   totalPixelsInSeg+=1;
 }
 
 void updateAfterWholeFrameChecked() {
   float cx = ((edges.highestXPt.x - edges.lowestXPt.x) / 2)+ edges.lowestXPt.x;
   float cy = ((edges.highestYPt.y - edges.lowestYPt.y) / 2) + edges.lowestYPt.y;
   center = new PVector(cx, cy);
   velocity = dist(center.x, center.y, centerOld.x, centerOld.y); 
   xDiff = center.x - centerOld.x;
   yDiff = center.y - centerOld.y;
 }
 
 void setIsActive(boolean active) {
   isActive = active;
 }
 
 boolean getIsActive() {
  return isActive; 
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
 
 PVector getCenter() {
    return center;
 }
 
 float getVelocity() {
    return velocity; 
 }
 
 float getXDiff() {
   return xDiff; 
 }
 
 float getTotalPixels() {
   return totalPixelsInSeg; 
 }
 
  
}


class Record {
  
  float lowestY; //"top"
  PVector lowestYPt;
  float highestY; //"bottom"
  PVector highestYPt;
  float lowestX; // "left"
  PVector lowestXPt;
  float highestX; // "right"
  PVector highestXPt;
 
  Record() {
    lowestY = kinect2.depthHeight;
    lowestYPt = new PVector(0,0);
    highestY = 0;
    highestYPt = new PVector(0,0);
    lowestX = kinect2.depthWidth;
    lowestXPt = new PVector(0,0);
    highestX = 0;
    highestXPt = new PVector(0,0);
  }
  
  void check(float newX, float newY){
     if (newY <= lowestY) {
      lowestY = newY; 
      lowestYPt = new PVector(newX, newY);
     }
     if (newY > highestY) {
      highestY = newY; 
      highestYPt = new PVector(newX, newY);
     }
     if (newX <= lowestX) {
      lowestX = newX; 
      lowestXPt = new PVector(newX, newY);
     }
     if (newX > highestX) {
      highestX = newX; 
      highestXPt = new PVector(newX, newY);
     }
  }
  
  void resetRecord() {
    lowestY = kinect2.depthHeight;
    lowestYPt = new PVector(0,0);
    highestY = 0;
    highestYPt = new PVector(0,0);
    lowestX = kinect2.depthWidth;
    lowestXPt = new PVector(0,0);
    highestX = 0;
    highestXPt = new PVector(0,0);
  }
}
