default: main.d externals.d macros.c
	gdc main.d externals.d macros.c -lncurses
