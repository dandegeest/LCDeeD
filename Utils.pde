import java.io.File;
import java.util.ArrayList;
import processing.video.*;

@FunctionalInterface
interface TimerFunction {
    void timeout();
}

int interval = 10 * 1000; // 1 Second Timer Interval
int previousTime = 0;

void timer(TimerFunction tfx) {
  // Check if the specified interval has passed
  if (millis() - previousTime > interval) {
    previousTime = millis();
    tfx.timeout();
  }
}

int luminosity(int r, int g, int b, float lumos) {
  // Convert RGB color to HSB color space
  float[] hsb = java.awt.Color.RGBtoHSB(r, g, b, null);
  // Adjust the brightness (luminosity) component
  hsb[2] *= lumos; // Multiply by the luminosity facto
  // Convert back to RGB color space
  return java.awt.Color.HSBtoRGB(hsb[0], hsb[1], hsb[2]);
}

PImage resizeImage(PImage img, int targetWidth, int targetHeight) {
  if (img.width == targetWidth && img.height == targetHeight)
    return img;
    
  // Calculate the aspect ratio of the original image
  float aspectRatio = float(img.width) / img.height;

  // Calculate the new dimensions while maintaining the aspect ratio
  int newWidth, newHeight;
  if (targetWidth / aspectRatio <= targetHeight) {
    // Resize based on width to fit within the target dimensions
    newWidth = targetWidth;
    newHeight = int(targetWidth / aspectRatio);
  } else {
    // Resize based on height to fit within the target dimensions
    newWidth = int(targetHeight * aspectRatio);
    newHeight = targetHeight;
  }

  // Create a new PImage with the calculated dimensions
  PImage resizedImage = createImage(newWidth, newHeight, ARGB);

  // Copy the original image to the resized image
  resizedImage.copy(img, 0, 0, img.width, img.height, 0, 0, newWidth, newHeight);

  //println("Resize:" + resizedImage.width + "x" + resizedImage.height);
  return resizedImage;
}

ArrayList<String> loadImageFolder(String folderPath) {
  ArrayList<String> filenames = new ArrayList<String>();
  
  // Create a File object for the folder
  File folder = new File(folderPath);
  
  // Check if the folder exists and is a directory
  if (folder.exists() && folder.isDirectory()) {
    println("Loading...", folderPath);
    // Get an array of File objects representing files in the folder
    File[] files = folder.listFiles();
    
    // Loop through the files array and add filenames to the ArrayList
    for (File file : files) {
      if (file.isFile()) {
        filenames.add(file.getName());
      }
    }
  }
  
  return filenames;
}
 
