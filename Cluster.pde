class Cluster {  
  PVector center;
  float radius; 
  int complexity;
  PVector[] endpoints;
  PShape cShape;
  color cColor;
  
  Cluster(float centerX, float centerY, float rad, int complex) {
    center = new PVector(centerX, centerY);
    radius = rad;
    complexity = complex;
    endpoints = new PVector[complexity]; 
    cColor = color(floor(random(0, 360)), floor(random(80, 100))*saturationLevel, floor(random(80, 100))*brightnessLevel);

    
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
  }
  
  void drawShapeWithGlow() {
    color cCol = color(hue(cColor), saturation(cColor)*saturationLevel, brightness(cColor)*brightnessLevel);
    cShape.setFill(cCol);
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
  }
  
  //
  // Unused
  //
  void drawClusterStatic() {
    ellipse(center.x, center.y, radius, radius);
  }
  
  void drawClusterShapeStatic() {
    shape(cShape, center.x, center.y);
  }
  
  void drawCircleWithGlow() {
    stroke(hue(cColor), saturation(cColor)*saturationLevel, brightness(cColor)*brightnessLevel, 20);
    strokeWeight(5);
    ellipse(center.x, center.y, 5, 5);
    noFill();
    stroke(hue(cColor), saturation(cColor)*saturationLevel, brightness(cColor)*brightnessLevel, 15);
    ellipse(center.x, center.y, 15, 15);
    stroke(hue(cColor), saturation(cColor)*saturationLevel, brightness(cColor)*brightnessLevel, 10);
    ellipse(center.x, center.y, 25, 25);
    stroke(hue(cColor), saturation(cColor)*saturationLevel, brightness(cColor)*brightnessLevel, 5);
    ellipse(center.x, center.y, 35, 35);
  }
  
  boolean isPassingPolygon(PVector point) {
    int i, j;
    boolean passing = false;
   
     for (i = 0, j = complexity-1; i < complexity; j = i++) {
       if ( ((endpoints[i].y>point.y) != (endpoints[j].y>point.y)) &&
        (point.x < (endpoints[j].x-endpoints[i].x) * (point.y-endpoints[i].y) / (endpoints[j].y-endpoints[i].y) + endpoints[i].x) )
          passing = !passing;
     }
     return passing; 
  }
  
}
