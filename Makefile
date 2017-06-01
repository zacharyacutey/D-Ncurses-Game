ifneq ($(t), gravity)
default: main.d externals.d macros.c
	gdc main.d externals.d macros.c -lncurses
else
gravity: gravity.d externals.d macros.c
	gdc gravity.d externals.d macros.c -lncurses
endif
