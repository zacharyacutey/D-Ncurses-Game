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
  int getX() {
    return this.x;
  }
  void setX(int x) {
    this.x = x;
  }
  int getY() {
    return this.y;
  }
  void setY(int y) {
    return this.y;
  }
  void moveLeft() {
    this.x -= 1;
  }
  void moveRight() {
    this.x += 1;
  }
  void moveUp() {
    this.y -= 1; //Weird co-ordinate system that ncurses uses. (0,0) is at the top left.
  }
  void moveDown() {
    this.y += 1;
  }
}

void main() {
}
