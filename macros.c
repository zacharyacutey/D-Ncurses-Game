//The file containing wrapper functions around macros, since D doesn't have macros.
#include <ncurses.h>
int color_pair(int n) {
	return COLOR_PAIR(n);
}
