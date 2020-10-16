class StaticLines {
  int lineNum;
  PVector[] startPts;
  PVector[] endPts;
  int[] weights;
  boolean[] startOnXAxis;
  boolean[] endOnXAxis;
  boolean[] shiftStartUp;
  boolean[] shiftEndUp; 
  int linesToDraw;
  
  float shiftIncr;
  
  color bgCol;
  color lineCol;
  
  StaticLines(int number, float shift) {
    shiftIncr = shift;   
    lineNum = number;
    linesToDraw = 0;
    startPts = new PVector[lineNum];
    endPts = new PVector[lineNum];
    weights = new int[lineNum];
    startOnXAxis = new boolean[lineNum];
    endOnXAxis = new boolean[lineNum];;
    shiftStartUp = new boolean[lineNum];
    shiftEndUp = new boolean[lineNum];
    
    bgCol = color(0);
    lineCol = color(255);
    
    int startX = 0;
    int startY = 0;
    int endX = 0;
    int endY = 0;
    for (int i = 0; i < lineNum; i++) {
      int startAxis = floor(random(0,2));
      if (startAxis == 0) {
        startX = floor(random(0, width));
        startY = 0;
        startOnXAxis[i] = true;
      } else {
        startX = 0;
        startY = floor(random(0,height));
        startOnXAxis[i] = false;
      }
      int endAxis = floor(random(0,2));
      if (endAxis == 0) {
        endX = floor(random(0, width));
        endY = height;
        endOnXAxis[i] = true;
      } else {
        endX = width;
        endY = floor(random(0,height));
        endOnXAxis[i] = false;
      }
      int weight = floor(random(1, 10));
      startPts[i] = new PVector(startX, startY);
      endPts[i] = new PVector(endX, endY);
      weights[i] = weight;
      shiftStartUp[i] = true;
      shiftEndUp[i] = true;
    }
  }
  
  void shiftLines() {
    float shiftXIncr = random(0, shiftIncr);
    float shiftYIncr = random(0, shiftIncr);
    
    for (int i = 0; i < linesToDraw; i++) {
       
       if (startOnXAxis[i]) {
         float oldX = startPts[i].x;
          if (oldX >= width) {
            shiftStartUp[i] = false; 
          } else if (oldX <= 0) {
            shiftStartUp[i] = true;
          }
          if (shiftStartUp[i]) {
            startPts[i] = new PVector(oldX+shiftXIncr, 0);           
          } else {
            startPts[i] = new PVector(oldX-shiftXIncr, 0);
          }
       } else {
         float oldY = startPts[i].y;
          if (oldY >= height) {
             shiftStartUp[i] = false; 
          } else if (oldY <= 0) {
            shiftStartUp[i] = true;
          }
          if (shiftStartUp[i]) {
            startPts[i] = new PVector(0, oldY+shiftYIncr);           
          } else {
            startPts[i] = new PVector(0, oldY-shiftYIncr);
          }
       }
  
       if (endOnXAxis[i]) {
         float oldX = endPts[i].x;
          if (oldX >= width) {
            shiftEndUp[i] = false; 
          } else if (oldX <= 0) {
            shiftEndUp[i] = true;
          }
          if (shiftEndUp[i]) {
            endPts[i] = new PVector(oldX+shiftIncr, height);           
          } else {
            endPts[i] = new PVector(oldX-shiftIncr, height);
          }
       } else {
         float oldY = endPts[i].y;
          if (oldY >= height) {
             shiftEndUp[i] = false; 
          } else if (oldY <= 0) {
            shiftEndUp[i] = true;
          }
          if (shiftEndUp[i]) {
            endPts[i] = new PVector(width, oldY+shiftIncr);           
          } else {
            endPts[i] = new PVector(width, oldY-shiftIncr);
          }
       }
       
    }
    
  }
  
  void invertColors() {
    bgCol = color(255);
    lineCol = color(0);
  }
  
  void resetColors() {
    bgCol = color(0);
    lineCol = color(255);
  }
  
  void drawLines() {
    noStroke();
    fill(bgCol);
    rect(0, 0, width, height);
    stroke(lineCol);
    for (int i = 0; i < linesToDraw; i++) {
      strokeWeight(weights[i]);
      line(startPts[i].x, startPts[i].y, endPts[i].x, endPts[i].y);
    }
  }
    
}
