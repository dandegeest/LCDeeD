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

// Slides
HashMap<String, ArrayList<Slide>> slides;
// Lyrics
ArrayList<String[]> lyrics = new ArrayList<>();
String[] lyric;
int word = 0;
int lyricFade;

TimerFunction timerFn;

// Events
HashMap<Character, VisEvent> visEvents = new HashMap();

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
color slideTint = whiteDD;

// Compositing Buffer
PGraphics backBuffer;

// Fonts
PFont roboto;
PFont robotoCB;
PFont tetris;

// Playback options
boolean inDDon = false;
boolean backgroundOn = false;
boolean fireOn = false;
boolean hitoOn = false;
boolean videoOn = false;
boolean slidesOn = true;
boolean debugOn = false;
boolean lyricsOn = false;
boolean schiffOn = false;

//Active TV Input
int input = 0;

//Images
String slideGroup;
int slideNumber = 0;
int lastPhase = 0;
PImage slide;
float slideX = 0;

void setSlideGroup(String group) {
  slideGroup = group;
  println("Slides", group);
  timerFn.timeout();
}

PImage nextSlide(String group) {
  if (!slides.containsKey(group))
    return slide;
    
  ArrayList<Slide> imgGroup = slides.get(group);
  if (slideNumber >= imgGroup.size())
    slideNumber = 0;  
  
  Slide slide = imgGroup.get(slideNumber);
  if (slide.image == null) {
    loadSlideImage(slide);
  }
  
  slideX = random(width - slide.image.width);
  slideNumber++;
  if (group == "Phases")
    lastPhase = slideNumber;
  return slide.image;
}

PImage randomSlide(String group) {
  if (!slides.containsKey(group))
    return slide;
    
  ArrayList<Slide> imgGroup = slides.get(group);
  Slide s = imgGroup.get((int)random(imgGroup.size()-1));
  println(s, s.image, s.filePath);
  if (s.image == null) {
    loadSlideImage(s);
  }
  slideX = random(width - s.image.width);
  return s.image;
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
  String imagePath = sketchPath("") + "images" + group + "\\";
  for (String fn: loadImageFolder(imagePath)) {
    Slide s = new Slide();
    s.filePath = imagePath + fn;
    slideInfo.add(s);
  }
  
  slides.put(group, slideInfo);
  println("Loaded Slide Group", group, slides.get(group).size());
}

void setup() {
  size(1280, 720);
  frameRate(60);
  //1fullScreen();
  
  lyrics.add(new String[] {"Love", "Fire", "Fortress", "Light", "Pink Moon"});
  lyrics.add(new String[] {"Wiitch TiiT", "Lyndsay", "MAMA T", "AshTree", "The Colonel", "Benji"});
  lyrics.add(new String[] {"It's the Moon", "The Pink Moon", "And It's", "Rising"});
  lyric = lyrics.get(0);
  
  tetris = createFont("fonts\\tetris.ttf", 18, true);
  roboto = createFont("fonts\\Roboto-Bold.ttf", 16, true);
  robotoCB = createFont("fonts\\RobotoCondensed-Bold.ttf", 16, true);

  slides = new HashMap<>();
  String[] show = new String[]{"Fire", "Moon", "Dev", "Phases", "Wiitch"};
  for (String g: show)
    loadSlides(g);  
  slideGroup = "Dev";
  slide = randomSlide(slideGroup);
  
  lcds = new LCDD[4];
  lcds[0] = new LCDD(0, 0, width, height, 3);
  lcds[0].logo = loadImage(sketchPath("") + "imagesWiitch\\wiitch_logo2.png");
  lcds[0].logo.resize(0, 100);
  lcds[0].tvOn = true;
  // Split screens
  lcds[1] = new LCDD(width/2, 0, width/2, height/2, 3);
  lcds[1].scanInterval = 2;
  lcds[2] = new LCDD(0, height/2, width/2, height/2, 3);
  lcds[2].scanInterval = .5;
  lcds[3] = new LCDD(width/2, height/2, width/2, height/2, 3);
  
  backBuffer = createGraphics(width, height);
  
  hito = new Hitodama(width, height);
  flies = new FireFlies(width, height);
  fire = new LodeFire(width, height);
  innerDD = new InnerDD();
  schiff = new Schiffman(width, height);

  timerFn = () -> {
    if (slidesOn) {
      slide = nextSlide(slideGroup);
    }
  };
  
  loadEvents();
}

void loadEvents() {
  // BACK BUFFER
  visEvents.put('b', toggleBackground);
  visEvents.put('B', backgroundColorReset);
  visEvents.put('a', randomTint);
  visEvents.put('A', backgroundTint);
  visEvents.put('c', pixelMode);
  
  // LYRICS
  visEvents.put('j', nextLyric);
  visEvents.put('k', toggleLyrics);
  visEvents.put('K', lyricsChange);

  // VISUALIZERS
  visEvents.put('f', toggleFire);
  visEvents.put('h', toggleHito);
  visEvents.put('i', toggleInnerDD);
  visEvents.put('I', innerConnect);
  visEvents.put('e', innerDDieMode1);
  visEvents.put('E', innerDDieMode2);
  visEvents.put('o', toggleFlies);
  visEvents.put('O', toggleGrass);
  visEvents.put('p', toggleSchiff);
  visEvents.put('s', toggleSlides);
  
  // TV CONTROLS
  //    ON/OFF
  visEvents.put('1', selectTV_0);
  visEvents.put('2', selectTV_1);
  visEvents.put('3', selectTV_2);
  visEvents.put('4', selectTV_3);
  //    SELECT INPUT
  visEvents.put(TAB, splitScreen);
  visEvents.put('T', togglePIP);
  //    SELECT INPUT
  visEvents.put('!', toggleTV_0);
  visEvents.put('@', toggleTV_1);
  visEvents.put('#', toggleTV_2);
  visEvents.put('$', toggleTV_3);
  //    INPUT OPTIONS
  //          OVERSCAN
  visEvents.put('M', overScanToggle);
  visEvents.put('/', overScanColor);
  visEvents.put('?', overScanColorReset); 
  visEvents.put('<', overScanWidth); 
  visEvents.put('>', overScanInterval); 
  visEvents.put('.', overScanWidthReset); 
  visEvents.put(',', overScanIntervalReset); 
  //          SCALING
  visEvents.put('-', scaleDown);
  visEvents.put('=', scaleUp);
  visEvents.put('+', scaleReset);
  visEvents.put('_', transReset);
  //          BRIGTHNESS
  visEvents.put('7', briteMode0);
  visEvents.put('8', briteMode1);
  visEvents.put('9', briteMode2);
  //          BRIGTHNESS
  visEvents.put('L', toggleLogo);  
  
  // RESETS
  visEvents.put('0', resetAll);
  visEvents.put(BACKSPACE, resetVis);
  
  // SLIDES
  visEvents.put('g', slidesDev);
  visEvents.put('w', slidesWiitch);
  visEvents.put('W', slidesMoon);

  // TOOLS
  visEvents.put('D', toggleDebug);
  visEvents.put(ENTER, saveFrame);
}

void draw() {  
  timer(timerFn);
  
  backBuffer.beginDraw();
 
  if (backgroundOn) {
    backBuffer.background(bgColor); 
  }

  if (slidesOn) {
    backBuffer.tint(slideTint);
    backBuffer.image(slide, slideX, 0);
  }
  
  if (lyricsOn) {
    backBuffer.push();
    backBuffer.noStroke();
    if ((lyricFade+=10) <= 260) {
      backBuffer.fill(bgColor, 10);
      backBuffer.rect(100, height/2-90, width-200, 180, 45);
    }
    backBuffer.textAlign(CENTER, CENTER);
    backBuffer.textFont(tetris);
    backBuffer.textSize(174);
    backBuffer.fill(lerpColor(slideTint, yellowDD, .25), 240);
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
      lcds[i].sourceImage(bImage);
      lcds[i].display();
    }
    else offCnt++;
  }
  
  if (offCnt == 4) image(bImage, 0, 0);
  bImage = null; 
  
  drawDebug();
}

void keyPressed() {
  if (key == CODED) handleCoded();
  
  if (visEvents.containsKey(key)) {
    visEvents.get(key).fire();
  }
    
  fire.keyPressed();  
}

void lyricChange() {
  lyric = lyrics.get((int)random(lyrics.size()));
  word = 0;
}

VisEvent toggleHito = () -> {
  hitoOn = !hitoOn;
  println("HITODAMA", hitoOn);
};

VisEvent toggleFlies = () -> {
  flies.fliesOn = !flies.fliesOn;
  if (flies.fliesOn) {
    slideNumber = lastPhase;
    setSlideGroup("Phases");
  }
  println("FireFlies", flies.fliesOn);
};

VisEvent toggleGrass = () -> {
  flies.grassOn = !flies.grassOn;
  println("Grass", flies.grassOn);
};

VisEvent toggleInnerDD = () -> {
  inDDon = !inDDon;
  println("INNERDDEMON", inDDon);
};

VisEvent toggleFire = () -> {
  fireOn = !fireOn;
  if (fireOn)
    setSlideGroup("Fire");
  println("FIRE", fireOn);
};

VisEvent toggleSchiff = () -> {
  schiffOn = !schiffOn;
  println("SCHIFFON", schiffOn);
};

VisEvent toggleSlides = () -> {
  slidesOn = !slidesOn;
  println("SLIDES", slidesOn);
};

VisEvent innerConnect = () -> {
  connected = !connected;
  println(key, "INNERCONNECTED", connected);
};

VisEvent resetVis = () -> {
  slide = nextSlide(slideGroup);
  if (inDDon)
    innerDD.spawn((int)random(10,200));
  if (flies.fliesOn)
    flies.hatch(int(random(50, 200)));
  println("Next Slide in " + slideGroup, "Spawn InnerDD", "Hatch Flies");
};

VisEvent toggleDebug = () -> {
  debugOn = !debugOn;
  println("FPS", debugOn);
};

VisEvent toggleBackground = () -> {
  backgroundOn = !backgroundOn;
  for (int i = 0; i < lcds.length; i++)
    lcds[i].invalidate();
  println("BACKGROUND", backgroundOn);
};

VisEvent backgroundColorReset = () -> {
  bgColor = black;
  println("BACKGROUND RESET", red(bgColor), green(bgColor), blue(bgColor));
};

VisEvent randomTint = () -> {
  slideTint = palette[(int)random(palette.length)];
  println("TINT", red(slideTint), green(slideTint), blue(slideTint));
}; 

VisEvent backgroundTint = () -> {
  bgColor = slideTint;
  println("BACKGROUND RESET", red(bgColor), green(bgColor), blue(bgColor));
};

VisEvent resetAll = () -> {
  for (int i = 0; i < 4; i++) {
    lcds[i].scale = 1.0;
    lcds[i].transX = 0.0;
    lcds[i].transY = 0.0;
  }
  println("RESET");
};

VisEvent saveFrame = () -> {
  String frameName = "screenshots/LCDD#####.png";
  saveFrame(frameName);
  println("SAVE FRAME", frameName);
};

VisEvent transLeft = () -> {
  lcds[input].transX -= lcds[input].scale * 10;
  println("TransX", lcds[input].transX);
};

VisEvent transRight = () -> {
  lcds[input].transX += lcds[input].scale * 10;
  println("TransX", lcds[input].transX);
};

VisEvent transUp = () -> {
  lcds[input].transY -= lcds[input].scale * 10;
  println("TY", lcds[input].transY);
};

VisEvent transDown = () -> {
  lcds[input].transY += lcds[input].scale * 10;
  println("TY", lcds[input].transY);
};

VisEvent scaleUp = () -> {
  lcds[input].scale += .5;
  println("SCALE TV", input, lcds[input].scale);
};

VisEvent scaleDown = () -> {
  lcds[input].scale -= .5;
  println("SCALE TV", input, lcds[input].scale);
};

VisEvent toggleLyrics = () -> {
  lyricsOn = !lyricsOn;
  println("LYRICS", lyricsOn);
};

VisEvent lyricsChange = () -> {
  lyricChange();
  println("Lyric Change");
  printArray(lyric);
};

VisEvent nextLyric = () -> {
  word++;
  if (word >= lyric.length) word = 0;
  lyricFade = 0;
  println("Next Lyric->" + lyric[word]);
};

void toggleTV(int tv) {
  lcds[tv].tvOn = !lcds[tv].tvOn;
  println(key, "TV/ON" + tv, lcds[tv].tvOn);
}

VisEvent toggleTV_0 = () -> {
  toggleTV(0);
};

VisEvent toggleTV_1 = () -> {
  toggleTV(1);
};

VisEvent toggleTV_2 = () -> {
  toggleTV(2);
};

VisEvent toggleTV_3 = () -> {
  toggleTV(3);
};

void selectInput(int tv) {
  input = tv;
  println("SELECT INPUT", input);
}

VisEvent selectTV_0 = () -> {
  selectInput(0);
};

VisEvent selectTV_1 = () -> {
  selectInput(1);
};

VisEvent selectTV_2 = () -> {
  selectInput(2);
};

VisEvent selectTV_3 = () -> {
  selectInput(3);
};

VisEvent overScanColor = () -> {
  color c = palette[(int)random(palette.length)];
  lcds[input].overScanColor = c;
  println("Overscan Color TV " + input, red(c), green(c), blue(c));
};

VisEvent overScanColorReset = () -> {
  lcds[input].overScanColor = black;
  println("Overscan Color Reset TV " + input);
};

VisEvent overScanWidth = () -> {
  lcds[input].overScanSize++;
  println("OVERSCAN WIDTH " + input, lcds[input].overScanSize);
};

VisEvent overScanWidthReset = () -> {
  lcds[input].overScanSize = 2;
  println("OVERSCAN WIDTH " + input, lcds[input].overScanSize);
};

VisEvent overScanInterval = () -> {
  lcds[input].overScanInterval++;
  println("OVERSCAN INTERVAL " + input, lcds[input].overScanInterval);
};

VisEvent overScanIntervalReset = () -> {
  lcds[input].overScanInterval = 3;
  println("OVERSCAN INTERVAL " + input, lcds[input].overScanInterval);
};

VisEvent overScanToggle = () -> {
  lcds[input].overScanOn = !lcds[input].overScanOn;
  println("Overscan TV", input, lcds[input].overScanOn);
};

VisEvent pixelMode = () -> {    
  subPixelDisclination++;
  if (subPixelDisclination > 2)
    subPixelDisclination = 0;
  
  println("Pixel Mode", 1 << subPixelDisclination);
};

VisEvent scaleReset = () -> { 
  lcds[input].scale = 1.0;
  println("SCALE RESET TV", input, lcds[input].scale);
};

VisEvent transReset = () -> { 
  lcds[input].transX = 0.0;
  lcds[input].transY = 0.0;
  println(key, "TRANS RESET TV", input, "(0,0)");
};

VisEvent splitScreen = () -> {
  if (lcds[0]._width == width) {
    lcds[0].setResolution(width/2, height/2, 3);
    for (int i = 0; i < lcds.length; i++)
      lcds[i].tvOn = true;
    println(key, "SPLIT/ON");
  }
  else {
    lcds[0].setResolution(width, height, 3);
    for (int i = 1; i < lcds.length; i++)
      lcds[i].tvOn = false;
    println(key, "SPLIT/OFF");
  }
};
  
VisEvent briteMode0 = () -> {
  lcds[input].bright = 0;
  println("BRIGHT", input, lcds[input].bright);
};

VisEvent briteMode1 = () -> {
  lcds[input].bright = 1;
  println("BRIGHT", input, lcds[input].bright);
};

VisEvent briteMode2 = () -> {
  lcds[input].bright = 2;
  println("BRIGHT", input, lcds[input].bright);
};

VisEvent togglePIP = () -> {
  for (int i = 0; i < lcds.length; i++)
    lcds[i].pipOn = !lcds[i].pipOn;
  println("PIP", lcds[0].pipOn);
};

VisEvent toggleLogo = () -> { 
  lcds[input].logoOn = !lcds[input].logoOn;
  println("LOGO", input, lcds[input].logoOn);
};

VisEvent slidesDev = () -> {   
  setSlideGroup("Dev");
};

VisEvent slidesWiitch = () -> {   
  setSlideGroup("Wiitch");
};

VisEvent slidesMoon = () -> {   
  setSlideGroup("Moon");
};

VisEvent innerDDieMode1 = () -> {   
  innerDDieMode = 1;
  println("INNERDDie", innerDDieMode);
};

VisEvent innerDDieMode2 = () -> {   
  innerDDieMode = 2;
  println("INNERDDie", innerDDieMode);
};

void handleCoded() {
  if (keyCode == LEFT) transLeft.fire();
  if (keyCode == RIGHT) transRight.fire();
  if (keyCode == UP) transUp.fire();
  if (keyCode == DOWN) transDown.fire();
}

void drawDebug() {
  if (debugOn) {
    int indY = 20;
    int indW = 50;
    int indH = 10;

    push();
    noStroke();
    fill(0, 20);
    rect(0, 0, indW, 20);
    rect(0, indY, 50, 150);  
    textAlign(LEFT, TOP);
    fill(128, 255, 128);
    textSize(12);
    text(nf(frameRate, 0, 2), 0, 0, 200, 50);

    textAlign(LEFT, CENTER);
    noFill();
    stroke(yellowDD);
    strokeWeight(10);
    line(0, indY, 40, indY);
    indY+=indH;
    noStroke();
    fill(slideTint == black ? color(255, 20) : slideTint);
    rect(0, indY, 50, indH);
    indY+=indH;   
    textSize(10);
    fill(bgColor);
    rect(0, indY, 50, indH);
    fill(bgColor == black ? whiteDD : black);
    text("BG " + backgroundOn, 0, indY, 50, indH);
    indY+=indH;

    if (slidesOn) {    
      fill(whiteDD);
      rect(0, indY, 50, indH);
      fill(black);
      text("Slides", 0, indY, 50, indH);
    }
    indY+=indH;
    if (flies.fliesOn) {    
      fill(whiteDD);
      rect(0, indY, 50, indH);
      fill(black);
      text("Flies", 0, indY, 50, indH);
    }
    indY+=indH;
    if (flies.grassOn) {    
      fill(whiteDD);
      rect(0, indY, 50, indH);
      fill(black);
      text("Grass", 0, indY, 50, indH);
    }
    indY+=indH;
    if (hitoOn) {    
      fill(whiteDD);
      rect(0, indY, 50, indH);
      fill(black);
      text("Hito", 0, indY, 50, indH);
    }
    indY+=indH;
    if (inDDon) {    
      fill(whiteDD);
      rect(0, indY, 50, indH);
      fill(black);
      text("InnerDD", 0, indY, 50, indH);
    }
    indY+=indH;
    if (schiffOn) {    
      fill(whiteDD);
      rect(0, indY, 50, indH);
      fill(black);
      text("Schiff", 0, indY, 50, indH);
    }
    indY+=indH;
    if (fireOn) {    
      fill(whiteDD);
      rect(0, indY, 50, indH);
      fill(black);
      text("Fire", 0, indY, 50, indH);
    }
    pop();
  }
}
