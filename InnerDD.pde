int curlSpan = 0;
ArrayList<Particle> particles = new ArrayList<Particle>();
class InnerDD {
 
  InnerDD() {
    spawn(10);
  }
  
  void spawn(int numP) {
    color[] colors = new color[2];
    colors[0] = palette.get("lightGreen");
    colors[1] = palette.get("darkGreen");
    
    curlSpan = int(random(50, 100));
    particles.clear();
    for (int i = 0; i < numP; i++) {
      color pc = lerpColor(colors[0], colors[1], random(1)); //colors[(int)random(2)];
      particles.add(new Particle(new PVector(width/2, height/2).add(new PVector(-5, 5)),
        new PVector(0, 3.5).rotate(i * PI * 2 / numP),
        pc,
        random(20, 40)
      ));
    }
  }
  
  void display(PGraphics frame) {
    ArrayList<Particle> spawns = new ArrayList<Particle>();
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      p.draw(frame);
      if (!p.alive) {
        particles.remove(i);
        color pc = p.pColor;//color(255, random(105, 255), random(180, 255), 255);
        spawns.add(new Particle(new PVector(width/2, height/2).add(new PVector(-5, 5)),p.ov.mult(2), pc, random(5, 10)));
        p = null;
      }
    }
    
    if (particles.size() < 400)
      particles.addAll(spawns);
    else
      spawns.clear();
  }
}
