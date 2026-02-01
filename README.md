# LCDeeD
An LCD TV simulation renderer for Processing

![image](/LCDD_TV.png)
![image](/screenshots/LCDD02690.png)
![image](/screenshots/LCDD19494.png)
![image](/screenshots/LCDD49199.png)
![image](/screenshots/LCDD01535.png)
![image](/screenshots/LCDD03932.png)
![image](/screenshots/LCDD08055.png)

## Overview

LCDeeD is a **retro-style LCD/TV display simulator** that recreates the look and behavior of vintage computer monitors and television screens. The system creates a pixel-perfect grid of individual display elements that can be controlled and animated to produce authentic retro visual effects.

### Core Components

**LCDD Class**: The main display simulator that converts screen dimensions into a lower resolution grid based on pixel size, creating that chunky, pixelated aesthetic of retro displays.

**Pixel Management**: Each display pixel is individually addressable with RGB color control and luminosity settings. The system manages thousands of discrete pixel objects for precise control.

**Visual Effects**:
- **Scanline Animation**: Implements a moving scanline effect that sweeps across the display, creating that classic CRT TV "rolling" effect
- **Overscan**: Adds vertical lines across the display to simulate CRT overscan artifacts  
- **Interlaced Rendering**: Alternates luminosity between even/odd lines for authentic retro look
- **Phosphor Simulation**: Individual sub-pixels (R,G,B) rendered separately to mimic CRT phosphor behavior

**Content Rendering Modes**:
- `CONTENT_OFF`: Pure effects mode with no background content
- `CONTENT_BACKGROUND`: Content composited as background layer with effects on top
- `CONTENT_OVERLAY`: Content applied as selective pixel overlay directly to LCD screens

### Performance Optimizations

- **Cached Content System**: Static slides cached to eliminate expensive scaling operations
- **Dirty Rectangle Tracking**: Only redraws changed regions instead of full screen updates  
- **Scanner State Caching**: Optimized scanline effects with minimal per-frame processing
- **Bounds Checking**: Safe array access when switching between display modes

## Rendering Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                          DRAW() FUNCTION                        │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                  backBuffer.beginDraw()                         │
│                 (1280x720 compositing)                          │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│  backgroundOn? → backBuffer.background(bgColor)                 │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                 contentMode == CONTENT_BACKGROUND?              │
└─────────────────┬───────────────────────────────────────────────┘
                  │ YES
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│              CONTENT CHANGE DETECTION                           │
│  • Video state changed?                                         │
│  • Movie state changed?                                         │
│  • Tint color changed?                                          │
│  • Cache invalid?                                               │
└─────────────────┬───────────────────┬───────────────────────────┘
         YES      │                   │ NO
                  ▼                   ▼
┌─────────────────────────────────┐ ┌─────────────────────────────┐
│    REBUILD scaledContent        │ │    USE CACHED scaledConten  │
│   ┌──────────────────────────┐  │ │                             │
│   │ scaledContent.beginDraw()│  │ │   Skip expensive operations:│
│   │ scaledContent.clear()    │  │ │   • No scaling              │
│   │ Apply tint if needed     │  │ │   • No tint operations      │
│   │ Scale video/movie/slide  │  │ │   • No method calls         │
│   │ scaledContent.endDraw()  │  │ │                             │
│   └──────────────────────────┘  │ │                             │
│                                 │ │                             │
│   Update cache state:           │ │                             │
│   • lastVideoState              │ │                             │
│   • lastMovieState              │ │                             │
│   • lastTint                    │ │                             │
│   • contentCacheValid = true    │ │                             │
└─────────────────────────────────┘ └─────────────────────────────┘
                  │                   │
                  └─────────┬─────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│           backBuffer.image(scaledContent, 0, 0)                 │
│              (Fast blit - no scaling needed)                    │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ADD OTHER EFFECTS                             │
│  • Lyrics (if lyricsOn)                                         │
│  • Hitodama particles (if hitoOn)                               │
│  • Schiffman trees (if schiffOn)                                │
│  • Fire effect (if fireOn)                                      │
│  • FireFlies (if flies.fliesOn)                                 │
│  • InnerDD visualization (if inDDon)                            │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                   backBuffer.endDraw()                          │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│              PImage bImage = backBuffer.get()                   │
│                  (Extract final image)                          │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                    LCD DISPLAY PROCESSING                       │
│  For each LCDD screen (lcds[0-3]):                              │
│    • Resize bImage to LCD resolution                            │
│    • Apply contentMode OVERLAY if needed                        │
│    • lcds[i].sourceImage(bImage, 0)                             │
│    • lcds[i].display() - renders with scanlines/effects         │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                     FINAL SCREEN OUTPUT                         │
│         Either LCD screens OR full bImage if all TVs off        │
└─────────────────────────────────────────────────────────────────┘
```

## Visual Events & Key Commands

The system uses a comprehensive event system (`VisEvents.pde`) that maps keyboard inputs to visual effects and display controls:

### Display Controls
- **Tab**: Toggle split screen mode
- **1,2,3,4**: Select TV input (0-3)
- **!,@,#,$**: Toggle TV on/off
- **t**: Toggle picture-in-picture (PIP)

### Content Modes  
- **s**: Cycle through content modes (OFF → BACKGROUND → OVERLAY)

### Visual Effects
- **f**: Toggle fire effect
- **h**: Toggle Hitodama particle system
- **i**: Toggle InnerDD visualization 
- **I**: Toggle InnerDD connection
- **o**: Toggle FireFlies
- **O**: Toggle grass effect
- **p**: Toggle Schiffman tree fractal
- **[,]**: Mow/grow grass

### Display Settings
- **M**: Toggle overscan effect
- **/,?**: Change/reset overscan color
- **<,>**: Adjust overscan width/interval  
- **.,comma**: Reset overscan parameters
- **-,=**: Scale down/up display
- **+**: Reset scale
- **_**: Reset translation
- **Z**: Toggle center scaling
- **L**: Toggle station logos

### Content Controls
- **g,G**: Switch slide groups (Fire/Dev)
- **w,W**: Switch slide groups (Wiitch/Moon) 
- **P**: Toggle phase slides
- **u,U**: Rewind/next movie
- **T**: Close movie
- **v**: Toggle video capture
- **y,Y**: Adjust slide brightness threshold

### Color & Effects
- **b**: Toggle background
- **a,A**: Random/background tint
- **c,C**: Reset colors/tint
- **k**: Random lyric color
- **:**: Toggle pixel mode
- **7,8,9**: Set brightness modes (0,1,2)

### Lyrics
- **j**: Next word
- **J**: Next lyric line  
- **K**: Toggle lyrics on/off
- **l**: Change lyric font

### Special Functions
- **e**: Toggle effigy mode
- **E**: Pink Moon finale sequence
- **%**: Toggle auto mode
- **0**: Reset all settings
- **Backspace**: Reset visualizers
- **D**: Toggle debug display
- **Enter**: Save frame

### Arrow Keys
- **Left/Right**: Translate display horizontally
- **Up/Down**: Translate display vertically

The event system also includes automatic timer-driven effects when auto mode is enabled, cycling through various visual effects and display settings to create dynamic, evolving displays.


