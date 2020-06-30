# MWMR

MWMR (multi-writer / multi-reader) is a desirable mode for local databases, the exactly one **Dflat** focuses on.

However, if you desire no conflict for a transaction, the multi-writer / multi-reader degrades to single-writer per table. This is what **Dflat** tries to offer. In simple words, **Dflat** makes sure each transaction closure operates on the same table executed serially. If they operate on different tables, they can be executed concurrently. That is the fundamental reason why you have to pledge which object types you want to operate upfront in `performChanges(_:)`. This is how [strict serializable](https://jepsen.io/consistency/models/strict-serializable) claim derived.

Is it really multi-writer with full concurrency, if we operate on different tables at the same time? Unfortunately, the answer is no, at the moment, with SQLite backend. It is related to the particular mode we operate with SQLite, the ["Write-Ahead Logging"](https://www.sqlite.org/wal.html).

To be precise, **Dflat** transaction closures for different tables operate concurrently, that fetch new objects, create new change requests, up until the first change request submitted. The first transaction closure that submitted the first change request will hold an exclusive lock to the end of that transaction closure, even if after the first submission, it only reads. Everyone else when submitting their change request, will be blocked until the first transaction closure finishes.

This is undesirable, but necessary due to SQLite WAL implementation. SQLite WAL implementation uses one WAL file, and writes in a transaction simply append to that log file. A rollback for a transaction simply means truncate the log file to an earlier point. Thus, once a write in a transaction happen, no writes from different transactions can be appended until the first transaction committed. Interleaving writes from different transactions, even for different tables, will make the rollback logic complicated (you almost certainly need to rewrite the log, which is a big no-no from original design perspective).

Alternatively, we can use one database file per table. However, this makes [cross table transaction non-atomic](https://sqlite.org/lang_attach.html). Fundamentally, this can only be fixed at SQLite level, possibly with multi-WAL files, which IMHO would be a no-go for SQLite.

Another alternative is to investigate other CoW (Copy-on-Write) data structure based databases, such as [libmdbx](https://github.com/erthink/libmdbx). Since these databases are key-value based, we also need to implement query execution logic for indexed queries ourselves rather than just generate SQL queries. This is simple enough and quite doable. But back to the MWMR situation we are trying to solve, I need to read more about how CoW data structure works and how it handles transaction rollbacks for cross table transactions (in key-value case, cross keyspace transactions) to make sure it is a viable long-term solution.

**There exists an effective but simple solution**: make sure in a transaction closure, you do all data transformations upfront, create or mutate all change requests, and then submit them towards the end of the transaction closure. It probably works best for everyone this way.
