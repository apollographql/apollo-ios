import XCTest
@testable import Apollo
import ApolloTestSupport
import StarWarsAPI

class DataLoaderTests: XCTestCase {
  func testSingleLoad() throws {
    let loader = DataLoader<Int, Int> { keys in
      return self.resultsForKeys(keys)
    }
    
    XCTAssertEqual(try loader[1].get(), 1)
  }
  
  func testMultipleLoads() throws {
    var numberOfBatchLoads = 0
    
    let loader = DataLoader<Int, Int> { keys in
      numberOfBatchLoads += 1
      return self.resultsForKeys(keys)
    }
        
    let promises = [loader[1], loader[2]]
    let values = try promises.map { try $0.get() }
    
    XCTAssertEqual(values, [1, 2])
    XCTAssertEqual(numberOfBatchLoads, 1)
  }
  
  func testCoalescesIdenticalRequests() throws {
    var batchLoads: [Set<Int>] = []
    
    let loader = DataLoader<Int, Int> { keys in
      batchLoads.append(keys)
      return self.resultsForKeys(keys)
    }
        
    let promises = [loader[1], loader[1]]
    let values = try promises.map { try $0.get() }
    
    XCTAssertEqual(values, [1, 1])
    XCTAssertEqual(batchLoads.count, 1)
    XCTAssertEqual(batchLoads[0], [1])
  }
  
  func testCachesRepeatedRequests() throws {
    var batchLoads: [Set<String>] = []
    
    let loader = DataLoader<String, String> { keys in
      batchLoads.append(keys)
      return self.resultsForKeys(keys)
    }
        
    let promises1 = [loader["A"], loader["B"]]
    let values1 = try promises1.map { try $0.get() }
    
    XCTAssertEqual(values1, ["A", "B"])
    XCTAssertEqual(batchLoads.count, 1)
    XCTAssertEqualUnordered(batchLoads[0], ["A", "B"])
        
    let promises2 = [loader["A"], loader["C"]]
    let values2 = try promises2.map { try $0.get() }
    
    XCTAssertEqual(values2, ["A", "C"])
    XCTAssertEqual(batchLoads.count, 2)
    XCTAssertEqual(batchLoads[1], ["C"])
    
    let promises3 = [loader["A"], loader["B"], loader["C"]]
    let values3 = try promises3.map { try $0.get() }

    XCTAssertEqual(values3, ["A", "B", "C"])
    XCTAssertEqual(batchLoads.count, 2)
  }
  
  // - Helpers
  
  private func resultsForKeys<Key>(_ keys: Set<Key>) -> [Key: Key] {
    return keys.reduce(into: [:]) { result, key in
      result[key] = key
    }
  }
}
