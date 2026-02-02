// LCDeeD - An LCD TV rendering simulation for Processing
// © Dan DeGeest 2024

// The LCDD/TV Screens 2 X 2 or single enlarged
LCDD lcds[];

color[] palette = new color[]{
  //RetroTV
  #1c1c1c, // Dark Grey
  #6b6b6b, // Medium Grey
  #b1b1b1, // Light Grey
  #670000, // Dark Red
  #8a0707, // Red
  #b91313, // Light Red
  #e51919, // Bright Red
  #005915, // Dark Green
  #008721, // Green
  #0daf30, // Light Green
  #10e538, // Bright Green
  #000d99, // Dark Blue
  #0030ff, // Blue
  #4683ff, // Light Blue
  #6ba4ff  // Bright Blue
};
// Colors
color reDD = palette[6];
color greenDD = palette[9];
color blueDD = palette[13];
color whiteDD = palette[3];
color black = palette[0];
color yellowDD = color(222, 222, 0);
color purpleDD = color(30, 20, 60);
color pinkDD = color(255, 192, 203);
color pinkDD2 = color(255, 105, 180);
color neonDD = color(255, 105, 180);
color neonDD2 = color(255, 20, 147);

color bgColor = black;
color slideTint = neonDD2;

// Content rendering modes
final int CONTENT_OFF = 0;
final int CONTENT_BACKGROUND = 1;
final int CONTENT_OVERLAY = 2;

// Playback options
boolean backgroundOn = false;
boolean debugOn = false;

boolean autoOn = false;

//Active TV Input
int input = 0;

// Timers
Timer fxTimer;
Timer zoomTimer;

void setup() {
  size(1280, 720);
  frameRate(30);
  //Important for pixel accuracy in LCDD rendering
  pixelDensity(1);
  //fullScreen();
  
  lcds = new LCDD[4];
  lcds[0] = new LCDD(0, 0, width, height, 1.5);
  lcds[0].tvOn = true;
  lcds[0].scanInterval = 2;
  lcds[0].customVisualizer = new FireFliesVisualizer(0, 0, width, height);
  lcds[0].enableVisualizer();
  
  // Split screens
  lcds[1] = new LCDD(width/2, 0, width/2, height/2, 1.5);
  lcds[1].scanInterval = 1.5;
  lcds[1].overScanColor = neonDD;
  lcds[1].overScanOn = true;
  lcds[1].overScanSize = 5;
  lcds[1].overScanInterval = 10;
  lcds[1].customVisualizer = new ImageVisualizer(0, 0,  width/2, height/2, "JunkLCD.jpg");
  lcds[1].enableVisualizer();
  
  lcds[2] = new LCDD(0, height/2, width/2, height/2, 1.5);
  lcds[2].scanInterval = .5;
  lcds[2].overScanColor = whiteDD;
  lcds[2].overScanOn = true;
  lcds[2].overScanSize = 15;
  lcds[2].overScanInterval = 40;
  lcds[2].customVisualizer = new GridVisualizer(0, 0,  width/2, height/2);
  lcds[2].enableVisualizer();

  lcds[3] = new LCDD(width/2, height/2, width/2, height/2, 1.5);
  lcds[3].overScanColor = greenDD;
  lcds[3].overScanOn = true;
  lcds[3].customVisualizer = new PulseVisualizer(0, 0,  width/2, height/2);
  lcds[3].enableVisualizer();
  
  loadKeyboardEvents();
  loadTimerEvents();
  
  fxTimer = new Timer();
  fxTimer.interval = 30 * 1000;
  fxTimer.tfx = () -> {
    if (!autoOn) return;
    int pInput = input;
    input = 0;
    fx.get(floor(random(fx.size()))).fire();
    input = pInput;
  };
  
  zoomTimer = new Timer();
  zoomTimer.interval = 15 * 1000;
  zoomTimer.tfx = () -> {
    if (!autoOn) return;
    int pInput = input;
    input = 0;
    zoom.get(floor(random(zoom.size()))).fire();
    input = pInput;
  };
}

// LCDDRAW
void draw() { 
  timer(fxTimer);
  timer(zoomTimer);
    
  boolean anyTVOn = false;
  for (LCDD lcdd : lcds) {
    lcdd.update();
    if (lcdd.tvOn) {
      lcdd.display();
      anyTVOn = true;
    }
  }

  if (!anyTVOn) {
    int l = (int)random(lcds.length);
    image(lcds[l].backBuffer, lcds[l].position.x, lcds[l].position.y);
  }

  drawOSD();
}

void keyPressed() {
  if (key == CODED) handleCoded();
  
  if (keyEvents.containsKey(key)) {
    keyEvents.get(key).fire();
  }  
}

void handleCoded() {
  if (keyCode == LEFT) transLeft.fire();
  if (keyCode == RIGHT) transRight.fire();
  if (keyCode == UP) transUp.fire();
  if (keyCode == DOWN) transDown.fire();
}

void drawOSD() {
  if (debugOn) {
    int indY = 20;
    int indW = 60;
    int indH = 10;

    push();
    noStroke();
    fill(0, 255);
    rect(0, 0, indW, 20);
    rect(0, indY, indW, 200);  
    textAlign(LEFT, TOP);
    fill(128, 255, 128);
    textSize(12);
    text(nf(frameRate, 2, 2), 0, 0, 200, 50);

    textAlign(LEFT, CENTER);
    noFill();
    stroke(reDD);
    strokeWeight(10);
    line(0, indY, 40, indY);
    indY+=indH;
    noStroke();
    fill(slideTint == black ? color(255, 20) : slideTint);
    rect(0, indY, indW, indH);
    indY+=indH;   
    textSize(10);
    fill(bgColor);
    rect(0, indY, indW, indH);
    fill(bgColor == black ? whiteDD : black);
    text("BG " + backgroundOn, 0, indY, indW, indH);
    indY+=indH;

    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);

    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);
    text("Z:" + nf(lcds[input].scale, 0, 2), 0, indY, indW, indH);

    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);
    text("X:" + nf(lcds[input].transX, 0, 2), 0, indY, indW, indH);
    
    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);
    text("Y:" + nf(lcds[input].transY, 0, 2), 0, indY, indW, indH);
    
    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);
    text("Input:" + input, 0, indY, indW, indH);
    
    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);
    text("DISC:" + (1 << subPixelDisclination), 0, indY, indW, indH);
    
    indY+=indH;   
    fill(whiteDD);
    rect(0, indY, indW, indH);
    for (int i = 0; i < 4; i++) {    
      if (lcds[i].overScanOn) {
        fill(lcds[i].overScanColor);
        rect(i * indW/4, indY, indW/4, indH);
      }
    }
    
    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    for (int i = 0; i < 4; i++) {    
      fill(black);
      text(nf(lcds[i].lumosMode), i * indW/4, indY, indW/4, indH);
    }

    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    for (int i = 0; i < 4; i++) {    
      fill(black);
      text(lcds[i].centerScale ? "|<>|" : "|__|", i * indW/4, indY, indW/4, indH);
    }

    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);
    text(autoOn ? "AUTO" : "OFF", 0, indY, indW, indH);

    pop();
  }
}