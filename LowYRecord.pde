class LowYRecord {
  float lowestY; //"top"
  PVector lowestYPt;
  boolean isStable;
  int stable = 10;
  float[] lowestYs = new float[stable];
  
  LowYRecord(boolean moreStable) {
    isStable = moreStable; 
    lowestYPt = new PVector(0,0);
    resetRecord();
  }
  
  void check(float newX, float newY){
    if (!isStable) {
       if (newY <= lowestY) {
        lowestY = newY; 
        lowestYPt = new PVector(newX, newY);
       }
    } else {
       lowestYs = lowArrayValues(newY, lowestYs);
       if (newY == lowestYs[0]) {
          lowestYPt = new PVector(newX, newY);
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

  void resetRecord() {
    if (!isStable) {
      lowestY = kinect2.depthHeight;
    } else {
      for (int i = 0; i < stable; i++) {
        lowestYs[i] = kinect2.depthHeight;
      }
    }
  }
}
