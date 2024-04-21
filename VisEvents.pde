@FunctionalInterface
interface VisEvent {
    void fire();
}

HashMap<Character, VisEvent> keyEvents = new HashMap();
ArrayList<VisEvent> fx = new ArrayList();
ArrayList<VisEvent> zoom = new ArrayList();

VisEvent toggleAuto = () -> {
  autoOn = !autoOn;
  println("AUTO", autoOn);
};

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
  println("OSD", debugOn);
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
  bgColor = black;//color((int)random(255), 0);//black;
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

void effigyUpdate() {
  if (effigyOn) {
    lcds[0].overScanOn = true;
    lcds[0].logoOn = earthPuzzOn;
    
    lcds[1].overScanOn = true;
    lcds[1].logoOn = windPuzzOn;
    
    lcds[2].overScanOn = true;
    lcds[2].logoOn = firePuzzOn;
    
    lcds[3].overScanOn = true;
    lcds[3].logoOn = waterPuzzOn;
  }
}

VisEvent toggleEffigy = () -> {
  effigyOn = !effigyOn;
  splitScreen(effigyOn);
  if (effigyOn) {
    effigyUpdate();
  }
  else {
    lcds[0].logoOn = false;
    lcds[1].logoOn = false;
    lcds[2].logoOn = false;
    lcds[3].logoOn = false;    
  }
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

void splitScreen(boolean split) {
  if (split == true) {
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
}

VisEvent splitScreen = () -> {
  if (lcds[0]._width == width) {
    splitScreen(true);
  }
  else {
    splitScreen(false);
    if (effigyOn) toggleEffigy.fire();
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

void loadKeyboardEvents() {
  keyEvents.put('%', toggleAuto);
  
  // BACK BUFFER
  keyEvents.put('b', toggleBackground);
  keyEvents.put('a', randomTint);
  keyEvents.put('A', backgroundTint);
  keyEvents.put('c', backgroundColorReset);
  keyEvents.put('C', resetTint);
  
  // PIXELS
  keyEvents.put(':', pixelMode);
  keyEvents.put('7', briteMode0);
  keyEvents.put('8', briteMode1);
  keyEvents.put('9', briteMode2);

  // LYRICS
  keyEvents.put('j', nextLyric);
  keyEvents.put('J', lyricsChange);
  keyEvents.put('k', toggleLyrics);
  keyEvents.put('K', randomLyricColor);
  keyEvents.put('l', incLyricFont);

  // EFFIGY
  keyEvents.put('e', toggleEffigy);
  //keyEvents.put('E', innerDDieMode2);

  // VISUALIZERS
  keyEvents.put('f', toggleFire);
  keyEvents.put('h', toggleHito);
  keyEvents.put('i', toggleInnerDD);
  keyEvents.put('I', innerConnect);
  keyEvents.put('o', toggleFlies);
  keyEvents.put('O', toggleGrass);
  keyEvents.put('[', mowGrass);
  keyEvents.put(']', growGrass);
  keyEvents.put('p', toggleSchiff);
  keyEvents.put('s', toggleSlides);
  
  // TV CONTROLS
  //    ON/OFF
  keyEvents.put('1', selectTV_0);
  keyEvents.put('2', selectTV_1);
  keyEvents.put('3', selectTV_2);
  keyEvents.put('4', selectTV_3);
  //    SELECT INPUT
  keyEvents.put(TAB, splitScreen);
  keyEvents.put('t', togglePIP);
  //    SELECT INPUT
  keyEvents.put('!', toggleTV_0);
  keyEvents.put('@', toggleTV_1);
  keyEvents.put('#', toggleTV_2);
  keyEvents.put('$', toggleTV_3);
  //    INPUT OPTIONS
  //          OVERSCAN
  keyEvents.put('M', overScanToggle);
  keyEvents.put('/', overScanColor);
  keyEvents.put('?', overScanColorReset); 
  keyEvents.put('<', overScanWidth); 
  keyEvents.put('>', overScanInterval); 
  keyEvents.put('.', overScanWidthReset); 
  keyEvents.put(',', overScanIntervalReset); 
  //          SCALING
  keyEvents.put('-', scaleDown);
  keyEvents.put('=', scaleUp);
  keyEvents.put('+', scaleReset);
  keyEvents.put('_', transReset);
  keyEvents.put('Z', centerScaleTV);
  //          LOGO
  keyEvents.put('L', toggleLogo);  
  
  // RESETS
  keyEvents.put('0', resetAll);
  keyEvents.put(BACKSPACE, resetVis);
  
  // SLIDES
  keyEvents.put('g', slidesFire);
  keyEvents.put('G', slidesDev);
  keyEvents.put('w', slidesWiitch);
  keyEvents.put('W', slidesMoon);
  keyEvents.put('P', togglePhases);
  
  // Movies
  keyEvents.put('u', rewindMovie);
  keyEvents.put('U', nextMovie);
  keyEvents.put('T', closeMovie);
  
  // Video
  keyEvents.put('v', videoToggle);
  
  // TRANSPARENCY
  keyEvents.put('y', slideBrighTInc);
  keyEvents.put('Y', slideBrighTDec);

  // TOOL
  keyEvents.put('D', toggleDebug);
  keyEvents.put(ENTER, saveFrame);
}

void loadTimerEvents() {
  fx.add(toggleHito);
  fx.add(toggleInnerDD);
  fx.add(innerConnect);
  fx.add(innerDDieMode1);
  fx.add(innerDDieMode2);
  fx.add(toggleFlies);
  fx.add(toggleGrass);
  fx.add(mowGrass);
  fx.add(growGrass);
  fx.add(toggleSchiff);
  fx.add(toggleSlides);

  fx.add(overScanToggle);
  fx.add(overScanColor);
  fx.add(overScanColorReset); 
  fx.add(overScanWidthReset); 
  fx.add(overScanIntervalReset); 

  for (int z = 0; z < 3; z++) {
    zoom.add(scaleUp);
    zoom.add(overScanInterval);
  }
  zoom.add(scaleDown);
  zoom.add(overScanWidth); 

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
