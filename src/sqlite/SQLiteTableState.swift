// This is state shared by one table. However, since we will have a pivotal table,
// this state can end up be manipulated with multiple tables.
final class SQLiteTableState {
  var tableCreated = Set<ObjectIdentifier>()
}
