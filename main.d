//The main file.


import externals;

interface Drawable { //An interface that represents a drawable object.
  void draw();
}

abstract class Position { //An abstract class that represents a position
  private int x;
  private int y;
  this(int x,int y) {
    this.x = x;
    this.y = y;
  }
  public int getX() {
    return this.x;
  }
  public void setX(int x) {
    this.x = x;
  }
  public int getY() {
    return this.y;
  }
  public void setY(int y) {
    return this.y;
  }
  public void moveLeft() {
    this.x -= 1;
  }
  public void moveRight() {
    this.x += 1;
  }
  public void moveUp() {
    this.y -= 1; //Weird co-ordinate system that ncurses uses. (0,0) is at the top left.
  }
  public void moveDown() {
    this.y += 1;
  }
}

void main() {
}
