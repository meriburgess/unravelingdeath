Kinect2 kinect2;
PImage depthImg;

Meri meri;

StaticLines stLines;
int stLineCt = 50;
float lineShiftMax = 1.5;

// Framing variables
float leftSideThres = 80; // Bungalow: 80
float rightSideThres = 50; // Bungalow: 50
float topThres = 50; // Bungalow: 50
float btmThres = 70; // Bungalow: 70
float yScale = 2.0;
float xScale = 2.0;
color thresColorHSB = color(235, 0, 50); 
//color thresColorRGB = color(235, 235, 235); 
color thresColorRGB = color(0, 0, 0, 0); 
color bgKinectColorRGB = color(255, 255, 255, 100); 
//color bgKinectColorRGB = color(255, 255, 255); 
color bgKinectColorHSB = color(359, 0, 100, 0);
int pixelCountValidThres = 5000;

boolean drawSil;
boolean flip = false;
boolean mirror = false;
boolean freeze = false; //node freeze

// Kinect spacers
int segCt = 1; // Bungalow: 1
float segThresStart = 500; // Bungalow: 500
float segThresIncr = 2680; // Bungalow: 2680
Segment[] segs = new Segment[segCt];
int activeSegment;

// Neuron/node stuff
float overlayAlpha = 100;
float agentOverlayAlpha = 5;
float topAgentsAlpha = 80;
float midAgentsAlpha = 50;
float btmAgentsAlpha = 10;

int topNodeCt = 100;
Node[] topNodes = new Node[topNodeCt];
int midNodeCt = 100;
Node[] midNodes = new Node[midNodeCt];
int btmNodeCt = 50;
Node[] btmNodes = new Node[btmNodeCt];
int clusterCt = 0;
Cluster[] clusters = new Cluster[clusterCt];
int dripCt = 150;
DripNode[] drips = new DripNode[dripCt];

// Nueron/node color and speed controls
color bgNodeColor;
int brainBgBrightness;

float saturationLevel;
float brightnessLevel;
float speedModulator;

// Probably not useful anymore
float[] segThres = new float[segCt*2];
color[] segCols  = { 
  color(0, 0, 0, 100), 

  color(255, 10, 10, 100),
  
  color(255, 175, 0), 
  color(255, 255, 0, 100), 
  color(0, 255, 0, 100),
  color(0, 255, 255, 100),
  color(0, 55, 255, 100),
  color(135, 0, 255, 100)
};

// Debugging 
boolean drawIndicators = false;
PVector indicatorCenter = new PVector(75, 150);
