//The main file.


import externals;
import std.string;

interface Drawable { //An interface that represents a drawable object.
  public void draw();
}

abstract class Position { //An abstract class that represents a position
  private int x;
  private int y;
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
    this.y = y;
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
  public bool opEquals(Position rhs) {
    return this.getX() == rhs.getX() && this.getY() == rhs.getY();
  }
}

class Obstacle : Position, Drawable {
  this(int x,int y) {
    this.x = x;
    this.y = y;
  }
  public void draw() {
    attr_on(color_pair(1)); //Turn color on.
    mvaddstr(this.getY(),this.getX(),std.string.toStringz(" ")); //Draw.
    attr_off(color_pair(1)); //Turn color off.
  }
}

class Player : Position, Drawable {
  this(int x,int y) {
    this.x = x;
    this.y = y;
  }
  public void draw() {
    attr_on(color_pair(2)); //Turn color on.
    mvaddstr(this.getY(),this.getX(),std.string.toStringz("o")); //Draw.
    attr_off(color_pair(2)); //Turn color off.
  }
}

void main() {
  WINDOW* w = initscr();
  start_color();
  noecho();
  curs_set(0);
  init_pair(short(1),short(0),short(1)); //Foreground := Black, Background := Red - Obstacle
  init_pair(short(2),short(1),short(0)); //Foreground := Red, Background :- Black - Player
  wresize(w,20,20);
  Obstacle o = new Obstacle(2,2);
  Player p = new Player(3,3);
  o.draw();
  p.draw();
  getch();
  p.moveLeft();
  getch();
  o.draw();
  p.draw();
  getch();
  endwin();
}
