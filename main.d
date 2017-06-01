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

class InputHandler {
  private Player position; //I have to use player, since it has the draw method.
  private int width;
  private int height;
  this(Player position,int width,int height) {
    this.position = position;
    this.width = width;
    this.height = height;
  }
  public void moveLeft() {
    this.position.moveLeft();
    if(this.position.getX() < 0) {
      this.position.setX(0);
    }
  }
  public void moveRight() {
    this.position.moveRight();
    if(this.position.getX() >= this.width) {
      this.position.setX(this.width - 1);
    }
  }
  public void moveUp() {
    this.position.moveUp();
    if(this.position.getY() < 0) {
      this.position.setY(0);
    }
  }
  public void moveDown() {
    this.position.moveDown();
    if(this.position.getY() >= this.height) {
      this.position.setY(this.height - 1);
    }
  }
  public bool handleInput() {
    int u = getch();
    char c = cast(char)u;
    if(c == 'a') {
      this.moveLeft();
    } else if(c == 'd') {
      this.moveRight();
    } else if(c == 'w') {
      this.moveUp();
    } else if(c == 's') {
      this.moveDown();
    } else if(u == 3) {
      return false;
    }
    clear(); //Hacky, sort of
    this.position.draw();
    return true;
  }
}

class Game { 
  private Player player;
  private int width;
  private int height;
  private Obstacle[] obstacles;
  private InputHandler inputHandler;
  this(Player player,int width,int height) {
    this.player = player;
    this.width = width;
    this.height = height;
    this.obstacles = [];
    this.inputHandler = new InputHandler(player,width,height);
  }
  public void addObstacle(Obstacle o) {
    this.obstacles ~= o;
  }
  public bool uncollided() {
    for(int i = 0;i < this.obstacles.length;i++) {
      if(this.obstacles[i].getX() == this.player.getX() && this.obstacles[i].getY() == this.player.getY()) {
        return false;
      }
    }
    return true;
  }
  public void drawObstacles() {
    for(int i = 0;i < this.obstacles.length;i++) {
      this.obstacles[i].draw();
    }
  }
  public void play() {
    WINDOW* w = initscr();
    start_color();
    noecho();
    curs_set(0);
    init_pair(short(1),short(0),short(1)); //Foreground := Black, Background := Red - Obstacle
    init_pair(short(2),short(1),short(0)); //Foreground := Red, Background :- Black - Player
    wresize(w,this.height,this.width);
    while(this.inputHandler.handleInput() && this.uncollided()) {
      this.drawObstacles();
    }
    endwin();
  }
}

void main() { //This is my testing for now, I know D has unittest, but I have no idea how to do that with ncurses!

  Obstacle o = new Obstacle(2,2);
  Player p = new Player(3,3);
  Game g = new Game(p,20,20);
  g.addObstacle(o);
  g.play();
}
