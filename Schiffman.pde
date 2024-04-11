class Schiffman {
  float theta;
  int _w;
  int _h;
  int tLevel = 50;
  PGraphics fg;
  
  Schiffman(int w, int h) {
    _w = w;
    _h = h;
    fg = createGraphics(_w, _h);
    draw();
  }
  
  void setLevel(int tl) {
    if (tl == tLevel) return;
    
    tLevel = tl;
    draw();
  }
  
  void draw() {
    fg.beginDraw();
    fg.clear();
    fg.push();
    fg.stroke(0, 0);
    // Let's pick an angle 0 to 90 degrees based on the mouse position
    float a = (tLevel / (float) width) * 90f;
    // Convert it to radians
    theta = radians(a);
    // Start the tree from the bottom of the screen
    fg.translate(width/2, height/2 + 120);
    // Draw a line 120 pixels
    fg.line(0,0,0,-120);
    // Move to the end of that line
    fg.translate(0,-120);
    // Start the recursive branching!
    branch(120);
    fg.pop();
    fg.endDraw();
  }
  
  void display(PGraphics frame) {       
    frame.image(fg, 0, 0);
  }

  void branch(float h) {
    // Each branch will be 2/3rds the size of the previous one
    h *= 0.75;
    
    fg.stroke(random(255), random(255), random(255));//, random(255));    
    fg.strokeWeight(.5);
    // All recursive functions must have an exit condition!!!!
    // Here, ours is when the length of the branch is 2 pixels or less
    if (h > 2) {
      fg.pushMatrix();    // Save the current state of transformation (i.e. where are we now)
      fg.scale(1.1);
      fg.rotate(theta);   // Rotate by theta
      fg.line(0, 0, 0, -h);  // Draw the branch
      fg.translate(0, -h); // Move to the end of the branch
      branch(h);       // Ok, now call myself to draw two new branches!!
      fg.popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
      
      // Repeat the same thing, only branch off to the "left" this time!
      fg.pushMatrix();
      fg.scale(1.1);
      fg.rotate(-theta);
      fg.line(0, 0, 0, -h);
      fg.translate(0, -h);
      branch(h);
      fg.popMatrix();
    }
  }
}
