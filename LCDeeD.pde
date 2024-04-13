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

// Slides
HashMap<String, ArrayList<Slide>> slides;
// Lyrics
ArrayList<String[]> lyrics = new ArrayList<>();
String[] lyric;
int word = 0;
int lyricFade;
PFont[] lyricFonts;
int lyricFont = 0;
float lyricSize = 174;

//Movies
Movie movie;
int movieNumber = 0;
ArrayList<String> movieTitles = new ArrayList<>();

//Video
Capture video;

// Events
HashMap<Character, VisEvent> visEvents = new HashMap();
ArrayList<VisEvent> fx = new ArrayList();

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

//Active TV Input
int input = 0;

//Images
String slideGroup;
int slideNumber = -1;
int slideLayer = 0;
int slideBrighT = 40;
int lastPhase = 0;
PImage slide;
float slideX = 0;

// Timers
Timer slideTimer;
Timer fxTimer;

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
  slideNumber++;
  if (slideNumber >= imgGroup.size())
    slideNumber = 0;  
  
  Slide slide = imgGroup.get(slideNumber);
  if (slide.image == null) {
    loadSlideImage(slide);
  }
  
  if (group == "Wiitch")
    slide.image.resize(0, max(100, (int)random(100, height)));
  
  slideX = random(width - slide.image.width);
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


String[] elements = new String[] {"Earth", "Wind", "Fire", "Water"};

void setup() {
  size(1280, 720);
  frameRate(60);
  cursor(loadImage(sketchPath("") + "wcursor.png"), 0, 0);
  fullScreen();
  
  lyrics.add(new String[] {"It's", "The Moon", "The", "Pink Moon", "And", "It's", "Rising"});
  lyrics.add(new String[] {"Love", "Is A", "Fortress", "OF Light", "COME", "INSIDE"});
  lyrics.add(new String[] {"Wiitch TiiT", "Lyndsay", "MAMA T", "AshTree", "The Colonel", "Benji"});
  lyrics.add(elements);
  lyric = lyrics.get(0);
  
  lyricFonts = new PFont[3];
  lyricFonts[0] = createFont("fonts/tetris.ttf", 18, true);
  lyricFonts[1] = createFont("fonts/Roboto-Bold.ttf", 18, true);
  lyricFonts[2] = createFont("fonts/mocha.ttf", 18, true);

  slides = new HashMap<>();
  String[] show = new String[]{"Dev", "Fire", "Moon", "Phases", "Wiitch"};
  for (String g: show)
    loadSlides(g);  
  slideGroup = show[0];
  slide = nextSlide(slideGroup);
  
  lcds = new LCDD[4];
  lcds[0] = new LCDD(0, 0, width, height, 3);
  lcds[0].logo = loadImage(sketchPath("") + "imagesWiitch/wiitch_logo2.png");
  lcds[0].logo.resize(0, 100);
  lcds[0].tvOn = true;
  lcds[0].scanInterval = 2;
  // Split screens
  lcds[1] = new LCDD(width/2, 0, width/2, height/2, 3);
  lcds[1].scanInterval = 2;
  lcds[1].overScanColor = black;
  lcds[1].overScanOn = true;
  lcds[2] = new LCDD(0, height/2, width/2, height/2, 3);
  lcds[2].scanInterval = .5;
  lcds[2].overScanColor = whiteDD;
  lcds[2].overScanOn = true;
  lcds[3] = new LCDD(width/2, height/2, width/2, height/2, 3);
  lcds[3].overScanColor = greenDD;
  lcds[3].overScanOn = true;
  
  backBuffer = createGraphics(width, height);

  loadMovies();
  
  hito = new Hitodama(width, height);
  flies = new FireFlies(width, height);
  fire = new LodeFire(width, height);
  innerDD = new InnerDD();
  schiff = new Schiffman(width, height);
  
  loadEvents();
  loadFX();
  
  slideTimer = new Timer();
  slideTimer.interval = 10 * 1000;
  slideTimer.tfx = () -> {
    if (movie == null && video == null) {
      slide = nextSlide(slideGroup);
    }
  };
  
  fxTimer = new Timer();
  fxTimer.interval = 10 * 1000;
  fxTimer.tfx = () -> {
    int pInput = input;
    input = 0;
    fx.get(floor(random(fx.size()))).fire();
    input = pInput;
  };
}

void movieEvent(Movie m) {
  if (movie.isPlaying())
    m.read();
}

void captureEvent(Capture c) {
  c.read();
}

void loadEvents() {
  // BACK BUFFER
  visEvents.put('b', toggleBackground);
  visEvents.put('a', randomTint);
  visEvents.put('A', backgroundTint);
  visEvents.put('c', backgroundColorReset);
  visEvents.put('C', resetTint);
  
  // PIXELS
  visEvents.put(':', pixelMode);
  visEvents.put('7', briteMode0);
  visEvents.put('8', briteMode1);
  visEvents.put('9', briteMode2);

  // LYRICS
  visEvents.put('j', nextLyric);
  visEvents.put('J', lyricsChange);
  visEvents.put('k', toggleLyrics);
  visEvents.put('K', randomLyricColor);
  visEvents.put('l', incLyricFont);

  // VISUALIZERS
  visEvents.put('f', toggleFire);
  visEvents.put('h', toggleHito);
  visEvents.put('i', toggleInnerDD);
  visEvents.put('I', innerConnect);
  visEvents.put('e', innerDDieMode1);
  visEvents.put('E', innerDDieMode2);
  visEvents.put('o', toggleFlies);
  visEvents.put('O', toggleGrass);
  visEvents.put('[', mowGrass);
  visEvents.put(']', growGrass);
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
  visEvents.put('t', togglePIP);
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
  visEvents.put('Z', centerScaleTV);
  //          LOGO
  visEvents.put('L', toggleLogo);  
  
  // RESETS
  visEvents.put('0', resetAll);
  visEvents.put(BACKSPACE, resetVis);
  
  // SLIDES
  visEvents.put('g', slidesFire);
  visEvents.put('G', slidesDev);
  visEvents.put('w', slidesWiitch);
  visEvents.put('W', slidesMoon);
  visEvents.put('P', togglePhases);
  
  // Movies
  visEvents.put('u', rewindMovie);
  visEvents.put('U', nextMovie);
  visEvents.put('T', closeMovie);
  
  // Video
  visEvents.put('v', videoToggle);
  
  // TRANSPARENCY
  visEvents.put('y', slideBrighTInc);
  visEvents.put('Y', slideBrighTDec);

  // TOOL
  visEvents.put('D', toggleDebug);
  visEvents.put(ENTER, saveFrame);
}

void loadFX() {
  fx.add(toggleHito);
  fx.add(toggleInnerDD);
  fx.add(innerConnect);
  fx.add(innerDDieMode1);
  fx.add(innerDDieMode2);
  fx.add(toggleFlies);
  fx.add(toggleGrass);
  fx.add(mowGrass);
  fx.add(growGrass);
  //fx.add(toggleSchiff);
  //fx.add(toggleSlides);

  fx.add(overScanToggle);
  fx.add(overScanColor);
  fx.add(overScanColorReset); 
  fx.add(overScanWidth); 
  fx.add(overScanInterval); 
  fx.add(overScanWidthReset); 
  fx.add(overScanIntervalReset); 

  fx.add(scaleDown);
  fx.add(scaleUp);

  fx.add(briteMode0);
  fx.add(briteMode1);
  fx.add(briteMode2);
  
  fx.add(slideBrighTInc);
  fx.add(slideBrighTDec);
  
  //fx.add(slidesWiitch);
  //fx.add(slidesMoon);
  //fx.add(togglePhases);
  
  fx.add(randomTint);
  fx.add(backgroundTint);
  
  fx.add(nextLyric);
  fx.add(lyricsChange);
  fx.add(toggleLyrics);
  fx.add(randomLyricColor);
  
  fx.add(randomSchiff);
}

void draw() { 
  timer(slideTimer);
  timer(fxTimer);
  
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
      lcds[i].sourceImage(bImage, 0);
      
      //Overlay
      if (slideLayer == 2) {
        PImage vi = null;
        if (video != null && video.isCapturing()) {
          //video.read();
          vi = video.get();
        }
        else if (movie != null) {
          vi = movie.get();
        }
        else vi = schiff.fg.get();
        if (vi != null) {
          vi.resize(0, lcds[i].phRes);
          lcds[i].sourceImage(vi, slideBrighT);
        }
      }
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
  println("FireFlies", flies.fliesOn);
};

VisEvent togglePhases = () -> {
    slideNumber = lastPhase;
    setSlideGroup("Phases");
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
  println("FIRE", fireOn);
};

VisEvent toggleSchiff = () -> {
  schiffOn = !schiffOn;
  println("SCHIFFON", schiffOn);
};

VisEvent toggleSlides = () -> {
  slideLayer++;
  if (slideLayer == 3) slideLayer = 0;
  println("SLIDES", slideLayer);
};

VisEvent innerConnect = () -> {
  connected = !connected;
  println(key, "INNERCONNECTED", connected);
};

VisEvent rewindMovie = () -> { 
  if (movie == null) return;
  movie.stop();
  movie.jump(0);
  movie.play();
  movie.volume(0);
  println("Restart movie");
};

VisEvent closeMovie = () -> {
  if (movie  == null) return;
  movie.stop();
  movie = null;
  println("Close movie", movieNumber, movieTitles.get(movieNumber));
};

VisEvent nextMovie = () -> { 
  closeMovie.fire();
  movieNumber++;
  if (movieNumber == movieTitles.size()) movieNumber = 0;
  movie = new Movie(this, movieTitles.get(movieNumber));
  movie.play();  
  movie.volume(0);
  println("New movie", movieNumber, movieTitles.get(movieNumber));
};

VisEvent videoToggle = () -> {
  if(video == null) {
    String[] cameras = Capture.list();
    printArray(cameras);
    video = new Capture(this, lcds[0].pwRes, lcds[0].phRes, cameras[0]);
    println("Video init", video.pixelWidth, video.pixelHeight);
  }
  videoOn = !videoOn;
  
  if (videoOn) {
    closeMovie.fire();
    video.start();
  }
  else {
    video.stop();
  }
  println(key, "Video", videoOn);
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
    
  if (backgroundOn == false) {
    backBuffer.clear();  // Clear all pixels to transparent
    backBuffer.background(0, 0, 0, 0); 
  }
  println("BACKGROUND", backgroundOn);
};

VisEvent backgroundColorReset = () -> {
  bgColor = color((int)random(255), 0);//black;
  println("BACKGROUND RESET", red(bgColor), green(bgColor), blue(bgColor));
};

VisEvent randomTint = () -> {
  slideTint = palette[(int)random(palette.length)];
  println("TINT", red(slideTint), green(slideTint), blue(slideTint));
}; 

VisEvent resetTint = () -> {
  slideTint = whiteDD;
  println("TINT", red(slideTint), green(slideTint), blue(slideTint));
}; 

VisEvent randomLyricColor = () -> {
  lyricColor = palette[(int)random(palette.length)];
  if (lyricColor == black) {
    lyricColor = color(random(255), random(255), random(255));
  }
  println("LYRIC COLOR", red(lyricColor), green(lyricColor), blue(lyricColor));
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

VisEvent growGrass = () -> {
  flies.grassHeight(flies.grassH-=.1);
};

VisEvent mowGrass = () -> {
  flies.grassHeight(flies.grassH+=.1);
};

VisEvent saveFrame = () -> {
  String frameName = "screenshots/LCDD#####.png";
  saveFrame(frameName);
  println("SAVE FRAME", frameName);
};

VisEvent transLeft = () -> {
  lcds[input].transX -= lcds[input].scale * 10;
  println("TX", lcds[input].transX);
};

VisEvent transRight = () -> {
  lcds[input].transX += lcds[input].scale * 10;
  println("TX", lcds[input].transX);
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
  lyricSize = random(100, 200);
  println("Next Lyric->" + lyric[word]);
};

VisEvent incLyricFont = () -> {
  lyricFont++;
  if (lyricFont == lyricFonts.length) lyricFont = 0;
};

VisEvent randomSchiff = () -> {
  if (!schiffOn) return;
  schiff.setLevel((int)random(width/2));
  println("RND SCHIFF", schiff.tLevel);
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

VisEvent centerScaleTV = () -> {
  lcds[input].centerScale = !lcds[input].centerScale;
  println("CENTER", input, lcds[input].centerScale);
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
  println("Overscan TV " + input, lcds[input].overScanOn);
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
  lcds[input].lumosMode = 0;
  println("BRIGHT", input, lcds[input].lumosMode);
};

VisEvent briteMode1 = () -> {
  lcds[input].lumosMode = 1;
  println("BRIGHT", input, lcds[input].lumosMode);
};

VisEvent briteMode2 = () -> {
  lcds[input].lumosMode = 2;
  println("BRIGHT", input, lcds[input].lumosMode);
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

VisEvent slidesFire = () -> {   
  setSlideGroup("Fire");
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

VisEvent slideBrighTInc = () -> {  
  slideBrighT+=5;
  if (slideBrighT > 255)
    slideBrighT = 255;
  println("SLIDE BRIGHT", slideBrighT);
};

VisEvent slideBrighTDec = () -> { 
  slideBrighT-=5;
  if (slideBrighT < 0)
    slideBrighT = 0;
  println("SLIDE BRIGHT", slideBrighT);
};

void handleCoded() {
  if (keyCode == LEFT) transLeft.fire();
  if (keyCode == RIGHT) transRight.fire();
  if (keyCode == UP) transUp.fire();
  if (keyCode == DOWN) transDown.fire();
}

void mousePressed() {
  schiff.setLevel(min(mouseX, width/2));
}

void drawDebug() {
  if (debugOn) {
    int indY = 20;
    int indW = 60;
    int indH = 10;

    push();
    noStroke();
    fill(0, 20);
    rect(0, 0, indW, 20);
    rect(0, indY, indW, 150);  
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
    fill(lyricColor);
    text(lyric[word], 0, indY, indW, indH);
    
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

    pop();
  }
}
