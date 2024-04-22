import processing.video.*;

// LCDeeD - An LCD TV rendering simulation for Processing
// © Dan DeGeest 2024

// The LCDD/TV Screens 2 X 2 or single enlarged
LCDD lcds[];

// Visualizers
InnerDD innerDD; // Adapted from https://openprocessing.org/sketch/2174599
Hitodama hito; // Adapted from https://openprocessing.org/sketch/2183938
FireFlies flies; // Adapted from https://openprocessing.org/sketch/2198756
LodeFire fire; // Adapted from https://lodev.org/cgtutor/fire.html
Schiffman schiff; // Adapted from https://processing.org/examples/tree.html

// Serial COM
Serial sPort;

// Slides
HashMap<String, ArrayList<Slide>> slides;
// Lyrics
ArrayList<String[]> lyrics = new ArrayList<>();
String[] lyric;
int line = 0;
int word = 0;
int lyricFade;
PFont[] lyricFonts;
int lyricFont = 2;
float lyricSize = 174;

//Movies
Movie movie;
int movieNumber = 0;
ArrayList<String> movieTitles = new ArrayList<>();

//Video
Capture video;

//Effigy
boolean effigyOn = false;

// Colors
color reDD = color(222, 0, 0);
color greenDD = color(0, 222, 0);
color blueDD = color(0, 0, 222);
color whiteDD = color(222, 222, 222);
color black = color(0);
color yellowDD = color(222, 222, 0);
color purpleDD = color(30, 20, 60);
color pinkDD = color(255, 192, 203);
color pinkDD2 = color(255, 105, 180);
color neonDD = color(255, 105, 180);
color neonDD2 = color(255, 20, 147);

color[] palette = new color[]{
  reDD, greenDD, blueDD, whiteDD,
  black, yellowDD, purpleDD, pinkDD,
  pinkDD2, neonDD, neonDD2,
  //Chillwave
  #F45D01, #FAA028, #FFD464, #FFF3AC,
  #5A6E69, #849FAA, #BDD3E6, #EFF7FB,
  #C1D0D9, #96B5C9, #6A97B9, #4679A9,
  #F45D01, #FAA028, #FFD464, #FFF3AC,
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

color bgColor = black;
color slideTint = neonDD2;
color lyricColor = neonDD;

// Compositing Buffer
PGraphics backBuffer;

// Playback options
boolean inDDon = false;
boolean backgroundOn = false;
boolean fireOn = false;
boolean hitoOn = false;
boolean videoOn = false;
boolean debugOn = false;
boolean lyricsOn = false;
boolean schiffOn = false;

// Puzzle
boolean earthPuzzOn = false;
boolean windPuzzOn = false;
boolean firePuzzOn = false;
boolean waterPuzzOn = false;
boolean lovePuzzOn = true;
boolean autoOn = false;

//Active TV Input
int input = 0;

//Images
String slideGroup;
int slideNumber = 25;
int slideLayer = 0;
int slideBrighT = 40;
int lastPhase = 0;
PImage slide;
float slideX = 0;

// Timers
Timer slideTimer;
Timer fxTimer;
Timer zoomTimer;

void setSlideGroup(String group) {
  slideGroup = group;
  println("Slides", group, slideNumber);
  slideTimer.tfx.timeout();
}

PImage nextSlide(String group) {
  if (!slides.containsKey(group)) {
    return slide;
  }
    
  ArrayList<Slide> imgGroup = slides.get(group);
  //Free up memory
  if (slideNumber < imgGroup.size()) {
    Slide ps = imgGroup.get(slideNumber);
    ps.image = null;
    println("Closed", ps.filePath);
  }
  
  slideNumber++;
  if (slideNumber >= imgGroup.size())
    slideNumber = 0;  
  
  Slide slide = imgGroup.get(slideNumber);
  if (slide.image == null) {
    loadSlideImage(slide);
  }
  
  if (group == "Wiitch")
    slide.image.resize(0, max(200, (int)random(100, height)));
  
  slideX = random(width - slide.image.width);
  if (group == "Phases")
    lastPhase = slideNumber;
  return slide.image;
}

PImage loadSlideImage(Slide slide) {
  PImage pi = loadImage(slide.filePath);
  if (pi.width != width && pi.height != height) {
    if (pi.width > pi.height)
      pi.resize(width, 0);
    else
      pi.resize(0, height);
    println("Resized", slide.filePath, pi.width, pi.height);
  }
  slide.image = pi;
  return slide.image;
}

void loadSlides(String group) {
  ArrayList<Slide> slideInfo = new ArrayList<>();
  String imagePath = sketchPath("") + "images" + group + "/";
  for (String fn: loadImageFolder(imagePath)) {
    Slide s = new Slide();
    s.filePath = imagePath + fn;
    slideInfo.add(s);
  }
  
  slides.put(group, slideInfo);
  println("Loaded Slide Group", group, slides.get(group).size());
}

void loadMovies() {
  String moviePath = sketchPath("") + "videos" + "/";
  for (String fn: loadImageFolder(moviePath)) {
    movieTitles.add(moviePath + fn);
  }
  
  println("Loaded Movie Titles", movieTitles.size());
}

void lyricChange() {
  line++;
  if (line == lyrics.size()) line = 0;
  lyric = lyrics.get(line);
  word = 0;
}

String[] elements = new String[] {"Earth", "Wind", "Fire", "Water"};

void setup() {
  size(1280, 720);
  frameRate(30);
  fullScreen();
  
  lyrics.add(new String[] {"It's", "The Moon", "The", "Pink Moon", "And", "It's", "Rising"});
  lyrics.add(new String[] {"LOVE", "IS A", "Fortress", "of LIGHT", "COME", "INSIDE"});
  lyrics.add(new String[] {"Wiitch TiiT", "Lyndsay", "MAMA T", "AshTree", "The Kernel", "Benjii"});
  lyrics.add(elements);
  lyric = lyrics.get(0);
  
  lyricFonts = new PFont[3];
  lyricFonts[0] = createFont("fonts/tetris.ttf", 72, true);
  lyricFonts[1] = createFont("fonts/Roboto-Bold.ttf", 72, true);
  lyricFonts[2] = createFont("fonts/mocha.ttf", 72, true);

  slides = new HashMap<>();
  String[] show = new String[]{"Dev", "Fire", "Moon", "Phases", "Wiitch", "Puzzle"};
  for (String g: show)
    loadSlides(g);  
  slideGroup = show[3];
  slide = nextSlide(slideGroup);
  
  lcds = new LCDD[4];
  int logoH  = 300;
  lcds[0] = new LCDD(0, 0, width, height, 3);
  lcds[0].logo = loadImage(sketchPath("") + "imagesPuzzle/PinkMoonClueEarth.png");
  lcds[0].logo.resize(0, logoH);
  lcds[0].tvOn = true;
  lcds[0].scanInterval = 2;
  
  // Split screens
  lcds[1] = new LCDD(width/2, 0, width/2, height/2, 3);
  lcds[1].logo = loadImage(sketchPath("") + "imagesPuzzle/PinkMoonClueAir.png");
  lcds[1].logo.resize(0, logoH);
  lcds[1].scanInterval = 1.5;
  lcds[1].overScanColor = neonDD;
  lcds[1].overScanOn = true;
  lcds[1].overScanSize = 5;
  lcds[1].overScanInterval = 10;
  
  lcds[2] = new LCDD(0, height/2, width/2, height/2, 3);
  lcds[2].scanInterval = .5;
  lcds[2].overScanColor = whiteDD;
  lcds[2].overScanOn = true;
  lcds[2].overScanSize = 15;
  lcds[2].overScanInterval = 40;
  lcds[2].logo = loadImage(sketchPath("") + "imagesPuzzle/PinkMoonClueFire.png");
  lcds[2].logo.resize(0, logoH);

  lcds[3] = new LCDD(width/2, height/2, width/2, height/2, 3);
  lcds[3].overScanColor = greenDD;
  lcds[3].overScanOn = true;
  lcds[3].logo = loadImage(sketchPath("") + "imagesPuzzle/PinkMoonClueWater.png");
  lcds[3].logo.resize(0, logoH);

  // Compositing buffer
  backBuffer = createGraphics(width, height);

  loadMovies();
  
  hito = new Hitodama(width, height);
  flies = new FireFlies(width, height);
  fire = new LodeFire(width, height);
  innerDD = new InnerDD();
  schiff = new Schiffman(width, height);
  
  loadKeyboardEvents();
  loadTimerEvents();
  
  slideTimer = new Timer();
  slideTimer.interval = 60 * 1000;
  slideTimer.tfx = () -> {
    if (movie == null && video == null) {
      slide = nextSlide(slideGroup);
    }
  };
  
  fxTimer = new Timer();
  fxTimer.interval = 30 * 1000;
  fxTimer.tfx = () -> {
    if (!autoOn || effigyOn) return;
    int pInput = input;
    input = 0;
    fx.get(floor(random(fx.size()))).fire();
    input = pInput;
  };
  
  zoomTimer = new Timer();
  zoomTimer.interval = 15 * 1000;
  zoomTimer.tfx = () -> {
    if (!autoOn || effigyOn) return;
    int pInput = input;
    input = 0;
    zoom.get(floor(random(zoom.size()))).fire();
    input = pInput;
  };
  
  initSerial("COM5");
}

void movieEvent(Movie m) {
  if (movie.isPlaying())
    m.read();
}

void captureEvent(Capture c) {
  c.read();
}

// LCDDRAW
void draw() { 
  timer(slideTimer);
  timer(fxTimer);
  timer(zoomTimer);
    
  backBuffer.beginDraw();
 
  if (backgroundOn) {
    backBuffer.background(bgColor); 
  }

  if (slideLayer == 1) {
    if (slideTint != whiteDD) {
      backBuffer.tint(slideTint);
    }
    
    if (video != null && video.isCapturing()) {
      backBuffer.image(video, 0, 0, backBuffer.width, backBuffer.height);
    }
    else if (movie != null  && movie.isPlaying())
      backBuffer.image(movie, 0, 0, backBuffer.width, backBuffer.height);
    else
      backBuffer.image(slide, slideX, 0);
  }
  
  if (lyricsOn) {
    backBuffer.push();
    backBuffer.noStroke();
    if ((lyricFade+=10) <= 260) {
      backBuffer.fill(bgColor, 10);
      backBuffer.rect(0, height/2-lyricSize/2, width, lyricSize, lyricSize/4);
    }
    backBuffer.textAlign(CENTER, CENTER);
    backBuffer.textFont(lyricFonts[lyricFont]);
    backBuffer.textSize(lyricSize);
    backBuffer.fill(lyricColor, 255);
    backBuffer.text(lyric[word], 0, 0, width, height);
    backBuffer.pop();
  }

  if (hitoOn) {
    hito.display(backBuffer);
  }

  if (schiffOn) {
    schiff.display(backBuffer);
  }
  
  if (fireOn)
    fire.display(backBuffer);
  
  if (flies.fliesOn || flies.grassOn) {
    //g.background(neon2);
    flies.display(backBuffer);
  }
  
  if (inDDon) {
    innerDD.display(backBuffer);
  }
  backBuffer.endDraw();
  
  PImage bImage = backBuffer.get();
  int offCnt = 0;
  for (int i = lcds.length - 1; i >= 0; i--) {
    if (lcds[i].tvOn) {
      bImage.resize(0, lcds[i].phRes);
      
      //Overlay
      if (slideLayer == 2) {
        PImage overlay = null;
        if (video != null && video.isCapturing()) {
          //video.read();
          overlay = video.get();
        }
        else if (movie != null) {
          overlay = movie.get();
        }
        else overlay = slide.copy();
        if (overlay != null) {
          overlay.resize(0, lcds[i].phRes);
          for (int yy = 0; yy < overlay.height; yy++)
            for (int xx = 0; xx < overlay.width; xx++) {
              int pc = overlay.get(xx, yy);
              if (alpha(pc) != 0 && brightness(pc) > slideBrighT)
                bImage.set(xx, yy, overlay.get(xx, yy));
            }
        }
      }
      lcds[i].sourceImage(bImage, 0);      
      lcds[i].display();
    }
    else offCnt++;
  }
  
  if (offCnt == 4) image(bImage, 0, 0);
  bImage = null; 
  
  drawOSD();
}

void keyPressed() {
  if (key == CODED) handleCoded();
  
  if (keyEvents.containsKey(key)) {
    keyEvents.get(key).fire();
  }  

  fire.keyPressed();  
}

void handleCoded() {
  if (keyCode == LEFT) transLeft.fire();
  if (keyCode == RIGHT) transRight.fire();
  if (keyCode == UP) transUp.fire();
  if (keyCode == DOWN) transDown.fire();
}

void mousePressed() {
  schiff.setLevel(min(mouseX, width/2));
}

void drawOSD() {
  if (debugOn) {
    int indY = 20;
    int indW = 60;
    int indH = 10;

    push();
    noStroke();
    fill(0, 20);
    rect(0, 0, indW, 20);
    rect(0, indY, indW, 200);  
    textAlign(LEFT, TOP);
    fill(128, 255, 128);
    textSize(12);
    text(nf(frameRate, 0, 2), 0, 0, 200, 50);

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
    text("S:" + slideLayer + " B:" + slideBrighT, 0, indY, indW, indH);
    
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
    if (flies.fliesOn) {    
      fill(whiteDD);
      rect(0, indY, indW, indH);
      fill(black);
      text("Flies", 0, indY, indW, indH);
    }
    indY+=indH;
    if (flies.grassOn) {    
      fill(whiteDD);
      rect(0, indY, indW, indH);
      fill(black);
      text("Grass", 0, indY, indW, indH);
    }
    indY+=indH;
    if (hitoOn) {    
      fill(whiteDD);
      rect(0, indY, indW, indH);
      fill(black);
      text("Hito", 0, indY, indW, indH);
    }
    indY+=indH;
    if (inDDon) {    
      fill(whiteDD);
      rect(0, indY, indW, indH);
      fill(black);
      text("InnDD:" + innerDDieMode + ":" + connected, 0, indY, indW, indH);
    }
    indY+=indH;
    if (schiffOn) {    
      fill(whiteDD);
      rect(0, indY, indW, indH);
      fill(black);
      text("Schiff :" + schiff.tLevel, 0, indY, indW, indH);
    }
    indY+=indH;
    if (fireOn) {    
      fill(whiteDD);
      rect(0, indY, indW, indH);
      fill(black);
      text("Fire", 0, indY, indW, indH);
    }
    
    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);
    text(slideGroup + ":" + nf(slideNumber), 0, indY, indW, indH);

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
    fill(black);
    text(lyric[word] + ":" + line + ":" + word, 0, indY, indW, indH);
    
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
    
    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);
    text(earthPuzzOn ? "EARTH" : "", 0, indY, indW, indH);

    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);
    text(windPuzzOn ? "WIND" : "", 0, indY, indW, indH);

        indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);
    text(firePuzzOn ? "FIRE" : "", 0, indY, indW, indH);

    indY+=indH;
    fill(whiteDD);
    rect(0, indY, indW, indH);
    fill(black);
    text(waterPuzzOn ? "WATER" : "", 0, indY, indW, indH);

    pop();
  }
}

void initSerial(String portName) {
  printArray(Serial.list());
  int comPort = -1;
  String[] ports = Serial.list();
  for (int i = 0; i < ports.length; i++) {
    if (ports[i].equals(portName)) {
      comPort = i;
      break; // If found, exit the loop
    }
  }
  
  if (comPort > 0) {
    println("OpenCOMPort:", Serial.list()[comPort]);
    sPort = new Serial(this, Serial.list()[comPort], 9600);
  }
}

int sCount = 0;
void serialEvent(Serial port) {
  //Read from port
  String inString = port.readStringUntil('\n');
  if (inString != null) {
    inString = inString.trim();
    // Process the message
    String[] command = inString.split(":");
    switch(command[0]) {
      case "EARTH":
        earthPuzzOn = command[1].equals("ON");
        break;
      case "AIR":
        windPuzzOn = command[1].equals("ON");
        break;
      case "FIRE":
        firePuzzOn = command[1].equals("ON");
        break;
      case "WATER":
        waterPuzzOn = command[1].equals("ON");
        break;
      case "PUZZLE":
        lovePuzzOn = command[1].equals("ON");
        break;
    }
    
    effigyUpdate();
  }
}
