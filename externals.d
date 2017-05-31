//The file with all the external C functions from ncurses.
extern(C) {
	struct WINDOW;
	WINDOW* initscr();
	int color_pair(int);
	int attr_on(int);
	int mvaddstr(int,int,const char*);
	int attr_off(int);
	int wresize(WINDOW*,int,int);
	int getch();
	void endwin();
	int start_color();
	int init_pair(short,short,short);
	void clear();
	int noecho();
	int curs_set(int);
}
