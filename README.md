# D-Ncurses-Game
A game using NCurses &amp; GDC.

Uses the fact of gdc's relation to gcc [You can pass the `-lncurses` option to gdc, using `extern(C)` on D's side]

Compile with `gdc main.d externals.d macros.c -lncurses`
