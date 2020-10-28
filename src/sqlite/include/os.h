
// Workaround Swift cannot call variadic function directly.
extern int open_dprotected_np(const char *path, int flags, int klass, int dpflags, int mode);

