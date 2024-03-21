class Schiffman {
  float theta;
  int _w;
  int _h;
  
  Schiffman(int w, int h) {
    _w = w;
    _h = h;
  }
  
  void display(PGraphics frame) {
    //frame.background(0);
    if (mouseX != -1) {
      frame.push();
      frame.stroke(255, 200);
      //strokeWeight(random(.1, 5));
      // Let's pick an angle 0 to 90 degrees based on the mouse position
      float a = (mouseX / (float) width) * 90f;
      // Convert it to radians
      theta = radians(a);
      // Start the tree from the bottom of the screen
      frame.translate(width/2,height);
      // Draw a line 120 pixels
      frame.line(0,0,0,-120);
      // Move to the end of that line
      frame.translate(0,-120);
      // Start the recursive branching!
      branch(120, frame);
      frame.pop();
    }
  }

  void branch(float h, PGraphics frame) {
    // Each branch will be 2/3rds the size of the previous one
    h *= 0.7;
    
    // All recursive functions must have an exit condition!!!!
    // Here, ours is when the length of the branch is 2 pixels or less
    if (h > 2) {
      frame.pushMatrix();    // Save the current state of transformation (i.e. where are we now)
      frame.rotate(theta);   // Rotate by theta
      frame.line(0, 0, 0, -h);  // Draw the branch
      frame.translate(0, -h); // Move to the end of the branch
      branch(h,frame);       // Ok, now call myself to draw two new branches!!
      frame.popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
      
      // Repeat the same thing, only branch off to the "left" this time!
      frame.pushMatrix();
      frame.rotate(-theta);
      frame.line(0, 0, 0, -h);
      frame.translate(0, -h);
      branch(h, frame);
      frame.popMatrix();
    }
  }
}
