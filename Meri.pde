class Meri {
  int stopCtr = 500;
  int firstEntranceThres = 2500;
  int firstEnterFreezeMin = 10;
  int firstEnterFreezeMax= 200;
  int waitBeforeLinesStop = 300;
  int firstExitThres = 300;
  int secondEnterThres = 200;
  

  boolean firstEntrance;
  int firstEnterFreezeCtr;
  boolean doneFreeze;
  int stops;
  boolean curtainTriggered;
  boolean curtainFinished;
  int waitBeforeLines;
  boolean secondExit;
  boolean secondEntrance;
  int enterBackOrFront; // 0 is front, 1 is back
  
  Meri() {
   firstEntrance = false;
   firstEnterFreezeCtr = 0;
   doneFreeze = false;
   stops = 0;
   curtainTriggered = false;
   curtainFinished = false;
   waitBeforeLines = 0;
   secondExit = false;
   secondEntrance = false;
   enterBackOrFront = -1;
  }
  
  // very beginning
  void resetMeri() {
   freeze = false;
   firstEntrance = false;
   firstEnterFreezeCtr = 0;
   doneFreeze = false;
   stops = 0;
   curtainTriggered = false;
   curtainFinished = false;
   waitBeforeLines = 0;
   secondExit = false;
   secondEntrance = false;
   enterBackOrFront = -1;
  }
  
  // frozen entrance
  void setToAlmost1(){
   freeze = false;
   firstEntrance = true;
   firstEnterFreezeCtr = 0;
   doneFreeze = false;
   stops = 0;
   curtainTriggered = false;
   curtainFinished = false;
   waitBeforeLines = 0;
   secondExit = false;
   secondEntrance = false;
   enterBackOrFront = -1;
  }
  
  // hopping around
  void setTo1(){
   freeze = false;
   firstEntrance = true;
   firstEnterFreezeCtr = firstEnterFreezeMax;
   doneFreeze = true;
   stops = 0;
   curtainTriggered = false;
   curtainFinished = false;
   waitBeforeLines = 0;
   secondExit = false;
   secondEntrance = false;
   enterBackOrFront = -1;
  }
  
  // curtain
  void setTo2(){
   freeze = false;
   firstEntrance = true;
   firstEnterFreezeCtr = firstEnterFreezeMax;
   doneFreeze = true;
   stops = stopCtr;
   curtainTriggered = true;
   curtainFinished = false;
   waitBeforeLines = 0;
   secondExit = false;
   secondEntrance = false;
   enterBackOrFront = -1;
  }
  
  // lines
  void setTo3(){
   freeze = false;
   firstEntrance = true;
   firstEnterFreezeCtr = firstEnterFreezeMax;
   doneFreeze = true;
   stops = stopCtr;
   curtainTriggered = true;
   curtainFinished = true;
   waitBeforeLines = 0;
   secondExit = false;
   secondEntrance = false;
   enterBackOrFront = -1;
  }
  
  // meri over in web
  void setTo4() {
   freeze = false;
   firstEntrance = true;
   firstEnterFreezeCtr = firstEnterFreezeMax;
   doneFreeze = true;
   stops = stopCtr;
   curtainTriggered = true;
   curtainFinished = true;
   waitBeforeLines = waitBeforeLinesStop;
   secondExit = true;
   secondEntrance = false;
   enterBackOrFront = -1;
  }
  
  void setTo5Back() { //Shadows
   freeze = true;
   firstEntrance = true;
   firstEnterFreezeCtr = firstEnterFreezeMax;
   doneFreeze = true;
   stops = stopCtr;
   curtainTriggered = true;
   curtainFinished = true;
   waitBeforeLines = waitBeforeLinesStop;
   secondExit = true;
   secondEntrance = true;
   enterBackOrFront = 1;
  }
  
  void setTo5Front() { //drips
   freeze = true;
   firstEntrance = true;
   firstEnterFreezeCtr = firstEnterFreezeMax;
   doneFreeze = true;
   stops = stopCtr;
   curtainTriggered = true;
   curtainFinished = true;
   waitBeforeLines = waitBeforeLinesStop;
   secondExit = true;
   secondEntrance = true;
   enterBackOrFront = 0;
  }
}
