class Sprite
{
  PVector position;
  PVector offset;
  float _width;
  float _height;
  
  Sprite(float x, float y, float w, float h) {
    position = new PVector(x, y);
    offset = new PVector(0, 0);
    _width = w;
    _height = h;
  }

  boolean mouseIn() {
    PVector pos = location();
    
    if (mouseX >= pos.x &&
        mouseX <= pos.x + _width &&
        mouseY >= pos.y &&
        mouseY <= pos.y + _height)
      return true;

    return false;
  }

  void update() {}
  void display() {}
  
  PVector location() {
    return position.copy().add(offset);
  }
  
  PVector center() {
    return new PVector(location().x + _width/2, location().y + _height/2);
  }
  
  float mouseProximity() {
    PVector c = center();
    float distance = dist(c.x, c.y, mouseX, mouseY);
    return distance;
  }
}
