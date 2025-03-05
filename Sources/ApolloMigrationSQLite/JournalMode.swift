import Foundation

public enum JournalMode: String {
  /// The rollback journal is deleted at the conclusion of each transaction. This is the default behaviour.
  case delete = "DELETE"
  /// Commits transactions by truncating the rollback journal to zero-length instead of deleting it.
  case truncate = "TRUNCATE"
  /// Prevents the rollback journal from being deleted at the end of each transaction. Instead, the header
  /// of the journal is overwritten with zeros.
  case persist = "PERSIST"
  /// Stores the rollback journal in volatile RAM. This saves disk I/O but at the expense of database
  /// safety and integrity.
  case memory = "MEMORY"
  /// Uses a write-ahead log instead of a rollback journal to implement transactions. The WAL journaling
  /// mode is persistent; after being set it stays in effect across multiple database connections and after
  /// closing and reopening the database.
  case wal = "WAL"
  /// Disables the rollback journal completely
  case off = "OFF"
}
