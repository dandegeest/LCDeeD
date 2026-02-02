float maxR;

class Hitodama {

  ArrayList<Shape> shapes = new ArrayList();
  int shapesNum = 80;
  
  Hitodama(int w, int h) {
    maxR = min(w, h) * 0.8;
  
    for (int i = 0; i < shapesNum; i++) {
      shapes.add(new Shape());
    }
  }
  
  void display(PGraphics frame) {
    for (int i = 0; i < shapes.size(); i++) {
      Shape s = shapes.get(i);
      s.move();
      s.display(frame);
    }
  
    //filter(BLUR, 6);
    //filter(POSTERIZE, 4);
  }
  
}

class Shape {
  float x;
  float y;
  float r;
  float startT;
  float t;
  float rSpeed;
  float tSpeed;
  float maxW;
  float w;
  color c;
  float n;
  
  Shape() {
    this.x = width / 2;
    this.y = height / 2;
    this.r = random(maxR);
    this.startT = random(-180 + 45, -45);
    this.t = this.startT;
    this.rSpeed = random(0.5, 1) * 10;
    this.tSpeed = random(0, 0.75);
    this.maxW = random(10, 200);
    this.w = this.maxW;
    this.c = color(random(170, 240), 100, 100, 20);
    c = color(random(100, 255), 20);
    int adjust = (int)random(15,145);
    c = color(255-adjust, 160-adjust, 200-adjust, 20);
    this.n = random(1000);
  }

  void move() {
    this.x = width / 2 + cos(this.t) * this.r;
    this.y = height * 0.8 + sin(this.t) * this.r;
    this.r += this.rSpeed;
    this.w = map(this.r, 0, maxR, this.maxW, 0);
    this.t = map(noise(frameCount * 0.01, this.n), 0, 1, -180 + 45, -45);
    //this.startT + map(noise(frameCount * 0.0075), 0, 1, -15, 15);

    if (this.r > maxR) {
      this.r = 0;
    }
  }

  void display(PGraphics frame) {
    frame.push();
    frame.noStroke();
    frame.fill(lerpColor(this.c, palette.get("darkBlue"), .5));
    frame.translate(this.x, this.y);
    // rotate(this.t + 45);
    frame.circle(0, 0, this.w);
    frame.pop();
  }  
}
