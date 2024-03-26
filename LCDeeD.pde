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
ArrayList<String[]> lyrics = new ArrayList<>();
String[] lyric;

TimerFunction timerFn;

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

// Playback options
boolean inDDon = false;
boolean backgroundOn = false;
boolean fireOn = false;
boolean fliesOn = false;
boolean hitoOn = false;
boolean videoOn = false;
boolean slidesOn = true;
boolean fpsOn = true;
boolean lyricsOn = false;
boolean schiffOn = false;

//Active TV Input
int input = 0;

String slideGroup;
int slideNumber = 0;
PImage slide;
float slideX = 0;

void setSlideGroup(String group) {
  slideGroup = group;
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
  //fullScreen();
  
  lyrics.add(new String[] {"Love", "Fire", "Fortress", "Light", "Pink Moon"});
  lyrics.add(new String[] {"Lyndsay", "MAMA T", "AshTree", "The Colonel", "Benji"});
  lyric = lyrics.get(0);
  
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
  lcds[2] = new LCDD(0, height/2, width/2, height/2, 3);
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
}

int word = 0;
void draw() {  
  timer(timerFn);
  
  backBuffer.beginDraw();
 
  if (backgroundOn) {
    background(bgColor);
    backBuffer.background(bgColor); 
  }

  if (slidesOn) {
    backBuffer.tint(slideTint);
    backBuffer.image(slide, slideX, 0);
  }
  
  if (lyricsOn) {
    backBuffer.push();
    backBuffer.noStroke();
    backBuffer.fill(0, 10);
    backBuffer.rect(400, height/2 - 92, width-800, 144, 72);
    backBuffer.textAlign(CENTER, TOP);
    backBuffer.textSize(144);
    backBuffer.fill(255, 105, 180, 220);
    backBuffer.text(lyric[word], 0, height/2 - 88, width, 150);
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
  
  if (fliesOn) {
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
  
  if (fpsOn) {
    push();
    noStroke();
    fill(0, 20);
    rect(0, 0, 100, 24);
    int indY = 50;
    int indH = 10;
    rect(0, indY, 50, 200);
    
    textAlign(LEFT, TOP);
    fill(128, 255, 128);
    textSize(24);
    text("FPS:" + nf(frameRate, 0, 2), 0, 0, 200, 50);

    noFill();
    stroke(yellowDD);
    strokeWeight(10);
    line(0, indY, 40, indY);
    indY = 60;
    noStroke();
    fill(slideTint == black ? color(255, 20) : slideTint);
    rect(0, indY, 50, indH);
    indY = 70;
    
    if (backgroundOn) {
      fill(bgColor == black ? color(255, 20) : bgColor);
      rect(0, indY, 50, indH);
      indY+=indH;
    }
    if (slidesOn) {    
      fill(greenDD);
      rect(0, indY+=indH, 40, indH);
    }
    if (fliesOn) {    
      fill(whiteDD);
      rect(0, indY+=indH, 40, indH);
    }
    if (hitoOn) {    
      fill(blueDD);
      rect(0, indY+=indH, 40, indH);
    }
    if (inDDon) {    
      fill(pinkDD);
      rect(0, indY+=indH, 40, indH);
    }
    if (schiffOn) {    
      fill(neonDD);
      rect(0, indY+=indH, 40, indH);
    }
    if (fireOn) {    
      fill(palette[15]);
      rect(0, indY+=indH, 40, indH);
    }
    pop();
  }
}

void keyPressed() {
  if (key == BACKSPACE) {
    println("BACKSPACE", "Random Slide", "Reset", "Hatch");
    slide = nextSlide(slideGroup);
    innerDD.reset((int)random(10,200));
    flies.hatch(int(random(50, 200)));
  }
    
    if (key == '/' || key == '?') {
    lcds[input].overScanColor = palette[(int)random(palette.length)];
    if (key == '?') lcds[input].overScanColor = bgColor = black;
    println(key, "TINT");
  }
  
  if (key == 'b') {
    backgroundOn = !backgroundOn;
    for (int i = 0; i < lcds.length; i++)
      lcds[i].invalidate();
    println(key, "BACKGROUND", backgroundOn);
  }

  if (key == 'g') setSlideGroup("Dev");
  if (key == 'G') setSlideGroup("Moon");
  if (key == 'w') setSlideGroup("Wiitch");
  
  if (key == 'L') lcds[input].logoOn = !lcds[input].logoOn;
  
  if (key == 'm' || key == 'M') {
    setSlideGroup("Fire");
    fireOn = !fireOn;
    println(key, "FIRE", fireOn);
  }

  if (key == 'f') {
    fpsOn = !fpsOn;
    println(key, "FPS", fpsOn);
  }

  if (key == 'o') {
    setSlideGroup("Phases");
    fliesOn = !fliesOn;
    println(key, "FIREFLIES", fliesOn);
  }
  if (key == 'O') {
    flies.grassOn = !flies.grassOn;
  }
  
  if (key == 'h') {
    hitoOn = !hitoOn;
    println(key, "HITODAMA", hitoOn);
  }
  
  if (key == 'i') {
    inDDon = !inDDon;
    println(key, "INNERDDEMON", inDDon);
  }

  if (key == 'p') {
    schiffOn = !schiffOn;
    println(key, "SCHIFFON", schiffOn);
  }

  if (key == 's') {
    slidesOn = !slidesOn;
    println(key, "SLIDES", slidesOn);
  }

  if (key == '.') {
    lcds[input].overScanOn = !lcds[input].overScanOn;
    println(key, "Overscan", input, lcds[input].overScanOn);
  }

  if (key == 'e') {println(key, "DIEMODE:1"); dieMode = 1;}
  if (key == 'r') {println(key, "DIEMODE:2"); dieMode = 2;}
    
  if (key == ENTER) {
    saveFrame("screenshots/LCDD#####.png");
    println("ENTER", "SAVE FRAME");
  }

  if (keyCode == LEFT) {
    lcds[input].transX -= lcds[input].scale * 10;
    println("TX", lcds[input].transX);
  }

  if (keyCode == RIGHT) {
    lcds[input].transX += lcds[input].scale * 10;
    println("TX", lcds[input].transX);
  }

  if (key == '<') {
    lcds[input].transY -= lcds[input].scale * 10;
    println("TY", lcds[input].transY);
  }

  if (key == '>') {
    lcds[input].transY += lcds[input].scale * 10;
    println("TY", lcds[input].transY);
  }
  
  if (keyCode == UP) {
    lcds[input].scale += .5;
    println("SCALE", lcds[input].scale);
  }

  if (keyCode == DOWN) {
    lcds[input].scale -= .5;
    println("SCALE", lcds[input].scale);
  }
  
  if (key >= '1' && key <= '4') {
    String f = "" + key;
    input = Integer.parseInt(f) - 1;
    println(key, "INPUT", input);
  }
  
  if (key >= '5' && key <= '7') {
    String f = "" + key;
    lcds[input].bright = Integer.parseInt(f) - 5;
    println(key, "BRIGHT", input, lcds[input].bright);
  }
  
  if (key == '8') {
    lcds[input].overScanInterval++;
    println(key, "OVERSCAN INT", input, lcds[input].overScanInterval);
  }

  if (key == '*') {
    lcds[input].overScanInterval = 2;
    println(key, "OVERSCAN INT", input, lcds[input].overScanInterval);
  }
  
  if (key == '9') {
    lcds[input].overScanSize++;
    println(key, "OVERSCAN SIZE", input, lcds[input].overScanSize);
  }

  if (key == '(') {
    lcds[input].overScanSize = 2;
    println(key, "OVERSCAN SIZE", input, lcds[input].overScanSize);
  }

  if (key == '=') {
    lcds[input].scale = 1.0;
    println("SCALE", input, lcds[input].scale);
  }

  if (key == '+') {
    lcds[input].transX = lcds[input].transY = 0.0;
    println(key, "TRANS", input, "0,0");
  }

  if (key == 'j') {
    word++;
    if (word >= lyric.length) word = 0;
  }

  if (key == 'k') {
    lyricsOn = !lyricsOn;
    println(key, "LYRICS", lyricsOn);
  }
  
  if (key == 'K') {
    lyricChange();
    println(key, "Lyric Change");
  }
  
  if (key == 'c') {
    subPixelDisclination++;
    if (subPixelDisclination > 2)
      subPixelDisclination = 0;
    
    println("PSD", 1 << subPixelDisclination);
  }
  
  if (key == 'n') {
    connected = !connected;
    println(key, "INNERCONNECTED", connected);
  }

  if (key == 't') {
    for (int i = 0; i < lcds.length; i++)
      lcds[i].pipOn = !lcds[i].pipOn;
    println(key, "PIP", lcds[input].pipOn);
  }
  
  if (key == '!') {
    lcds[0].tvOn = !lcds[0].tvOn;
    println(key, "TV/ON 0", lcds[input].tvOn);
  }
  if (key == '@') {
    lcds[1].tvOn = !lcds[1].tvOn;
    println(key, "TV/ON 1", lcds[input].tvOn);
  }
  if (key == '#') {
    lcds[2].tvOn = !lcds[2].tvOn;
    println(key, "TV/ON 2", lcds[input].tvOn);
  }
  if (key == '$') {
    lcds[3].tvOn = !lcds[3].tvOn;
    println(key, "TV/ON 3", lcds[input].tvOn);
  }

  if (key == '-') {
    if (lcds[input]._width == width) {
      lcds[0].setResolution(width/2, height/2, 3);
      for (int i = 1; i < lcds.length; i++)
        lcds[i].tvOn = true;
      println(key, "SPLIT/OFF");
    }
    else {
      lcds[0].setResolution(width, height, 3);
      for (int i = 1; i < lcds.length; i++)
        lcds[i].tvOn = false;
      println(key, "SPLIT/OFF");
    }
  }
  
  if (key == 'a' || key == 'A') {
    slideTint = palette[(int)random(palette.length)];
    if (key == 'A') bgColor = slideTint; else bgColor = black;
    println(key, "TINT");
  }
  
  fire.keyPressed();  
}

void lyricChange() {
  lyric = lyrics.get((int)random(lyrics.size()));
  word = 0;
}
