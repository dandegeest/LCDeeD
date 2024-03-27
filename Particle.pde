static int innerDDieMode = 2;
static boolean connected = false;
  
class Particle {
  PVector p, v, a;
  float r, rFac;
  int copySpan, z;
  color pColor;
  boolean alive;
  PVector lastP;
  PVector ov;
  float radius = 5;

  
  Particle(PVector p, PVector v, color c, float r) {
    this.p = p.copy();
    this.v = v.copy();
    this.ov = v.copy();
    this.a = new PVector(0, 0);
    this.r = random(1, 2);
    this.rFac = random(0.994, 0.995);
    this.copySpan = int(random(20, 90));
    this.z = 0;
    this.pColor = c;//colors[int(random(colors.length))];
    this.alive = true;
    radius = r;
  }
  
  void update() {
    lastP = p.copy();
    p.add(v);
    v.add(a);
    
    if (innerDDieMode == 2 && (frameCount % copySpan == 0 && r > 0.5 && random(1) < 0.6 && z < 5)) {
      particles.add(new Particle(p.copy(), v.copy().rotate(0.1), pColor, random(5,10)));
      alive = false;
    }

    if (innerDDieMode == 1 && (lastP.x == p.x || lastP.y == p.y)) {
      alive = false;
    }
    
    v.x += sin(p.x/20 + p.x/curlSpan) / 10 / (r+0.1) / 2;
    v.y += cos(p.y/10 + p.x/80) / 10 / (r+0.1) / 2;
    
    v.y += sin(p.x/20 + p.x/curlSpan) / -10 / (r+0.1) / 40;
    v.x += cos(p.y/10 + p.x/5) / -10 / (r+0.1) / 40;
    r *= rFac;
    v.mult(0.995);
    
    v.rotate(sin(frameCount/10 + p.x/50 + p.y/10) / (r*r + 0.01) / 500);
    radius += .1;
  }
  
  void draw(PGraphics frame) {
    frame.pushStyle();
    color c = pColor;
    c = c << (int)random(100, 255);
    frame.noFill();
    frame.strokeWeight(1);
    frame.stroke(c);
    frame.ellipse(p.x, p.y, radius, radius);
    if (connected)
      frame.bezier(width/2, height/2, lastP.x, lastP.y, random(width), random(height), p.x, p.y);
    frame.popStyle();
  }
}
