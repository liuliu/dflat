#if os(Linux)

  import XCTest

  XCTMain([
    testCase(ConcurrencyTests.allTests),
    testCase(ExprTests.allTests),
    testCase(FetchTests.allTests),
    testCase(ObjectRepositoryTests.allTests),
    testCase(SchemaUpgradeTests.allTests),
    testCase(SQLiteWorkspaceCRUDTests.allTests),
    testCase(SerialTests.allTests),
    testCase(SubscribeTests.allTests),
    testCase(DictionaryTests.allTests),
  ])

#endif
