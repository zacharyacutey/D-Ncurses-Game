//The main file.


import externals;
import std.stdio;
import std.string;
import std.conv;

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
  private Player player; //I have to use player, since it has the draw method.
  private int width;
  private int height;
  this(Player player,int width,int height) {
    this.player = player;
    this.width = width;
    this.height = height;
  }
  public void moveLeft() {
    this.player.moveLeft();
    if(this.player.getX() < 1) {
      this.player.setX(1);
    }
  }
  public void moveRight() {
    this.player.moveRight();
    if(this.player.getX() >= this.width - 1) {
      this.player.setX(this.width - 2);
    }
  }
  public void moveUp() {
    this.player.moveUp();
    if(this.player.getY() < 1) {
      this.player.setY(1);
    }
  }
  public void moveDown() {
    this.player.moveDown();
    if(this.player.getY() >= this.height - 1) {
      this.player.setY(this.height - 2);
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
    } else {
      return this.handleInput();
    }
    clear(); //Hacky, sort of
    this.player.draw();
    return true;
  }
}

class Game { 
  private Player player;
  private int width;
  private int height;
  private Obstacle[] obstacles;
  private InputHandler inputHandler;
  private Hint[][] turns;
  this(Player player,int width,int height) {
    this.player = player;
    this.width = width;
    this.height = height;
    this.obstacles = [];
    this.inputHandler = new InputHandler(player,width,height);
    this.turns = [];
  }
  public int getWidth() {
    return this.width;
  }
  public int getHeight() {
    return this.height;
  }
  public void addObstacle(Obstacle o) {
    this.obstacles ~= o;
  }
  public void clearObstacles() {
    this.obstacles = [];
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
  public void addTurn(Hint[] h) {
    this.turns ~= h;
  }
  public void doHints() {
    if(turns.length == 0) {
      return;
    }
      
    Hint[] tmp;
    for(int i = 0;i < this.turns[0].length;i++) {
      if(this.turns[0][i].getDurability() != 0) {
        this.turns[0][i].update(this);
        this.turns[0][i].draw();
        tmp ~= this.turns[0][i];
      }
    }
    if(this.turns.length > 1) {
      for(int i = 0;i < this.turns[1].length;i++) {
        this.turns[1][i].warn();
      }
    }
    if(this.turns.length == 1) {
      this.turns = [tmp];
    } else if(this.turns.length == 2) {
      this.turns = [tmp~this.turns[1]];
    } else {
      this.turns = [tmp~this.turns[1]]~this.turns[2 .. $];
    }
  }
  public void play() {
    WINDOW* w = initscr();
    start_color();
    noecho();
    curs_set(0);
    init_pair(short(1),short(0),short(1)); //Foreground := Black, Background := Red - Obstacle
    init_pair(short(2),short(1),short(0)); //Foreground := Red, Background := Black - Player
    wresize(w,this.height,this.width);
    box(w,0,0);
    this.clearObstacles();
    this.doHints();
    this.drawObstacles();
    this.player.draw();
    while(this.inputHandler.handleInput() && this.uncollided()) {
      box(w,0,0);
      this.clearObstacles();
      this.doHints();
      if(!this.uncollided()) break;
      this.drawObstacles();
    }
    endwin();
  }
}

interface Hint : Drawable {
  public void update(Game g); //Updates the hint, and adds obstacles to the Game g.
  public int getDurability();
  public void warn();
}


class HorizontalLaser : Hint {
  private int durability;
  private int y;
  this(int durability,int y) {
    this.durability = durability;
    this.y = y;
  }
  public int getDurability() {
    return this.durability;
  }
  public void draw() {
    mvaddstr(this.y,0,std.string.toStringz(to!string(this.durability)));
  }
  public void update(Game g) {
    for(int x = 1;x < g.getWidth()-1;x++) {
      g.addObstacle(new Obstacle(x,this.y));
    }
    this.durability -= 1;
    this.draw();
  }
  public void warn() {
    mvaddstr(this.y,0,std.string.toStringz("!"));
  }
}

class VerticalLaser : Hint {
  private int durability;
  private int x;
  this(int durability,int x) {
    this.durability = durability;
    this.x = x;
  }
  public int getDurability() {
    return this.durability;
  }
  public void draw() {
    mvaddstr(0,this.x,std.string.toStringz(to!string(this.durability)));
  }
  public void update(Game g) {
    for(int y = 1;y < g.getHeight()-1;y++) {
      g.addObstacle(new Obstacle(this.x,y));
    }
    this.durability -= 1;
    this.draw();
  }
  public void warn() {
    mvaddstr(0,this.x,std.string.toStringz("!"));
  }
}


void main() { //This is my testing for now, I know D has unittest, but I have no idea how to do that with ncurses!
  Player p = new Player(1,1);
  Game g = new Game(p,20,20);
  g.addTurn([]);
  for(int i = 1;i < 18;i++) {
    g.addTurn([new VerticalLaser(10,i)]);
  }
  for(int i = 1;i < 18;i++) {
    g.addTurn([new HorizontalLaser(10,i)]);
  }
  for(int i = 18;i > 1;i--) {
    g.addTurn([new VerticalLaser(10,i)]);
  }
  for(int i = 18;i > 1;i--) {
    g.addTurn([new HorizontalLaser(3,i)]);
  }
  g.addTurn([new VerticalLaser(2,1)]);
  g.addTurn([new VerticalLaser(1,4),new VerticalLaser(3,5)]);
  g.addTurn([new VerticalLaser(1,3)]);
  g.addTurn([new HorizontalLaser(1,1)]);
  g.addTurn([new VerticalLaser(1,1),new VerticalLaser(1,2)]);
  g.addTurn([new HorizontalLaser(1,1),new HorizontalLaser(1,2)]);
  g.addTurn([new VerticalLaser(1,3)]);
  g.addTurn([new VerticalLaser(1,4),new VerticalLaser(1,5)]);
  g.addTurn([new VerticalLaser(10,1),new VerticalLaser(10,2)]);
  g.addTurn([new HorizontalLaser(10,3),new HorizontalLaser(10,4),new HorizontalLaser(10,5)]);
  g.addTurn([cast(Hint)new VerticalLaser(1,4),cast(Hint)new VerticalLaser(1,3)]);
  for(int i = 5;i<18;i++) {
    g.addTurn([new VerticalLaser(1,i)]);
  }
  g.play();
}
