#include "os.h"

static __thread void* tls_txn_context;

void tls_set_txn_context(void* txn_context)
{
  tls_txn_context = txn_context;
}

void* tls_get_txn_context(void)
{
  return tls_txn_context;
}

static __thread void* tls_sqlite_snapshot;

void tls_set_sqlite_snapshot(void* snapshot)
{
  tls_sqlite_snapshot = snapshot;
}

void* tls_get_sqlite_snapshot(void)
{
  return tls_sqlite_snapshot;
}

