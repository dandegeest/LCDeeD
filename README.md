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

### New LCDDInput Source Model

The system now features a **pluggable LCDDInput architecture** that allows for custom drawing effects to be rendered directly to each LCD screen. This modular design replaces the previous hardcoded content system with a flexible, extensible framework:

**Abstract Base Class**: `LCDDInput` provides the foundation with common properties (position, colors, alpha, animation timing) and abstract `render()` method that subclasses must implement.

**Built-in LCDDInput Types**:
- **PulseLCDDInput**: Animated concentric circles that pulse outward from the center
- **GridLCDDInput**: Animated grid pattern with moving offset
- **ImageLCDDInput**: Static image display with transparency support  
- **FireFliesLCDDInput**: Complex procedural animation with fireflies and swaying grass

**Integration**: Each LCDD screen can have its own LCDDInput instance that renders during the update cycle. The rendered content is automatically scaled and applied to the pixel grid, maintaining the retro aesthetic while allowing for rich, custom visual content.

**⚠️ Critical Setup Note - pixelDensity(1)**

**IMPORTANT**: LCDeeD requires `pixelDensity(1)` to be set in `setup()` for pixel-accurate rendering. Without this setting, the LCD pixel grid will not align properly with the display, causing visual artifacts and incorrect scaling. This was a significant debugging issue that cost considerable development time - always ensure `pixelDensity(1)` is called before any display initialization.

### Core Components

**LCDD Class**: The main display simulator that converts screen dimensions into a lower resolution grid based on pixel size, creating that chunky, pixelated aesthetic of retro displays. Now supports pluggable LCDDInput sources for dynamic content generation.

**Pixel Management**: Each display pixel is individually addressable with RGB color control and luminosity settings. The system manages thousands of discrete pixel objects for precise control.

**LCDDInput System**: Modular content generation system where each screen can have its own custom drawing effect. LCDDInputs render to a PGraphics buffer that gets automatically converted to the pixel grid format.

**Visual Effects**:
- **Scanline Animation**: Implements a moving scanline effect that sweeps across the display, creating that classic CRT TV "rolling" effect
- **Overscan**: Adds vertical lines across the display to simulate CRT overscan artifacts  
- **Interlaced Rendering**: Alternates luminosity between even/odd lines for authentic retro look
- **Phosphor Simulation**: Individual sub-pixels (R,G,B) rendered separately to mimic CRT phosphor behavior

**Content Rendering Modes**:

The new LCDDInput architecture replaces the previous content mode system. Each LCDD screen now directly renders its assigned LCDDInput during the update cycle:

- **LCDDInput Enabled**: The assigned LCDDInput renders to the screen's backBuffer, which is then converted to the pixel grid
- **LCDDInput Disabled**: Screen displays static content or remains blank based on background settings
- **Multiple Screens**: Each of the four LCDD screens can run different LCDDInputs simultaneously

### Performance Optimizations

- **LCDDInput Caching**: Each LCDDInput manages its own animation state and only renders when enabled
- **Dirty Rectangle Tracking**: Only redraws changed regions instead of full screen updates  
- **Scanner State Caching**: Optimized scanline effects with minimal per-frame processing
- **Bounds Checking**: Safe array access when switching between display modes
- **Per-Screen Isolation**: Each LCDD manages its own LCDDInput independently for maximum performance

## Rendering Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                          DRAW() FUNCTION                        │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FOR EACH LCDD SCREEN                         │
│                        lcdd.update()                            │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                  LCDDInput ENABLED CHECK                        │
│              if (sourceInput.isEnabled())                       │
└─────────────────┬───────────────────┬───────────────────────────┘
        YES       │                   │ NO - Skip to display()
                  ▼                   ▼
┌─────────────────────────────────┐ ┌─────────────────────────────┐
│        LCDDInput RENDERING      │ │      STATIC DISPLAY         │
│   ┌──────────────────────────┐  │ │                             │
│   │ sourceInput.update()     │  │ │   Use existing pixel state  │
│   │ backBuffer.beginDraw()   │  │ │   Apply scanline effects    │
│   │ sourceInput.render()     │  │ │   Render with current       │
│   │ backBuffer.endDraw()     │  │ │   overscan settings         │
│   │ Convert to pixel grid    │  │ │                             │
│   └──────────────────────────┘  │ │                             │
└─────────────────────────────────┘ └─────────────────────────────┘
                  │                   │
                  └─────────┬─────────┘
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    LCDD.DISPLAY()                               │
│  • Apply scaling/translation transforms                         │
│  • Run scanline animation                                       │
│  • Render dirty pixel regions                                   │
│  • Apply overscan effects                                       │
│  • Show picture-in-picture if enabled                           │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                     FINAL SCREEN OUTPUT                         │
│    Either individual LCD screens OR full backBuffer             │
│              if all TVs are turned off (no LCDD effects)        │
└─────────────────────────────────────────────────────────────────┘
```

## Visual Events & Key Commands

The system uses a custom event system (`VisEvents.pde`) that maps keyboard inputs to visual effects and display controls but can also be fired programmatically as show in the "autoRun" mode:

### Display Controls
- **Tab**: Toggle split screen mode
- **1,2,3,4**: Select TV input (0-3)
- **!,@,#,$**: Toggle TV on/off
- **t**: Toggle picture-in-picture (PIP)

### LCDDInput Controls (NEW)
- **f**: Toggle custom LCDDInputs on/off for all screens
- **V**: Cycle through LCDDInput types (Pulse → Grid → Image → Pulse)
- **r**: Reset custom LCDDInputs (restart animations, reload state)

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

### Color & Effects
- **b**: Toggle background erasure
- **:**: Toggle pixel mode (changes sub-pixel rendering)
- **7,8,9**: Set brightness modes (0: interlaced, 1: full, 2: brightness-based)

### Special Functions
- **%**: Toggle auto mode (automatic effect cycling)
- **0**: Reset all settings (scale, translation, etc.)
- **D**: Toggle debug display (shows framerate)
- **Enter**: Save frame to screenshots/

### Arrow Keys
- **Left/Right**: Translate display horizontally
- **Up/Down**: Translate display vertically

### Auto Mode
When auto mode is enabled with **%**, the system automatically cycles through various visual effects and display settings using timer-driven events, creating dynamic, evolving displays without manual intervention.

## LCDDInput Architecture

The LCDDInput system represents a major architectural shift from hardcoded effects to a pluggable, extensible content generation framework. This design pattern enables easy creation of custom visual effects while maintaining the retro LCD aesthetic.

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        LCDD Screen                              │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   LCDDInput                               │  │
│  │  • Abstract base class                                   │  │
│  │  • Common properties (position, colors, timing)         │  │
│  │  • abstract render(PGraphics buffer)                    │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                 backBuffer                                │  │
│  │  • PGraphics canvas                                      │  │
│  │  • Rendered by LCDDInput.render()                       │  │
│  │  • Scaled to match LCDD resolution                      │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Pixel Grid Conversion                        │  │
│  │  • sourceImage(backBuffer.get(), 0)                     │  │
│  │  • Individual pixel RGB mapping                          │  │
│  │  • Luminosity and brightness processing                  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Creating Custom LCDDInputs

To create a custom LCDDInput, extend the abstract base class and implement the `render()` method:

```processing
class CustomLCDDInput extends LCDDInput {
  private float animationParam;
  
  public CustomLCDDInput(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  protected void initialize() {
    // Set up initial state
    animationParam = 0;
  }
  
  protected void updateAnimation() {
    // Update animation state each frame
    animationParam += speed;
  }
  
  public void render(PGraphics buffer) {
    if (!enabled) return;
    
    buffer.push();
    // Your custom drawing code here
    // Use this.time for animation timing
    // Use this.primaryColor and secondaryColor for theming
    // Use this.alpha for transparency
    buffer.pop();
  }
}
```

### Built-in LCDDInput Types

**PulseLCDDInput**: Creates animated concentric circles that pulse outward from the center, perfect for abstract visual effects or attention-grabbing displays.

**GridLCDDInput**: Renders an animated grid pattern with configurable spacing and moving offset, ideal for technical or geometric backgrounds.

**ImageLCDDInput**: Displays static images with proper scaling and transparency support, allowing for logos, patterns, or artistic content.

**FireFliesLCDDInput**: A complex procedural animation featuring fireflies with flocking behavior and animated grass, demonstrating the full power of the LCDDInput system for rich, interactive content.

## Screenshot Gallery

Click any image to view full size:

<a href="screenshots/LCDD00001.png"><img src="screenshots/LCDD00001.png" width="200"/></a>
<a href="screenshots/LCDD00002.png"><img src="screenshots/LCDD00002.png" width="200"/></a>
<a href="screenshots/LCDD00003.png"><img src="screenshots/LCDD00003.png" width="200"/></a>
<a href="screenshots/LCDD00017.png"><img src="screenshots/LCDD00017.png" width="200"/></a>
<a href="screenshots/LCDD00075.png"><img src="screenshots/LCDD00075.png" width="200"/></a>
<a href="screenshots/LCDD00131.png"><img src="screenshots/LCDD00131.png" width="200"/></a>
<a href="screenshots/LCDD00147.png"><img src="screenshots/LCDD00147.png" width="200"/></a>
<a href="screenshots/LCDD00164.png"><img src="screenshots/LCDD00164.png" width="200"/></a>
<a href="screenshots/LCDD00204.png"><img src="screenshots/LCDD00204.png" width="200"/></a>
<a href="screenshots/LCDD00207.png"><img src="screenshots/LCDD00207.png" width="200"/></a>
<a href="screenshots/LCDD00212.png"><img src="screenshots/LCDD00212.png" width="200"/></a>
<a href="screenshots/LCDD00229.png"><img src="screenshots/LCDD00229.png" width="200"/></a>
<a href="screenshots/LCDD00333.png"><img src="screenshots/LCDD00333.png" width="200"/></a>
<a href="screenshots/LCDD00334.png"><img src="screenshots/LCDD00334.png" width="200"/></a>
<a href="screenshots/LCDD00335.png"><img src="screenshots/LCDD00335.png" width="200"/></a>
<a href="screenshots/LCDD00336.png"><img src="screenshots/LCDD00336.png" width="200"/></a>
<a href="screenshots/LCDD00339.png"><img src="screenshots/LCDD00339.png" width="200"/></a>
<a href="screenshots/LCDD00364.png"><img src="screenshots/LCDD00364.png" width="200"/></a>
<a href="screenshots/LCDD00418.png"><img src="screenshots/LCDD00418.png" width="200"/></a>
<a href="screenshots/LCDD00470.png"><img src="screenshots/LCDD00470.png" width="200"/></a>
<a href="screenshots/LCDD00481.png"><img src="screenshots/LCDD00481.png" width="200"/></a>
<a href="screenshots/LCDD00489.png"><img src="screenshots/LCDD00489.png" width="200"/></a>
<a href="screenshots/LCDD00497.png"><img src="screenshots/LCDD00497.png" width="200"/></a>
<a href="screenshots/LCDD00522.png"><img src="screenshots/LCDD00522.png" width="200"/></a>
<a href="screenshots/LCDD00554.png"><img src="screenshots/LCDD00554.png" width="200"/></a>
<a href="screenshots/LCDD00629.png"><img src="screenshots/LCDD00629.png" width="200"/></a>
<a href="screenshots/LCDD00635.png"><img src="screenshots/LCDD00635.png" width="200"/></a>
<a href="screenshots/LCDD00641.png"><img src="screenshots/LCDD00641.png" width="200"/></a>
<a href="screenshots/LCDD00653.png"><img src="screenshots/LCDD00653.png" width="200"/></a>
<a href="screenshots/LCDD00678.png"><img src="screenshots/LCDD00678.png" width="200"/></a>
<a href="screenshots/LCDD00680.png"><img src="screenshots/LCDD00680.png" width="200"/></a>
<a href="screenshots/LCDD00693.png"><img src="screenshots/LCDD00693.png" width="200"/></a>
<a href="screenshots/LCDD00757.png"><img src="screenshots/LCDD00757.png" width="200"/></a>
<a href="screenshots/LCDD00760.png"><img src="screenshots/LCDD00760.png" width="200"/></a>
<a href="screenshots/LCDD00801.png"><img src="screenshots/LCDD00801.png" width="200"/></a>
<a href="screenshots/LCDD00834.png"><img src="screenshots/LCDD00834.png" width="200"/></a>
<a href="screenshots/LCDD00836.png"><img src="screenshots/LCDD00836.png" width="200"/></a>
<a href="screenshots/LCDD00850.png"><img src="screenshots/LCDD00850.png" width="200"/></a>
<a href="screenshots/LCDD00864.png"><img src="screenshots/LCDD00864.png" width="200"/></a>
<a href="screenshots/LCDD00882.png"><img src="screenshots/LCDD00882.png" width="200"/></a>
<a href="screenshots/LCDD00957.png"><img src="screenshots/LCDD00957.png" width="200"/></a>
<a href="screenshots/LCDD00962.png"><img src="screenshots/LCDD00962.png" width="200"/></a>
<a href="screenshots/LCDD00995.png"><img src="screenshots/LCDD00995.png" width="200"/></a>
<a href="screenshots/LCDD01029.png"><img src="screenshots/LCDD01029.png" width="200"/></a>
<a href="screenshots/LCDD01110.png"><img src="screenshots/LCDD01110.png" width="200"/></a>
<a href="screenshots/LCDD01131.png"><img src="screenshots/LCDD01131.png" width="200"/></a>
<a href="screenshots/LCDD01137.png"><img src="screenshots/LCDD01137.png" width="200"/></a>
<a href="screenshots/LCDD01163.png"><img src="screenshots/LCDD01163.png" width="200"/></a>
<a href="screenshots/LCDD01172.png"><img src="screenshots/LCDD01172.png" width="200"/></a>
<a href="screenshots/LCDD01183.png"><img src="screenshots/LCDD01183.png" width="200"/></a>
<a href="screenshots/LCDD01186.png"><img src="screenshots/LCDD01186.png" width="200"/></a>
<a href="screenshots/LCDD01217.png"><img src="screenshots/LCDD01217.png" width="200"/></a>
<a href="screenshots/LCDD01244.png"><img src="screenshots/LCDD01244.png" width="200"/></a>
<a href="screenshots/LCDD01284.png"><img src="screenshots/LCDD01284.png" width="200"/></a>
<a href="screenshots/LCDD01321.png"><img src="screenshots/LCDD01321.png" width="200"/></a>
<a href="screenshots/LCDD01390.png"><img src="screenshots/LCDD01390.png" width="200"/></a>
<a href="screenshots/LCDD01399.png"><img src="screenshots/LCDD01399.png" width="200"/></a>
<a href="screenshots/LCDD01404.png"><img src="screenshots/LCDD01404.png" width="200"/></a>
<a href="screenshots/LCDD01415.png"><img src="screenshots/LCDD01415.png" width="200"/></a>
<a href="screenshots/LCDD01435.png"><img src="screenshots/LCDD01435.png" width="200"/></a>
<a href="screenshots/LCDD01446.png"><img src="screenshots/LCDD01446.png" width="200"/></a>
<a href="screenshots/LCDD01501.png"><img src="screenshots/LCDD01501.png" width="200"/></a>
<a href="screenshots/LCDD01510.png"><img src="screenshots/LCDD01510.png" width="200"/></a>
<a href="screenshots/LCDD01511.png"><img src="screenshots/LCDD01511.png" width="200"/></a>
<a href="screenshots/LCDD01535.png"><img src="screenshots/LCDD01535.png" width="200"/></a>
<a href="screenshots/LCDD01542.png"><img src="screenshots/LCDD01542.png" width="200"/></a>
<a href="screenshots/LCDD01547.png"><img src="screenshots/LCDD01547.png" width="200"/></a>
<a href="screenshots/LCDD01585.png"><img src="screenshots/LCDD01585.png" width="200"/></a>
<a href="screenshots/LCDD01616.png"><img src="screenshots/LCDD01616.png" width="200"/></a>
<a href="screenshots/LCDD01689.png"><img src="screenshots/LCDD01689.png" width="200"/></a>
<a href="screenshots/LCDD01713.png"><img src="screenshots/LCDD01713.png" width="200"/></a>
<a href="screenshots/LCDD01751.png"><img src="screenshots/LCDD01751.png" width="200"/></a>
<a href="screenshots/LCDD01863.png"><img src="screenshots/LCDD01863.png" width="200"/></a>
<a href="screenshots/LCDD01893.png"><img src="screenshots/LCDD01893.png" width="200"/></a>
<a href="screenshots/LCDD01907.png"><img src="screenshots/LCDD01907.png" width="200"/></a>
<a href="screenshots/LCDD01925.png"><img src="screenshots/LCDD01925.png" width="200"/></a>
<a href="screenshots/LCDD01995.png"><img src="screenshots/LCDD01995.png" width="200"/></a>
<a href="screenshots/LCDD02024.png"><img src="screenshots/LCDD02024.png" width="200"/></a>
<a href="screenshots/LCDD02053.png"><img src="screenshots/LCDD02053.png" width="200"/></a>
<a href="screenshots/LCDD02062.png"><img src="screenshots/LCDD02062.png" width="200"/></a>
<a href="screenshots/LCDD02098.png"><img src="screenshots/LCDD02098.png" width="200"/></a>
<a href="screenshots/LCDD02208.png"><img src="screenshots/LCDD02208.png" width="200"/></a>
<a href="screenshots/LCDD02212.png"><img src="screenshots/LCDD02212.png" width="200"/></a>
<a href="screenshots/LCDD02230.png"><img src="screenshots/LCDD02230.png" width="200"/></a>
<a href="screenshots/LCDD02331.png"><img src="screenshots/LCDD02331.png" width="200"/></a>
<a href="screenshots/LCDD02358.png"><img src="screenshots/LCDD02358.png" width="200"/></a>
<a href="screenshots/LCDD02364.png"><img src="screenshots/LCDD02364.png" width="200"/></a>
<a href="screenshots/LCDD02390.png"><img src="screenshots/LCDD02390.png" width="200"/></a>
<a href="screenshots/LCDD02395.png"><img src="screenshots/LCDD02395.png" width="200"/></a>
<a href="screenshots/LCDD02403.png"><img src="screenshots/LCDD02403.png" width="200"/></a>
<a href="screenshots/LCDD02439.png"><img src="screenshots/LCDD02439.png" width="200"/></a>
<a href="screenshots/LCDD02552.png"><img src="screenshots/LCDD02552.png" width="200"/></a>
<a href="screenshots/LCDD02561.png"><img src="screenshots/LCDD02561.png" width="200"/></a>
<a href="screenshots/LCDD02619.png"><img src="screenshots/LCDD02619.png" width="200"/></a>
<a href="screenshots/LCDD02627.png"><img src="screenshots/LCDD02627.png" width="200"/></a>
<a href="screenshots/LCDD02637.png"><img src="screenshots/LCDD02637.png" width="200"/></a>
<a href="screenshots/LCDD02640.png"><img src="screenshots/LCDD02640.png" width="200"/></a>
<a href="screenshots/LCDD02690.png"><img src="screenshots/LCDD02690.png" width="200"/></a>
<a href="screenshots/LCDD02716.png"><img src="screenshots/LCDD02716.png" width="200"/></a>
<a href="screenshots/LCDD02759.png"><img src="screenshots/LCDD02759.png" width="200"/></a>
<a href="screenshots/LCDD02802.png"><img src="screenshots/LCDD02802.png" width="200"/></a>
<a href="screenshots/LCDD02927.png"><img src="screenshots/LCDD02927.png" width="200"/></a>
<a href="screenshots/LCDD02930.png"><img src="screenshots/LCDD02930.png" width="200"/></a>
<a href="screenshots/LCDD02989.png"><img src="screenshots/LCDD02989.png" width="200"/></a>
<a href="screenshots/LCDD03000.png"><img src="screenshots/LCDD03000.png" width="200"/></a>
<a href="screenshots/LCDD03031.png"><img src="screenshots/LCDD03031.png" width="200"/></a>
<a href="screenshots/LCDD03179.png"><img src="screenshots/LCDD03179.png" width="200"/></a>
<a href="screenshots/LCDD03184.png"><img src="screenshots/LCDD03184.png" width="200"/></a>
<a href="screenshots/LCDD03198.png"><img src="screenshots/LCDD03198.png" width="200"/></a>
<a href="screenshots/LCDD03206.png"><img src="screenshots/LCDD03206.png" width="200"/></a>
<a href="screenshots/LCDD03223.png"><img src="screenshots/LCDD03223.png" width="200"/></a>
<a href="screenshots/LCDD03226.png"><img src="screenshots/LCDD03226.png" width="200"/></a>
<a href="screenshots/LCDD03245.png"><img src="screenshots/LCDD03245.png" width="200"/></a>
<a href="screenshots/LCDD03250.png"><img src="screenshots/LCDD03250.png" width="200"/></a>
<a href="screenshots/LCDD03260.png"><img src="screenshots/LCDD03260.png" width="200"/></a>
<a href="screenshots/LCDD03283.png"><img src="screenshots/LCDD03283.png" width="200"/></a>
<a href="screenshots/LCDD03323.png"><img src="screenshots/LCDD03323.png" width="200"/></a>
<a href="screenshots/LCDD03468.png"><img src="screenshots/LCDD03468.png" width="200"/></a>
<a href="screenshots/LCDD03496.png"><img src="screenshots/LCDD03496.png" width="200"/></a>
<a href="screenshots/LCDD03582.png"><img src="screenshots/LCDD03582.png" width="200"/></a>
<a href="screenshots/LCDD03621.png"><img src="screenshots/LCDD03621.png" width="200"/></a>
<a href="screenshots/LCDD03649.png"><img src="screenshots/LCDD03649.png" width="200"/></a>
<a href="screenshots/LCDD03686.png"><img src="screenshots/LCDD03686.png" width="200"/></a>
<a href="screenshots/LCDD03688.png"><img src="screenshots/LCDD03688.png" width="200"/></a>
<a href="screenshots/LCDD03720.png"><img src="screenshots/LCDD03720.png" width="200"/></a>
<a href="screenshots/LCDD03747.png"><img src="screenshots/LCDD03747.png" width="200"/></a>
<a href="screenshots/LCDD03778.png"><img src="screenshots/LCDD03778.png" width="200"/></a>
<a href="screenshots/LCDD03787.png"><img src="screenshots/LCDD03787.png" width="200"/></a>
<a href="screenshots/LCDD03805.png"><img src="screenshots/LCDD03805.png" width="200"/></a>
<a href="screenshots/LCDD03808.png"><img src="screenshots/LCDD03808.png" width="200"/></a>
<a href="screenshots/LCDD03842.png"><img src="screenshots/LCDD03842.png" width="200"/></a>
<a href="screenshots/LCDD03932.png"><img src="screenshots/LCDD03932.png" width="200"/></a>
<a href="screenshots/LCDD03970.png"><img src="screenshots/LCDD03970.png" width="200"/></a>
<a href="screenshots/LCDD03973.png"><img src="screenshots/LCDD03973.png" width="200"/></a>
<a href="screenshots/LCDD04010.png"><img src="screenshots/LCDD04010.png" width="200"/></a>
<a href="screenshots/LCDD04017.png"><img src="screenshots/LCDD04017.png" width="200"/></a>
<a href="screenshots/LCDD04019.png"><img src="screenshots/LCDD04019.png" width="200"/></a>
<a href="screenshots/LCDD04021.png"><img src="screenshots/LCDD04021.png" width="200"/></a>
<a href="screenshots/LCDD04099.png"><img src="screenshots/LCDD04099.png" width="200"/></a>
<a href="screenshots/LCDD04108.png"><img src="screenshots/LCDD04108.png" width="200"/></a>
<a href="screenshots/LCDD04150.png"><img src="screenshots/LCDD04150.png" width="200"/></a>
<a href="screenshots/LCDD04214.png"><img src="screenshots/LCDD04214.png" width="200"/></a>
<a href="screenshots/LCDD04235.png"><img src="screenshots/LCDD04235.png" width="200"/></a>
<a href="screenshots/LCDD04246.png"><img src="screenshots/LCDD04246.png" width="200"/></a>
<a href="screenshots/LCDD04259.png"><img src="screenshots/LCDD04259.png" width="200"/></a>
<a href="screenshots/LCDD04331.png"><img src="screenshots/LCDD04331.png" width="200"/></a>
<a href="screenshots/LCDD04379.png"><img src="screenshots/LCDD04379.png" width="200"/></a>
<a href="screenshots/LCDD04394.png"><img src="screenshots/LCDD04394.png" width="200"/></a>
<a href="screenshots/LCDD04511.png"><img src="screenshots/LCDD04511.png" width="200"/></a>
<a href="screenshots/LCDD04512.png"><img src="screenshots/LCDD04512.png" width="200"/></a>
<a href="screenshots/LCDD04514.png"><img src="screenshots/LCDD04514.png" width="200"/></a>
<a href="screenshots/LCDD04526.png"><img src="screenshots/LCDD04526.png" width="200"/></a>
<a href="screenshots/LCDD04606.png"><img src="screenshots/LCDD04606.png" width="200"/></a>
<a href="screenshots/LCDD04711.png"><img src="screenshots/LCDD04711.png" width="200"/></a>
<a href="screenshots/LCDD04714.png"><img src="screenshots/LCDD04714.png" width="200"/></a>
<a href="screenshots/LCDD04731.png"><img src="screenshots/LCDD04731.png" width="200"/></a>
<a href="screenshots/LCDD04779.png"><img src="screenshots/LCDD04779.png" width="200"/></a>
<a href="screenshots/LCDD04826.png"><img src="screenshots/LCDD04826.png" width="200"/></a>
<a href="screenshots/LCDD04959.png"><img src="screenshots/LCDD04959.png" width="200"/></a>
<a href="screenshots/LCDD04982.png"><img src="screenshots/LCDD04982.png" width="200"/></a>
<a href="screenshots/LCDD05000.png"><img src="screenshots/LCDD05000.png" width="200"/></a>
<a href="screenshots/LCDD05101.png"><img src="screenshots/LCDD05101.png" width="200"/></a>
<a href="screenshots/LCDD05103.png"><img src="screenshots/LCDD05103.png" width="200"/></a>
<a href="screenshots/LCDD05173.png"><img src="screenshots/LCDD05173.png" width="200"/></a>
<a href="screenshots/LCDD05424.png"><img src="screenshots/LCDD05424.png" width="200"/></a>
<a href="screenshots/LCDD05456.png"><img src="screenshots/LCDD05456.png" width="200"/></a>
<a href="screenshots/LCDD05457.png"><img src="screenshots/LCDD05457.png" width="200"/></a>
<a href="screenshots/LCDD05464.png"><img src="screenshots/LCDD05464.png" width="200"/></a>
<a href="screenshots/LCDD05476.png"><img src="screenshots/LCDD05476.png" width="200"/></a>
<a href="screenshots/LCDD05564.png"><img src="screenshots/LCDD05564.png" width="200"/></a>
<a href="screenshots/LCDD05673.png"><img src="screenshots/LCDD05673.png" width="200"/></a>
<a href="screenshots/LCDD05692.png"><img src="screenshots/LCDD05692.png" width="200"/></a>
<a href="screenshots/LCDD05859.png"><img src="screenshots/LCDD05859.png" width="200"/></a>
<a href="screenshots/LCDD05881.png"><img src="screenshots/LCDD05881.png" width="200"/></a>
<a href="screenshots/LCDD06056.png"><img src="screenshots/LCDD06056.png" width="200"/></a>
<a href="screenshots/LCDD06060.png"><img src="screenshots/LCDD06060.png" width="200"/></a>
<a href="screenshots/LCDD06090.png"><img src="screenshots/LCDD06090.png" width="200"/></a>
<a href="screenshots/LCDD06113.png"><img src="screenshots/LCDD06113.png" width="200"/></a>
<a href="screenshots/LCDD06120.png"><img src="screenshots/LCDD06120.png" width="200"/></a>
<a href="screenshots/LCDD06286.png"><img src="screenshots/LCDD06286.png" width="200"/></a>
<a href="screenshots/LCDD06417.png"><img src="screenshots/LCDD06417.png" width="200"/></a>
<a href="screenshots/LCDD06585.png"><img src="screenshots/LCDD06585.png" width="200"/></a>
<a href="screenshots/LCDD06799.png"><img src="screenshots/LCDD06799.png" width="200"/></a>
<a href="screenshots/LCDD06841.png"><img src="screenshots/LCDD06841.png" width="200"/></a>
<a href="screenshots/LCDD06843.png"><img src="screenshots/LCDD06843.png" width="200"/></a>
<a href="screenshots/LCDD06900.png"><img src="screenshots/LCDD06900.png" width="200"/></a>
<a href="screenshots/LCDD06923.png"><img src="screenshots/LCDD06923.png" width="200"/></a>
<a href="screenshots/LCDD07165.png"><img src="screenshots/LCDD07165.png" width="200"/></a>
<a href="screenshots/LCDD07210.png"><img src="screenshots/LCDD07210.png" width="200"/></a>
<a href="screenshots/LCDD07243.png"><img src="screenshots/LCDD07243.png" width="200"/></a>
<a href="screenshots/LCDD07345.png"><img src="screenshots/LCDD07345.png" width="200"/></a>
<a href="screenshots/LCDD07347.png"><img src="screenshots/LCDD07347.png" width="200"/></a>
<a href="screenshots/LCDD07420.png"><img src="screenshots/LCDD07420.png" width="200"/></a>
<a href="screenshots/LCDD07444.png"><img src="screenshots/LCDD07444.png" width="200"/></a>
<a href="screenshots/LCDD07486.png"><img src="screenshots/LCDD07486.png" width="200"/></a>
<a href="screenshots/LCDD07580.png"><img src="screenshots/LCDD07580.png" width="200"/></a>
<a href="screenshots/LCDD07581.png"><img src="screenshots/LCDD07581.png" width="200"/></a>
<a href="screenshots/LCDD07631.png"><img src="screenshots/LCDD07631.png" width="200"/></a>
<a href="screenshots/LCDD07794.png"><img src="screenshots/LCDD07794.png" width="200"/></a>
<a href="screenshots/LCDD07904.png"><img src="screenshots/LCDD07904.png" width="200"/></a>
<a href="screenshots/LCDD07950.png"><img src="screenshots/LCDD07950.png" width="200"/></a>
<a href="screenshots/LCDD07988.png"><img src="screenshots/LCDD07988.png" width="200"/></a>
<a href="screenshots/LCDD08015.png"><img src="screenshots/LCDD08015.png" width="200"/></a>
<a href="screenshots/LCDD08055.png"><img src="screenshots/LCDD08055.png" width="200"/></a>
<a href="screenshots/LCDD08118.png"><img src="screenshots/LCDD08118.png" width="200"/></a>
<a href="screenshots/LCDD08210.png"><img src="screenshots/LCDD08210.png" width="200"/></a>
<a href="screenshots/LCDD08256.png"><img src="screenshots/LCDD08256.png" width="200"/></a>
<a href="screenshots/LCDD08258.png"><img src="screenshots/LCDD08258.png" width="200"/></a>
<a href="screenshots/LCDD08518.png"><img src="screenshots/LCDD08518.png" width="200"/></a>
<a href="screenshots/LCDD08530.png"><img src="screenshots/LCDD08530.png" width="200"/></a>
<a href="screenshots/LCDD08577.png"><img src="screenshots/LCDD08577.png" width="200"/></a>
<a href="screenshots/LCDD08596.png"><img src="screenshots/LCDD08596.png" width="200"/></a>
<a href="screenshots/LCDD08672.png"><img src="screenshots/LCDD08672.png" width="200"/></a>
<a href="screenshots/LCDD08690.png"><img src="screenshots/LCDD08690.png" width="200"/></a>
<a href="screenshots/LCDD08771.png"><img src="screenshots/LCDD08771.png" width="200"/></a>
<a href="screenshots/LCDD08787.png"><img src="screenshots/LCDD08787.png" width="200"/></a>
<a href="screenshots/LCDD08796.png"><img src="screenshots/LCDD08796.png" width="200"/></a>
<a href="screenshots/LCDD08801.png"><img src="screenshots/LCDD08801.png" width="200"/></a>
<a href="screenshots/LCDD08812.png"><img src="screenshots/LCDD08812.png" width="200"/></a>
<a href="screenshots/LCDD08836.png"><img src="screenshots/LCDD08836.png" width="200"/></a>
<a href="screenshots/LCDD08914.png"><img src="screenshots/LCDD08914.png" width="200"/></a>
<a href="screenshots/LCDD08934.png"><img src="screenshots/LCDD08934.png" width="200"/></a>
<a href="screenshots/LCDD08974.png"><img src="screenshots/LCDD08974.png" width="200"/></a>
<a href="screenshots/LCDD09000.png"><img src="screenshots/LCDD09000.png" width="200"/></a>
<a href="screenshots/LCDD09066.png"><img src="screenshots/LCDD09066.png" width="200"/></a>
<a href="screenshots/LCDD09121.png"><img src="screenshots/LCDD09121.png" width="200"/></a>
<a href="screenshots/LCDD09149.png"><img src="screenshots/LCDD09149.png" width="200"/></a>
<a href="screenshots/LCDD09170.png"><img src="screenshots/LCDD09170.png" width="200"/></a>
<a href="screenshots/LCDD09200.png"><img src="screenshots/LCDD09200.png" width="200"/></a>
<a href="screenshots/LCDD09396.png"><img src="screenshots/LCDD09396.png" width="200"/></a>
<a href="screenshots/LCDD09428.png"><img src="screenshots/LCDD09428.png" width="200"/></a>
<a href="screenshots/LCDD09443.png"><img src="screenshots/LCDD09443.png" width="200"/></a>
<a href="screenshots/LCDD09463.png"><img src="screenshots/LCDD09463.png" width="200"/></a>
<a href="screenshots/LCDD09585.png"><img src="screenshots/LCDD09585.png" width="200"/></a>
<a href="screenshots/LCDD09857.png"><img src="screenshots/LCDD09857.png" width="200"/></a>
<a href="screenshots/LCDD09963.png"><img src="screenshots/LCDD09963.png" width="200"/></a>
<a href="screenshots/LCDD09966.png"><img src="screenshots/LCDD09966.png" width="200"/></a>
<a href="screenshots/LCDD09994.png"><img src="screenshots/LCDD09994.png" width="200"/></a>
<a href="screenshots/LCDD10026.png"><img src="screenshots/LCDD10026.png" width="200"/></a>
<a href="screenshots/LCDD10385.png"><img src="screenshots/LCDD10385.png" width="200"/></a>
<a href="screenshots/LCDD10390.png"><img src="screenshots/LCDD10390.png" width="200"/></a>
<a href="screenshots/LCDD10416.png"><img src="screenshots/LCDD10416.png" width="200"/></a>
<a href="screenshots/LCDD10436.png"><img src="screenshots/LCDD10436.png" width="200"/></a>
<a href="screenshots/LCDD10459.png"><img src="screenshots/LCDD10459.png" width="200"/></a>
<a href="screenshots/LCDD10461.png"><img src="screenshots/LCDD10461.png" width="200"/></a>
<a href="screenshots/LCDD10468.png"><img src="screenshots/LCDD10468.png" width="200"/></a>
<a href="screenshots/LCDD10474.png"><img src="screenshots/LCDD10474.png" width="200"/></a>
<a href="screenshots/LCDD10537.png"><img src="screenshots/LCDD10537.png" width="200"/></a>
<a href="screenshots/LCDD10555.png"><img src="screenshots/LCDD10555.png" width="200"/></a>
<a href="screenshots/LCDD10575.png"><img src="screenshots/LCDD10575.png" width="200"/></a>
<a href="screenshots/LCDD10790.png"><img src="screenshots/LCDD10790.png" width="200"/></a>
<a href="screenshots/LCDD10912.png"><img src="screenshots/LCDD10912.png" width="200"/></a>
<a href="screenshots/LCDD10958.png"><img src="screenshots/LCDD10958.png" width="200"/></a>
<a href="screenshots/LCDD10985.png"><img src="screenshots/LCDD10985.png" width="200"/></a>
<a href="screenshots/LCDD10987.png"><img src="screenshots/LCDD10987.png" width="200"/></a>
<a href="screenshots/LCDD10989.png"><img src="screenshots/LCDD10989.png" width="200"/></a>
<a href="screenshots/LCDD11058.png"><img src="screenshots/LCDD11058.png" width="200"/></a>
<a href="screenshots/LCDD11323.png"><img src="screenshots/LCDD11323.png" width="200"/></a>
<a href="screenshots/LCDD11356.png"><img src="screenshots/LCDD11356.png" width="200"/></a>
<a href="screenshots/LCDD11436.png"><img src="screenshots/LCDD11436.png" width="200"/></a>
<a href="screenshots/LCDD11466.png"><img src="screenshots/LCDD11466.png" width="200"/></a>
<a href="screenshots/LCDD11515.png"><img src="screenshots/LCDD11515.png" width="200"/></a>
<a href="screenshots/LCDD11675.png"><img src="screenshots/LCDD11675.png" width="200"/></a>
<a href="screenshots/LCDD11750.png"><img src="screenshots/LCDD11750.png" width="200"/></a>
<a href="screenshots/LCDD11902.png"><img src="screenshots/LCDD11902.png" width="200"/></a>
<a href="screenshots/LCDD11979.png"><img src="screenshots/LCDD11979.png" width="200"/></a>
<a href="screenshots/LCDD12440.png"><img src="screenshots/LCDD12440.png" width="200"/></a>
<a href="screenshots/LCDD12490.png"><img src="screenshots/LCDD12490.png" width="200"/></a>
<a href="screenshots/LCDD12506.png"><img src="screenshots/LCDD12506.png" width="200"/></a>
<a href="screenshots/LCDD12529.png"><img src="screenshots/LCDD12529.png" width="200"/></a>
<a href="screenshots/LCDD12559.png"><img src="screenshots/LCDD12559.png" width="200"/></a>
<a href="screenshots/LCDD12587.png"><img src="screenshots/LCDD12587.png" width="200"/></a>
<a href="screenshots/LCDD12591.png"><img src="screenshots/LCDD12591.png" width="200"/></a>
<a href="screenshots/LCDD12669.png"><img src="screenshots/LCDD12669.png" width="200"/></a>
<a href="screenshots/LCDD12715.png"><img src="screenshots/LCDD12715.png" width="200"/></a>
<a href="screenshots/LCDD12750.png"><img src="screenshots/LCDD12750.png" width="200"/></a>
<a href="screenshots/LCDD12930.png"><img src="screenshots/LCDD12930.png" width="200"/></a>
<a href="screenshots/LCDD13169.png"><img src="screenshots/LCDD13169.png" width="200"/></a>
<a href="screenshots/LCDD13259.png"><img src="screenshots/LCDD13259.png" width="200"/></a>
<a href="screenshots/LCDD13290.png"><img src="screenshots/LCDD13290.png" width="200"/></a>
<a href="screenshots/LCDD13338.png"><img src="screenshots/LCDD13338.png" width="200"/></a>
<a href="screenshots/LCDD13350.png"><img src="screenshots/LCDD13350.png" width="200"/></a>
<a href="screenshots/LCDD13560.png"><img src="screenshots/LCDD13560.png" width="200"/></a>
<a href="screenshots/LCDD13948.png"><img src="screenshots/LCDD13948.png" width="200"/></a>
<a href="screenshots/LCDD14500.png"><img src="screenshots/LCDD14500.png" width="200"/></a>
<a href="screenshots/LCDD14614.png"><img src="screenshots/LCDD14614.png" width="200"/></a>
<a href="screenshots/LCDD14639.png"><img src="screenshots/LCDD14639.png" width="200"/></a>
<a href="screenshots/LCDD14915.png"><img src="screenshots/LCDD14915.png" width="200"/></a>
<a href="screenshots/LCDD15126.png"><img src="screenshots/LCDD15126.png" width="200"/></a>
<a href="screenshots/LCDD15640.png"><img src="screenshots/LCDD15640.png" width="200"/></a>
<a href="screenshots/LCDD15704.png"><img src="screenshots/LCDD15704.png" width="200"/></a>
<a href="screenshots/LCDD16079.png"><img src="screenshots/LCDD16079.png" width="200"/></a>
<a href="screenshots/LCDD16177.png"><img src="screenshots/LCDD16177.png" width="200"/></a>
<a href="screenshots/LCDD16234.png"><img src="screenshots/LCDD16234.png" width="200"/></a>
<a href="screenshots/LCDD17139.png"><img src="screenshots/LCDD17139.png" width="200"/></a>
<a href="screenshots/LCDD17230.png"><img src="screenshots/LCDD17230.png" width="200"/></a>
<a href="screenshots/LCDD17319.png"><img src="screenshots/LCDD17319.png" width="200"/></a>
<a href="screenshots/LCDD17426.png"><img src="screenshots/LCDD17426.png" width="200"/></a>
<a href="screenshots/LCDD18593.png"><img src="screenshots/LCDD18593.png" width="200"/></a>
<a href="screenshots/LCDD19494.png"><img src="screenshots/LCDD19494.png" width="200"/></a>
<a href="screenshots/LCDD19938.png"><img src="screenshots/LCDD19938.png" width="200"/></a>
<a href="screenshots/LCDD20213.png"><img src="screenshots/LCDD20213.png" width="200"/></a>
<a href="screenshots/LCDD20311.png"><img src="screenshots/LCDD20311.png" width="200"/></a>
<a href="screenshots/LCDD21400.png"><img src="screenshots/LCDD21400.png" width="200"/></a>
<a href="screenshots/LCDD22890.png"><img src="screenshots/LCDD22890.png" width="200"/></a>
<a href="screenshots/LCDD23541.png"><img src="screenshots/LCDD23541.png" width="200"/></a>
<a href="screenshots/LCDD24242.png"><img src="screenshots/LCDD24242.png" width="200"/></a>
<a href="screenshots/LCDD24824.png"><img src="screenshots/LCDD24824.png" width="200"/></a>
<a href="screenshots/LCDD24904.png"><img src="screenshots/LCDD24904.png" width="200"/></a>
<a href="screenshots/LCDD26164.png"><img src="screenshots/LCDD26164.png" width="200"/></a>
<a href="screenshots/LCDD27095.png"><img src="screenshots/LCDD27095.png" width="200"/></a>
<a href="screenshots/LCDD27729.png"><img src="screenshots/LCDD27729.png" width="200"/></a>
<a href="screenshots/LCDD28279.png"><img src="screenshots/LCDD28279.png" width="200"/></a>
<a href="screenshots/LCDD28928.png"><img src="screenshots/LCDD28928.png" width="200"/></a>
<a href="screenshots/LCDD28949.png"><img src="screenshots/LCDD28949.png" width="200"/></a>
<a href="screenshots/LCDD30899.png"><img src="screenshots/LCDD30899.png" width="200"/></a>
<a href="screenshots/LCDD37587.png"><img src="screenshots/LCDD37587.png" width="200"/></a>
<a href="screenshots/LCDD39297.png"><img src="screenshots/LCDD39297.png" width="200"/></a>
<a href="screenshots/LCDD41565.png"><img src="screenshots/LCDD41565.png" width="200"/></a>
<a href="screenshots/LCDD45692.png"><img src="screenshots/LCDD45692.png" width="200"/></a>
<a href="screenshots/LCDD45757.png"><img src="screenshots/LCDD45757.png" width="200"/></a>
<a href="screenshots/LCDD45892.png"><img src="screenshots/LCDD45892.png" width="200"/></a>
<a href="screenshots/LCDD47104.png"><img src="screenshots/LCDD47104.png" width="200"/></a>
<a href="screenshots/LCDD48181.png"><img src="screenshots/LCDD48181.png" width="200"/></a>
<a href="screenshots/LCDD49162.png"><img src="screenshots/LCDD49162.png" width="200"/></a>
<a href="screenshots/LCDD49199.png"><img src="screenshots/LCDD49199.png" width="200"/></a>
<a href="screenshots/LCDD53456.png"><img src="screenshots/LCDD53456.png" width="200"/></a>
<a href="screenshots/LCDD57754.png"><img src="screenshots/LCDD57754.png" width="200"/></a>
<a href="screenshots/LCDD57844.png"><img src="screenshots/LCDD57844.png" width="200"/></a>
<a href="screenshots/LCDD57871.png"><img src="screenshots/LCDD57871.png" width="200"/></a>
<a href="screenshots/LCDD58342.png"><img src="screenshots/LCDD58342.png" width="200"/></a>