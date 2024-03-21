import java.util.Random;

class LodeFire {
  int sw;
  int sh;
  int[] fire;
  color[] palette = new int[256];

  Random rand = new Random();
  
  int step1 = 1;
  int step2 = 2;
  int xOff = 1;
  
  LodeFire(int w, int h) {
    sw = w;
    sh = h;
    fire = new int[sh * sw];  // This buffer will contain the fire values
    fire = new int[height * width];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
          fire[y * width + x] = 0;
      }
    }
  
    push();
    colorMode(HSB, 360, 100, 100);
    for (int x = 0; x < 256; x++) {
      // Hue goes from 0 to 85: red to yellow
      // Saturation is always the maximum: 255
      // Lightness is 0..255 for x=0..128, and 255 for x=128..255
      color c = color(x / 3, 255, Math.min(255, x * 2));
      // Set the palette to the calculated RGB value
      palette[x] = c;
    }
    pop();
  }


  void display(PGraphics frame) {
    frame.loadPixels();

    // Randomize the bottom row of the fire buffer
    int brIndex = (height - 1) * width;
    for (int x = 0; x < width; x += xOff) {
      if (x % xOff == 0)
        fire[brIndex + x] = Math.abs(32768 + rand.nextInt()) % 256;
      else
        fire[brIndex + x] = 0;
    }
  
    for (int y = 0; y < height - 1; y++) {
        for (int x = 0; x < width; x++) {
            int index = y * width + x; // Calculate the index in the 1D array
            fire[index] = ((fire[((y + 1) % height) * width + ((x - 1 + width) % width)]
                    + fire[((y + floor(map(mouseX, 0, width, 1, 20))) % height) * width + (x % width)]
                    + fire[((y + 1) % height) * width + ((x + 1) % width)]
                    + fire[((y + floor(map(mouseY, 0, height, 2, 20))) % height) * width + (x % width)]) * 128) / 513;
            
            if (fire[index] > 5) {
              color c1 = lerpColor(palette[fire[index]], bgColor, random(.75));
              c1 = (c1 & 0xFFFFFF) | (int(100) << 24);
              frame.pixels[y * width + x] = c1;
            }
        }
    }  
  
    frame.updatePixels();
  }
  
  void keyPressed() { 
    if (key == 'x' && xOff > 1) {
      xOff--;
      println(key, "FIRE X", xOff);
    }
    
    if (key == 'z') {
     xOff++;
      println(key, "FIRE X", xOff);
    }
  }
}
