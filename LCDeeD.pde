// LCDeeD - An LCD TV rendering simulation for Processing
// © Dan DeGeest 2024

LCDD lcds[];

Capture video;

InnerDD innerDD;
Hitodama hito;
FireFlies flies;
LodeFire fire;
Schiffman schiff;

HashMap<String, ArrayList<PImage>> images;
ArrayList<String[]> lyrics = new ArrayList<>();
String[] lyric;

TimerFunction timerFn;

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
  reDD, greenDD, blueDD, whiteDD, black, yellowDD, purpleDD, pinkDD, pinkDD2, neonDD, neonDD2,
  #F45D01, #FAA028, #FFD464, #FFF3AC,
  #5A6E69, #849FAA, #BDD3E6, #EFF7FB,
  #C1D0D9, #96B5C9, #6A97B9, #4679A9,
  #F45D01, #FAA028, #FFD464, #FFF3AC
};

color bgColor = purpleDD;
color slideTint = whiteDD;

// Buffer
PGraphics backBuffer;

// Playback
boolean inDDon = false;
boolean backgroundOn = false;
boolean fireOn = false;
boolean fliesOn = false;
boolean hitoOn = false;
boolean videoOn = false;
boolean slidesOn = false;
boolean fpsOn = true;
boolean staticOn = false;
boolean lyricsOn = false;
boolean schiffOn = false;

String slideGroup;
PImage slide;
float slideX = 0;

PImage randomImage(String group) {
  if (!images.containsKey(group))
    return slide;
    
  ArrayList<PImage> imgGroup = images.get(group);
  PImage p = imgGroup.get((int)random(imgGroup.size()));
  slideX = random(width - p.width);
  return p;
}

void loadSlides(String group) {
  slideGroup = group;
  ArrayList<PImage> imgFiles = new ArrayList<>();
  String imagePath = sketchPath("") + "images" + group + "/";
  for (String fn: loadImageFolder(imagePath)) {
    PImage pi = loadImage(imagePath + fn);
    pi.resize(0, height);
    imgFiles.add(pi);
  }
  
  images.put(group, imgFiles);
}

void setup() {
  size(1280, 720);
  frameRate(60);
  fullScreen();
  
  lyrics.add(new String[] {"Love", "Fire", "Fortress", "Light", "Moon"});
  lyrics.add(new String[] {"Love", "is a", "fortress", "of light", "come inside"});
  lyric = lyrics.get(0);
  
  images = new HashMap<>();
  String[] dev = new String[]{"Dev"};
  String[] show = new String[]{"Fire", "Moon"};
  for (String g: show)
    loadSlides(g);  
  slide = randomImage(slideGroup);
  
  lcds = new LCDD[4];
  lcds[0] = new LCDD(0, 0, width/2, height/2, 3);
  lcds[1] = new LCDD(width/2, 0, width/2, height/2, 3);
  lcds[2] = new LCDD(0, height/2, width/2, height/2, 3);
  lcds[3] = new LCDD(width/2, height/2, width/2, height/2, 3);
  
  backBuffer = createGraphics(width, height);
  
  hito = new Hitodama(width, height);
  flies = new FireFlies(width, height);
  fire = new LodeFire(width, height);
  innerDD = new InnerDD();
  schiff = new Schiffman(width, height);

  video = new Capture(this, width, height);
  timerFn = () -> {
    if (slidesOn) {
      slide = randomImage(slideGroup);
      lyricChange();
    }
  };
}

int word = 0;
void draw() {  
  timer(timerFn);
  
  if (frameCount % 60 * 5 == 0) {
    word++;
    if (word == lyric.length) word = 0;
  }
  
  if (staticOn)
    g.background(bgColor); 
  
  backBuffer.beginDraw();
 
  if (backgroundOn) {
    backBuffer.background(black); 
  }

  if (slidesOn) {
    backBuffer.tint(slideTint);
    backBuffer.image(slide, slideX, 0);
  }
  
  if (videoOn && video.available()) {
      video.read(); // Read the captured video frame
      backBuffer.image(video, 0, 0);
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
  for (int i = lcds.length - 1; i >= 0; i--) {
    if (i == 0 || (lcds[0]._width < width && lcds[0]._height < height)) {
      bImage.resize(0, lcds[i].phRes);
      lcds[i].sourceImage(bImage);
      lcds[i].display();
    }
  }
  
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
    fill(slideTint);
    rect(0, indY, 50, indH);
    indY = 70;
    
    if (backgroundOn) {    
      fill(reDD);
      rect(0, indY+=indH, 15, indH);
    }
    if (slidesOn) {    
      fill(greenDD);
      rect(0, indY+=indH, 15, indH);
    }
    if (fliesOn) {    
      fill(whiteDD);
      rect(0, indY+=indH, 15, indH);
    }
    if (hitoOn) {    
      fill(blueDD);
      rect(0, indY+=indH, 15, indH);
    }
    if (inDDon) {    
      fill(pinkDD);
      rect(0, indY+=indH, 15, indH);
    }
    if (schiffOn) {    
      fill(neonDD);
      rect(0, indY+=indH, 15, indH);
    }
    if (fireOn) {    
      fill(palette[15]);
      rect(0, indY+=indH, 15, indH);
    }
    
    pop();
  }
}

void keyPressed() {
  if (key == BACKSPACE) {
    println("BACKSPACE", "Random Image", "Reset", "Hatch");
    slide = randomImage(slideGroup);
    innerDD.reset((int)random(10,200));
    flies.hatch(int(random(50, 200)));
  }
    
  if (key == 'b') {
    backgroundOn = !backgroundOn;
    for (int i = 0; i < lcds.length; i++)
      lcds[i].invalidate();
    println(key, "BACKGROUND", backgroundOn);
  }
  
  if (key == 'm') {
    slideGroup = "Fire";
    fireOn = !fireOn;
    println(key, "FIRE", fireOn);
  }

  if (key == 'f') {
    fpsOn = !fpsOn;
    println(key, "FPS", fpsOn);
  }

  if (key == 'o') {
    slideGroup = "Moon";
    fliesOn = !fliesOn;
    println(key, "FIREFLIES", fliesOn);
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
    staticOn = !staticOn;
    println(key, "Static", staticOn);
  }

  if (key == 'v') {
    videoOn = !videoOn;
    if (video == null)
      return;
      
    if (videoOn) video.start();
    else video.stop();
  }

  if (key == 'q') {println(key, "DIEMODE:1"); dieMode = 1;}
  if (key == 'w') {println(key, "DIEMODE:2"); dieMode = 2;}
    
  if (key == ENTER) {
    saveFrame("screenshots/LCDD#####.png");
    println("ENTER", "SAVE FRAME");
  }

  if (keyCode == LEFT) {
    lcds[0].transX -= lcds[0].scale * 10;
  }

  if (keyCode == RIGHT) {
    lcds[0].transX += lcds[0].scale * 10;
  }

  if (key == '=') {
    lcds[0].transX = lcds[0].transY = 0.0;
    println(key, "TRANS RESET");
  }
  
  if (keyCode == UP) {
    lcds[0].scale += .5;
    println("SCALE", lcds[0].scale);
  }

  if (keyCode == DOWN) {
    lcds[0].scale -= .5;
    println("SCALE", lcds[0].scale);
  }
  
  if (keyCode >= '1' && keyCode <= '9') {
    //Scale from 1.1 to 1.9
    String f = "" + key;
    int factor = Integer.parseInt(f);
    lcds[0].scale = lcds[0].scale + .1 * factor;
  }
  
  if (key == '0') {
    lcds[0].scale = 1.0;
    println("SCALE", lcds[0].scale);
  }

  if (key == 'j') {
    word++;
    if (word >= lyric.length) word = 0;
  }

  if (key == 'k') {
    lyricsOn = !lyricsOn;
    println(key, "LYRICS", lyricsOn);
  }
  
  if (key == 'l') {
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
      lcds[i].imageOn = !lcds[i].imageOn;
    println(key, "PIP", lcds[0].imageOn);
  }
  
  if (key == '-') {
    if (lcds[0]._width == width)
      lcds[0].setResolution(width/2, height/2, 3);
    else
      lcds[0].setResolution(width, height, 3);
    println(key, "SPLIT");
  }
  
  if (key == 'a') {
    slideTint = palette[(int)random(palette.length)];
    println(key, "TINT");
  }
  fire.keyPressed();  
}

void lyricChange() {
  lyric = lyrics.get((int)random(lyrics.size()));
  word = 0;
}
