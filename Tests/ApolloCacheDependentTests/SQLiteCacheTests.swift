import Foundation
import ApolloTestSupport
import ApolloSQLiteTestSupport

class SQLiteFetchQueryTests: FetchQueryTests {
  override var cacheType: TestCacheProvider.Type {
    SQLiteTestCacheProvider.self
  }
}

class SQLiteLoadQueryFromStoreTests: LoadQueryFromStoreTests {
  override var cacheType: TestCacheProvider.Type {
    SQLiteTestCacheProvider.self
  }
}

class SQLiteStarWarsServerCachingRoundtripTests: StarWarsServerCachingRoundtripTests {
  override var cacheType: TestCacheProvider.Type {
    SQLiteTestCacheProvider.self
  }
}

class SQLiteStarWarsServerAPQsGetMethodTests: StarWarsServerAPQsGetMethodTests {
  override var cacheType: TestCacheProvider.Type {
    SQLiteTestCacheProvider.self
  }
}

class SQLiteStarWarsServerAPQsTests: StarWarsServerAPQsTests {
  override var cacheType: TestCacheProvider.Type {
    SQLiteTestCacheProvider.self
  }
}

class SQLiteStarWarsServerTests: StarWarsServerTests {
  override var cacheType: TestCacheProvider.Type {
    SQLiteTestCacheProvider.self
  }
}

class SQLiteReadWriteFromStoreTests: ReadWriteFromStoreTests {
  override var cacheType: TestCacheProvider.Type {
    SQLiteTestCacheProvider.self
  }
}

class SQLiteWatchQueryTests: WatchQueryTests {
  override var cacheType: TestCacheProvider.Type {
    SQLiteTestCacheProvider.self
  }
}
