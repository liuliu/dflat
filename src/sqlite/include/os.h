
extern int open_dprotected_np(const char *path, int flags, int class, int dpflags, ...);

// Workaround Swift cannot call variadic function directly.
static inline int open_dprotected_np_sb(const char *path, int flags, int klass, int dpflags) {
  return open_dprotected_np(path, flags, klass, dpflags, 0666);
}
