# Rowid & ChangesTimestamp

There are two Int64 abstractions leaked in **Dflat**: rowid and changes timestamp. I will discuss what them are, and why they leaked. Both of them are powerful enough to make the abstraction leakage worthy.

## Rowid

This is leaked from underlying SQLite backend. We elected for rowid to be a 64-bit monotonically increment integer that uniquely identify an object. Because it is monotonically incremented, old rowid won't be reused by new object. This helps in multiple fronts:

 1. We can uniquely identify an object, even if it is deleted later, without worrying a new object could occupy the same rowid;

 2. We could quickly check whether an index (we index a field with a different table) up-to-date or not by comparing `MAX(rowid)` from both main table and the index table. This is a very cheap operation and free of problems such as object deletion (if we naively use `COUNT(rowid)`, it could match because the index table hasn't caught up with main table while main table deleted some items).

If in the future, we moved to the other backends, rowid as a concept could still survive, due to benefits listed above.

## ChangesTimestamp

This is not a persisted property. It is an monotonically increment integer increments every time a transaction committed. Any data fetch will associate a changesTimestamp atomically fetched. This helps quickly check whether an object or a fetched result could change after the time when it is fetched. This is used for changes subscription.

If the atomic load / store becomes a bottle-neck, we may need to re-think how we do this in the future, possibly store them in thread-local manner and only propagate updates once for a while. It is unlikely though.
