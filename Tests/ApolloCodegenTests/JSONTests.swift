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
  
  // MARK: Literals
  
  func testArrayLiteralWithoutNesting() {
    let jsonDict: JSONValue = [
      1,
      2.0,
      "string",
      true,
      nil,
    ]
    
    switch jsonDict {
    case .array(let jsonValues):
      XCTAssertEqual(jsonValues[0], .int(1))
      XCTAssertEqual(jsonValues[1], .double(2.0))
      XCTAssertEqual(jsonValues[2], .string("string"))
      XCTAssertEqual(jsonValues[3], .bool(true))
      XCTAssertEqual(jsonValues[4], .null)
    default:
      XCTFail("Array was not created!")
    }
  }
  
  func testDictionaryLiteralWithoutNesting() throws {
    let jsonDict: JSONValue = [
      "an_int": 1,
      "a_double": 2.0,
      "a_string": "string",
      "a_bool": true,
      "a_nil": nil,
    ]
    
    switch jsonDict {
    case .dictionary(let dict):
      XCTAssertEqual(dict.count, 5)
      XCTAssertEqual(dict["an_int"], .int(1))
      XCTAssertEqual(dict["a_double"], .double(2.0))
      XCTAssertEqual(dict["a_string"], .string("string"))
      XCTAssertEqual(dict["a_bool"], .bool(true))
      XCTAssertEqual(dict["a_nil"], .null)
    default:
      XCTFail("Dictionary was not created!")
    }
  }
  
  func testDictionaryLiteralWithNestedArray() throws {
    let jsonDictionary: JSONValue = [
      "a_boolean": true,
      "a_string": "Yep",
      "an_int": 42,
      "something_null": nil,
      "an_array": [
        "single",
        "type",
        "array",
        "here"
      ],
    ]
  
    switch jsonDictionary {
    case .dictionary(let dict):
      XCTAssertEqual(dict["a_boolean"], .bool(true))
      XCTAssertEqual(dict["a_string"], .string("Yep"))
      XCTAssertEqual(dict["an_int"], .int(42))
      XCTAssertEqual(dict["something_null"], .null)
      
      let nestedArray = try XCTUnwrap(dict["an_array"])
      switch nestedArray {
      case .array(let array):
        XCTAssertEqual(array[0], .string("single"))
        XCTAssertEqual(array[1], .string("type"))
        XCTAssertEqual(array[2], .string("array"))
        XCTAssertEqual(array[3], .string("here"))
      default:
        XCTFail("Failed to create nested array within dictionary")
      }
    default:
      XCTFail("Failed to create dictionary with nested array")
    }
  }
  
  func testArrayLiteralWithNestedDictionaries() throws {
    let arrayOfDictsJSON: JSONValue = [
        [
          "name": "George Michael",
          "colors": [
            "Gray"
          ],
          "type": "Cat"
        ],
        [
          "name": "Hank",
          "colors": [
            "Black",
            "White"
          ],
          "type": "Cat"
        ]
      ]
    
    switch arrayOfDictsJSON {
    case .array(let array):
      XCTAssertEqual(array.count, 2)
      let first = try XCTUnwrap(array.first)
      switch first {
      case .dictionary(let firstDict):
        XCTAssertEqual(firstDict["name"], .string("George Michael"))
        XCTAssertEqual(firstDict["colors"], .array([.string("Gray")]))
        // Or we can check equality with an array literal
        XCTAssertEqual(firstDict["colors"], ["Gray"])
        XCTAssertEqual(firstDict["type"], .string("Cat"))
      default:
        XCTFail("Could not get first dictionary in array")
      }
      
      let last = try XCTUnwrap(array.last)
      switch last {
      case .dictionary(let lastDict):
        XCTAssertEqual(lastDict["name"], .string("Hank"))
        XCTAssertEqual(lastDict["colors"], .array([.string("Black"), .string("White")]))
        // Or we can check equality with an array literal
        XCTAssertEqual(lastDict["colors"], ["Black", "White"])
        XCTAssertEqual(lastDict["type"], .string("Cat"))
      default:
        XCTFail("Could not get last dictionary in array")
      }
    default:
      XCTFail("Failed to create array with nested dictionaries")
    }
  }
  
  func testDictionaryLiteralWithNestedDictionary() throws {
    let dictJSON: JSONValue = [
      "a_boolean": true,
      "a_string": "Yep",
      "an_int": 42,
      "something_null": nil,
      "another_dictionary": [
        "a_double": 53.2
      ]
    ]
    
    switch dictJSON {
    case .dictionary(let dict):
      XCTAssertEqual(dict.count, 5)
      XCTAssertEqual(dict["a_boolean"], .bool(true))
      XCTAssertEqual(dict["a_string"], .string("Yep"))
      XCTAssertEqual(dict["an_int"], .int(42))
      XCTAssertEqual(dict["something_null"], .null)
      
      let innerDictionary = try XCTUnwrap(dict["another_dictionary"])
      switch innerDictionary {
      case .dictionary(let innerDict):
        XCTAssertEqual(innerDict.count, 1)
        XCTAssertEqual(innerDict["a_double"], .double(53.2))
      default:
        XCTFail("Couldn't create nested dictionary with in a dictionary literal")
      }
    default:
      XCTFail("Couldn't create dictionary literal with a nested dictionary")
    }
  }
  
  func testBooleanLiteralConversion() {
    let json: JSONValue = true
    
    switch json {
    case .bool(let value):
      XCTAssertTrue(value)
    default:
      XCTFail("Boolean literal conversion failed")
    }
  }
  
  func testIntegerLiteralConversion() {
    let json: JSONValue = 1
    switch json {
    case .int(let value):
      XCTAssertEqual(value, 1)
    default:
      XCTFail("Integer literal conversion failed")
    }
  }
  
  func testNilLiteralConversion() {
    let json: JSONValue = nil
    
    switch json {
    case .null:
      // This is what we want
      break
    default:
      XCTFail("Nil literal conversion failed")
    }
  }
  
  func testDoubleLiteralConversion() {
    let json: JSONValue = 23.7534123567
    
    switch json {
    case .double(let value):
      XCTAssertEqual(value, 23.7534123567, accuracy: 0.0000000000001)
    default:
      XCTFail("Double literal conversion failed")
    }
  }
  
  func testStringLiteralConversion() {
    let json: JSONValue = "Hello, Dave."
    
    switch json {
    case .string(let value):
      XCTAssertEqual(value, "Hello, Dave.")
    default:
      XCTFail("String literal conversion failed")
    }
  }
}
