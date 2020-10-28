
extern int open_dprotected_np(const char *path, int flags, int class, int dpflags, ...);

// Workaround Swift cannot call variadic function directly.
static inline int open_dprotected_np_sb(const char *path, int flags, int klass, int dpflags) {
  return open_dprotected_np(path, flags, klass, dpflags, 0666);
}

extern void tls_set_txn_context(void* txn_context);
extern void* tls_get_txn_context(void);

extern void tls_set_sqlite_snapshot(void* snapshot);
extern void* tls_get_sqlite_snapshot(void);

