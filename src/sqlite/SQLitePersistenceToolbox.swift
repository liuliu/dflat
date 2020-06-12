import Dflat
import FlatBuffers

public final class SQLitePersistenceToolbox: PersistenceToolbox {
  public let connection: SQLiteConnection
  public var flatBufferBuilder = FlatBufferBuilder()
  init(connection: SQLiteConnection) {
    self.connection = connection
  }
}
