// Base Visualizer class for custom drawing effects
abstract class Visualizer {
  protected float x, y, w, h;
  protected boolean enabled = false;
  protected color primaryColor;
  protected color secondaryColor;
  protected float alpha = 255;
  
  // Animation timing
  protected float time = 0;
  protected float speed = 1.0;
  
  public Visualizer(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.primaryColor = color(greenDD);
    this.secondaryColor = color(whiteDD);
    initialize();
  }
  
  // Override this in subclasses for custom initialization
  protected void initialize() {
  }
  
  // Main render method - must be implemented by subclasses
  public abstract void render(PGraphics buffer);
  
  // Update animation state
  public void update() {
    if (enabled) {
      time += speed;
      updateAnimation();
    }
  }
  
  // Override this for custom animation updates
  protected void updateAnimation() {
  }
  
  // Control methods
  public void enable() { enabled = true; }
  public void disable() { enabled = false; }
  public boolean isEnabled() { return enabled; }
  
  public void setColors(color primary, color secondary) {
    this.primaryColor = primary;
    this.secondaryColor = secondary;
  }
  
  public void setAlpha(float alpha) {
    this.alpha = constrain(alpha, 0, 255);
  }
  
  public void setSpeed(float speed) {
    this.speed = speed;
  }
  
  public void reset() {
    time = 0;
    initialize();
  }
  
  public void setBounds(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
}

// Example concrete visualizer - Pulse effect
class PulseVisualizer extends Visualizer {
  private float pulseRadius;
  private float maxRadius;
  
  public PulseVisualizer(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  protected void initialize() {
    maxRadius = min(w, h) * 0.4;
    pulseRadius = 0;
  }
  
  protected void updateAnimation() {
    pulseRadius = (sin(time * 0.1) + 1) * 0.5 * maxRadius;
  }
  
  public void render(PGraphics buffer) {
    if (!enabled) return;
    
    buffer.push();
    buffer.noFill();
    buffer.stroke(red(primaryColor), green(primaryColor), blue(primaryColor), alpha * 0.8);
    buffer.strokeWeight(2);
    
    float centerX = x + w * 0.5;
    float centerY = y + h * 0.5;
    
    // Draw concentric circles
    for (int i = 1; i <= 3; i++) {
      float radius = pulseRadius * i * 0.4;
      float ringAlpha = alpha * (1.0 - (i - 1) * 0.3);
      buffer.stroke(red(primaryColor), green(primaryColor), blue(primaryColor), ringAlpha);
      buffer.ellipse(centerX, centerY, radius * 2, radius * 2);
    }
    
    buffer.pop();
  }
}

// Grid pattern visualizer
class GridVisualizer extends Visualizer {
  private float gridSize = 20;
  private float offset;
  
  public GridVisualizer(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  protected void updateAnimation() {
    offset = (time * 0.5) % gridSize;
  }
  
  public void render(PGraphics buffer) {
    if (!enabled) return;
    
    buffer.push();
    buffer.stroke(red(primaryColor), green(primaryColor), blue(primaryColor), alpha * 0.5);
    buffer.strokeWeight(1);
    
    // Vertical lines
    for (float i = x - offset; i <= x + w; i += gridSize) {
      buffer.line(i, y, i, y + h);
    }
    
    // Horizontal lines  
    for (float i = y - offset; i <= y + h; i += gridSize) {
      buffer.line(x, i, x + w, i);
    }
    
    buffer.pop();
  }
  
  public void setGridSize(float size) {
    this.gridSize = size;
  }
}

// Simple image visualizer
class ImageVisualizer extends Visualizer {
  private PImage sourceImage;
  private String imagePath;
  
  public ImageVisualizer(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  public ImageVisualizer(float x, float y, float w, float h, String imagePath) {
    super(x, y, w, h);
    setImage(imagePath);
  }
  
  public void setImage(String imagePath) {
    this.imagePath = imagePath;
    try {
      sourceImage = loadImage(this.imagePath);
      if (sourceImage == null) {
        println("Failed to load image: " + imagePath);
      }
    } catch (Exception e) {
      println("Error loading image: " + imagePath + " - " + e.getMessage());
      sourceImage = null;
    }
  }
  
  public void setImage(PImage img) {
    sourceImage = img;
    imagePath = null;
  }
  
  public void render(PGraphics buffer) {
    if (!enabled || sourceImage == null) return;
    
    buffer.push();
    buffer.tint(255, alpha);
    
    buffer.image(sourceImage, 0, 0);

    buffer.pop();
  }
}