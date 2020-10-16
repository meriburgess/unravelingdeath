class Record {
  float lowestY; //"top"
  PVector lowestYPt;
  float highestY; //"bottom"
  PVector highestYPt;
  float lowestX; // "left"
  PVector lowestXPt;
  float highestX; // "right"
  PVector highestXPt;
  
  boolean isStable;
  int stable = 50;
  float[] lowestYs = new float[stable];
  float[] highestYs = new float[stable];
  float[] lowestXs = new float[stable];
  float[] highestXs = new float[stable];
 
  Record(boolean moreStable) {
    isStable = moreStable; 
    highestYPt = new PVector(0,0);
    lowestYPt = new PVector(0,0);
    highestXPt = new PVector(0,0);
    lowestXPt = new PVector(0,0);
    resetRecord();
  }
  
  void check(float newX, float newY){
    if (!isStable) {
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
    } else {
     // int newYIdx = isLowerThanAnyValueInArray(newY, lowestYs);
       highestYs = highArrayValues(newY, highestYs);
       if (newY == highestYs[0]) {
          highestYPt = new PVector(newX, newY);
       }
       highestXs = highArrayValues(newX, highestXs);
       if (newX == highestYs[0]) {
          highestXPt = new PVector(newX, newY);
       }
       lowestYs = lowArrayValues(newY, lowestYs);
       if (newY == lowestYs[0]) {
          lowestYPt = new PVector(newX, newY);
       }
       lowestXs = lowArrayValues(newX, lowestXs);
       if (newX == lowestYs[0]) {
          lowestXPt = new PVector(newX, newY);
       }
      
    }
  }
  
  float[] lowArrayValues(float checkVal, float[] checkArr) {
    float[] newArr = new float[stable];
    //assume lowest is always at index length-1
    //assume highest is always at index 0
    
    if (checkVal < checkArr[0]) {
     for (int i = 1; i < stable; i++) {
       if (i == stable-1) {
         if (checkVal < checkArr[stable-1]) {
           for ( int j = 1; j <= stable-1; j++) {
             newArr[j-1] = checkArr[j];  
           }
           newArr[stable-1] = checkVal;
           return newArr;
         } else {
           for ( int j = 1; j <= i-1; j++) {
             newArr[j-1] = checkArr[j];
           }
           newArr[i-1] = checkVal;
           newArr[i] = checkArr[i];
           return newArr;
         }
       } else if (checkVal >= checkArr[i]) {
           if (i == 1) {
             newArr[0] = checkVal;
             for ( int j = 1; j < stable; j++) {
               newArr[j] = checkArr[j];
             }
             return newArr;
           } else { 
             for ( int j = 1; j < i; j++) {
               newArr[j-1] = checkArr[j];
             }
             // add checkVal to index i
             newArr[i-1] = checkVal;
             for ( int j = i; j <= stable-1; j++) {
                newArr[j] = checkArr[j];
             }
             return newArr;
           }
       }
     }
    } 
    return checkArr;
  }

  
  float[] highArrayValues(float checkVal, float[] checkArr) {
    float[] newArr = new float[stable];
    //assume highest is always at index length-1
    //assume lowest is always at index 0
    if (checkVal > checkArr[0]) {
     for (int i = 1; i < stable; i++) {
       if (i == stable-1) {
         if (checkVal > checkArr[stable-1]) {
           for ( int j = 1; j <= stable-1; j++) {
             newArr[j-1] = checkArr[j];  
           }
           newArr[stable-1] = checkVal;
           return newArr;
         } else {
           for ( int j = 1; j <= i-1; j++) {
             newArr[j-1] = checkArr[j];
           }
           newArr[i-1] = checkVal;
           newArr[i] = checkArr[i];
           return newArr;
         }
       } else if (checkVal <= checkArr[i]) {
           if (i == 1) {
             newArr[0] = checkVal;
             for ( int j = 1; j < stable; j++) {
               newArr[j] = checkArr[j];
             }
             return newArr;
           } else { 
             for ( int j = 1; j < i; j++) {
               newArr[j-1] = checkArr[j];
             }
             // add checkVal to index i
             newArr[i-1] = checkVal;
             for ( int j = i; j <= stable-1; j++) {
                newArr[j] = checkArr[j];
             }
             return newArr;
           }
       }
     }
    } 
    return checkArr;
  }
  
  void resetRecord() {
    if (!isStable) {
      lowestY = kinect2.depthHeight;
      highestY = 0;
      lowestX = kinect2.depthWidth;
      highestX = 0;
    } else {
      for (int i = 0; i < stable; i++) {
        highestYs[i] = 0;
        lowestYs[i] = kinect2.depthHeight;
        highestXs[i] = 0;
        lowestXs[i] = kinect2.depthWidth; 
      }
    }
  }
}
