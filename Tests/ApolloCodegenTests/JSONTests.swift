//
//  JSONTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 2/25/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import XCTest
import ApolloCodegenLib

class JSONTests: XCTestCase {
    
    func testSingleLevelDictionary() throws {
        let dictionaryString = """
{
    "a_boolean": true,
    "a_string": "Yep",
    "an_int": 42,
    "something_null": null,
    "a_double": 53.2
}
"""
        
        let value = try JSONValue(fromJSONString: dictionaryString)
        
        switch value {
        case .dictionary(let dictionary):
            let boolean = dictionary["a_boolean"]
            XCTAssertEqual(boolean, .bool(true))
            
            let string = dictionary["a_string"]
            XCTAssertEqual(string, .string("Yep"))
            
            let int = dictionary["an_int"]
            XCTAssertEqual(int, .int(42))
            
            let double = dictionary["a_double"]
            XCTAssertEqual(double, .double(53.2))
            
            let null = dictionary["something_null"]
            XCTAssertEqual(null, .null)
        default:
            XCTFail("Wrong type!")
        }
    }
    
    func testDictionaryWithNestedDictionary() throws {
        let dictionaryString = """
{
    "a_boolean": true,
    "a_string": "Yep",
    "an_int": 42,
    "something_null": null,
    "another_dictionary": {
        "a_double": 53.2
    }
}
"""
        
        let value = try JSONValue(fromJSONString: dictionaryString)
        
        switch value {
        case .dictionary(let dictionary):
            let boolean = dictionary["a_boolean"]
            XCTAssertEqual(boolean, .bool(true))
            
            let string = dictionary["a_string"]
            XCTAssertEqual(string, .string("Yep"))
            
            let int = dictionary["an_int"]
            XCTAssertEqual(int, .int(42))
            
            let null = dictionary["something_null"]
            XCTAssertEqual(null, .null)
            
            let dictionary = dictionary["another_dictionary"]
            XCTAssertEqual(dictionary, .dictionary([
              "a_double": .double(53.2)
            ]))
            
            let double = try value.valueForKeyPath([
                "another_dictionary",
                "a_double"
            ])
            XCTAssertEqual(double, .double(53.2))
        default:
            XCTFail("Wrong type!")
        }
    }
    
    
    func testDictionaryWithNestedArray() throws {
        let dictionaryString = """
{
    "a_boolean": true,
    "a_string": "Yep",
    "an_int": 42,
    "something_null": null,
    "an_array": [
        "single",
        "type",
        "array",
        "here"
    ]
}
"""
        let value = try JSONValue(fromJSONString: dictionaryString)
        
        switch value {
        case .dictionary(let dictionary):
            let boolean = dictionary["a_boolean"]
            XCTAssertEqual(boolean, .bool(true))
            
            let string = dictionary["a_string"]
            XCTAssertEqual(string, .string("Yep"))
            
            let int = dictionary["an_int"]
            XCTAssertEqual(int, .int(42))
            
            let null = dictionary["something_null"]
            XCTAssertEqual(null, .null)
            
            let array = dictionary["an_array"]
            let expectedArray: [JSONValue] = [
                .string("single"),
                .string("type"),
                .string("array"),
                .string("here")
            ]
            
            XCTAssertEqual(array, .array(expectedArray))
        default:
            XCTFail("Wrong type!")
        }
    }

    func testSingleLevelArray() throws {
        let arrayString = """
[
    "single",
    "type",
    "array",
    "here"
]
"""
        let value = try JSONValue(fromJSONString: arrayString)
        
        switch value {
        case .array(let values):
            XCTAssertEqual(values.count, 4)
            
            XCTAssertEqual(values[0], .string("single"))
            XCTAssertEqual(values[1], .string("type"))
            XCTAssertEqual(values[2], .string("array"))
            XCTAssertEqual(values[3], .string("here"))
        default:
            XCTFail("Wrong type!")
        }
    }
  
  func testArrayOfDictionaries() throws {
    let arrayOfDictionariesString = """
[
  {
    "name": "George Michael",
    "colors": [
      "Gray"
    ],
    "type": "Cat"
  },
  {
    "name": "Hank",
    "colors": [
      "Black",
      "White"
    ],
    "type": "Cat"
  }
]
"""
    let value = try JSONValue(fromJSONString: arrayOfDictionariesString)

    switch value {
    case .array(let array):
      XCTAssertEqual(array.count, 2)
      
      let georgie = JSONValue.dictionary([
        "name": .string("George Michael"),
        "colors": .array([
                    .string("Gray")
                  ]),
        "type": .string("Cat")
      ])
      
      let hank = JSONValue.dictionary([
        "name": .string("Hank"),
        "colors": .array([
                    .string("Black"),
                    .string("White")
                  ]),
        "type": .string("Cat")
      ])
      
      XCTAssertEqual(array, [georgie, hank])
    default:
      XCTFail("Incorrect type")
    }
  }
}
