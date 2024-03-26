import java.util.ArrayList;
import java.util.Random;
import java.util.Collections;


class FireFlies {
  ArrayList<FireFly> fireFlies = new ArrayList<FireFly>();
  PGraphics fg;
  ArrayList<Integer> colors = new ArrayList<Integer>();
  ArrayList<PVector[]> grass = new ArrayList<PVector[]>();
  float grassH = 1.8;
  int windDir = 1;
  float wind = 1;
  boolean grassOn = false;
  
  FireFlies(int w, int h) {
    for (int i = 0; i < 32; i++) {
      int range = (int)random(0,80);
      colors.add(color(255-range));
    }

    fg = createGraphics(w, h);
    hatch(100);
  }
  
  void hatch(int flies) {
    fireFlies.clear();
    for (int i = 0; i < flies; i++) {
      fireFlies.add(new FireFly(random(width), random(height)));
    }
  }
  
  void drawGrass() {
    int gStep = 10;
    fg.beginDraw();
    fg.clear();
    fg.fill(slideTint);
    fg.noStroke();
    float gH = height / grassH;
    
    for (int x = 0; x <= width; x += gStep) {
      fg.beginShape();
      fg.vertex(x, height-height/20);
      
      PVector[] blade;
      if (x/gStep >= grass.size()) {
        //Create the blades of grass on the first draw
        blade = new PVector[3];
        blade[0] = new PVector(random(-gH, gH), random(-gH/2, gH/2));
        blade[1] = new PVector(random(-gH, gH), random(-gH/2, gH/2));
        blade[2] = new PVector(x+random(-gH/2, gH/2), height-gH + random(-gH/4, gH/4));
        grass.add(blade);
      }
      else {
        blade = grass.get(x/gStep);
      }
      
      float xoff1 = blade[0].x;
      float yoff1 = blade[0].y;
      float xoff2 = blade[1].x;
      float yoff2 = blade[1].y;
      PVector tip = blade[2].copy();
      if (true) {
        tip.add(new PVector(wind+=(windDir*.005), 0));
        if (wind > 100 || wind < -100)
          windDir *= -1;
      }
      
      //fg.ellipse(tip.x, tip.y, 3, 3);
      fg.bezierVertex(x+xoff1, height-yoff1, x+xoff2, height-yoff2, tip.x, tip.y);
      fg.bezierVertex(x+xoff2+20, height-yoff2, x+xoff1+20, height-yoff1, x+20, height-height/20);  
      fg.endShape(CLOSE);
    }
    fg.endDraw();
  }
  
  void display(PGraphics frame) {
    if (true) {
      for (FireFly f : fireFlies) {
        f.update();
        f.relate();
        f.mutate();
        f.display(frame);
      }
    }

    if (grassOn) {
      drawGrass();
      frame.image(fg, 0, height / 10);
    }
  }
  
  class FireFly {
    PVector pos, vel, acc;
    int fcolor, lit;
    float angle;
  
    FireFly(float x, float y) {
      pos = new PVector(x, y);
      fcolor = colors.get(floor(random(colors.size())));
      vel = PVector.random2D();
      vel.mult(3.5);
      acc = PVector.random2D();
      acc.mult(0.01);
      lit = 0;
      angle = vel.heading();
    }
  
    void update() {
      acc.setMag(0.015);
      vel.add(acc);
      vel.limit(1);
      pos.add(vel);
      angle = vel.heading();
  
      if (pos.x < -10) {
        pos.x = width + 10;
      }
      if (pos.x > width + 10) {
        pos.x = -10;
      }
      if (pos.y < -10) {
        pos.y = height + 10;
      }
      if (pos.y > height + 10) {
        pos.y = -10;
      }
    }
  
    void relate() {
      for (FireFly other : fireFlies) {
        if (other == this) continue;
        float distance = PVector.dist(pos, other.pos);
        if (distance < 30) {
          if (lit > 50) {
            PVector force = PVector.sub(other.pos, pos);
            float forceMag = map(distance, 30, 0, 0.001, 0.01);
            force.setMag(forceMag);
            acc.add(force);
          }
          if (lit == 0 && distance < 20) {
            lit = 100;
          }
          if (lit == 100) {
            fcolor = lerpColor(fcolor, other.fcolor, random(0.1, 0.9));
          }
        }
      }
      if (lit == 1) {
        fcolor = lerpColor(fcolor, slideTint, random(0.5, 1.0));
      }
    }
  
    void mutate() {
      float r = random(1);
      if (r < 0.0002) {
        fcolor = colors.get((int)random(colors.size()));
      }
    }
  
    void display(PGraphics frame) {
      if (lit > 0) {
        lit--;
      }
      frame.pushMatrix();
      frame.translate(pos.x, pos.y);
      frame.rotate(angle);
      frame.noStroke();
      frame.fill(0);
      float colorAlpha = map(abs(lit - 50), 0, 50, 255, 0);
      int c1 = color(fcolor);
      c1 = (c1 & 0xFFFFFF) | (int(colorAlpha) << 24);
      frame.fill(c1);
      frame.ellipse(0, 0, 21, 19);
      frame.fill(fcolor);
      frame.fill(red(fcolor) - 50, green(fcolor) - 50, blue(fcolor) - 50, 55);
      //fill(0x88002200);
      frame.ellipse(0, 0, 7, 3);
      frame.popMatrix();
    }
  }
}
