import std.string;
import std.stdio;
import std.conv;

extern(C) {
	struct WINDOW;
	WINDOW* initscr();
	int color_pair(int);
	int attr_on(int);
	int mvaddstr(int,int,inout char*);
	int attr_off(int);
	int wresize(WINDOW*,int,int);
	int getch();
	void endwin();
	int start_color();
	int init_pair(short,short,short);
	void clear();
	int noecho();
	int echo();
	int curs_set(int);
	int box(WINDOW*,int,int);
        int getnstr(inout char*,int); //Still, have no idea how this works ...
	char get_vline();
}

enum : int { BLACK, RED, GREEN, YELLOW, MAGENTA, CYAN, WHITE }



int find(T)(T[] array,T item) {
	for(int i = 0;i < array.length;i++) {
		if(array[i] == item) { return i; }
	}
	return -1;
}





class Window {
	private WINDOW* screen;
	private int pair;
	this(int lines,int columns,int[2][] colors=[]) {
		this.screen = initscr();
		start_color();
		wresize(this.screen,lines,columns);
		for(int i=0;i<colors.length;i++) {
			init_pair(to!short(i+1),to!short(colors[i][0]),to!short(colors[i][1]));
		}
	}
	public void resize(int lines, int columns) {
		wresize(this.screen,lines,columns);
	}
	public char getch() {
		return cast(char)(.getch());
	}
	public void endwin() {
		.endwin();
	}
	public void moveTo(int x,int y) {
		mvaddstr(y,x,toStringz(""));
	}
	public void writeAt(string arg,int x,int y) {
		mvaddstr(y,x,toStringz(arg));
	}
	public string read(int size) {
		//I have no idea how this works, but it does. So note to self: leave it alone
		char[] t;
		const char* s = toStringz(t);
		getnstr(s,size);
		return to!string(fromStringz(s));
	}
	public void clear() {
		.clear();
	}
	public void cursorOff() {
		curs_set(0);
	}
	public void cursorOn() {
		curs_set(1);
	}
	public void echoOff() {
		noecho();
	}
	public void echoOn() {
		echo();
	}
	public void usePair(int pair) {
		attr_off(color_pair(this.pair));
		this.pair = pair;
		attr_on(color_pair(this.pair));
	}
	public void useDefault() {
		attr_off(color_pair(this.pair));
	}
}	

class MenuOption {
	private string text;
	public Window w;
	private int offColor;
	private int onColor;
	private int x;
	private int y;
	this(Window w,int x,int y,string text,int offColor,int onColor) {
		this.w = w;
		this.x = x;
		this.y = y;
		this.text = text;
		this.offColor = offColor;
		this.onColor = onColor;
	}
	public void draw(bool state) {
		w.usePair(state ? onColor : offColor);
		w.writeAt(text,x,y);
		w.useDefault();
	}
}

class Menu(T) {
	private MenuOption[] options;
	private char[] keys;
	private T[] values; 
	this(MenuOption[] options,char[] keys,T[] values) {
		this.options = options;
		this.keys = keys;
		this.values = values;
		this.options[0].w.cursorOff();
		this.options[0].w.echoOff();
	}
	public void highlight(char c) {
		for(int i = 0; i < options.length; i++) {
			 this.options[i].draw(c == this.keys[i]);
		}
	}
	public T select() {
		Window w = this.options[0].w;
		char c = '\n';
		while(true) {
			this.highlight(c);
			char tmp = w.getch();
			if ( tmp == '\n' ) {
				break;
			}
			c = tmp;
		}
		return this.values[this.keys.find!char(c)];
	}
}
void main() {
}
