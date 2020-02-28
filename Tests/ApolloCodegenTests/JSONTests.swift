//
//  JSONTests.swift
//  ApolloCodegenTests
//
//  Created by Ellen Shapiro on 2/25/20.
//  Copyright © 2020 Apollo GraphQL. All rights reserved.
//

import XCTest
import ApolloCodegenLib

class JSONContainerTests: XCTestCase {
    
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
        
        let container = try JSONContainer(fromJSONString: dictionaryString)
        
        switch container.value {
        case .dictionary:
            let boolean = try container.value(for: "a_boolean")
            XCTAssertEqual(boolean, .bool(true))
            
            let string = try container.value(for: "a_string")
            XCTAssertEqual(string, .string("Yep"))
            
            let int = try container.value(for: "an_int")
            XCTAssertEqual(int, .int(42))
            
            let double = try container.value(for: "a_double")
            XCTAssertEqual(double, .double(53.2))
            
            let null = try container.value(for: "something_null")
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
        
        let container = try JSONContainer(fromJSONString: dictionaryString)
        
        switch container.value {
        case .dictionary:
            let boolean = try container.value(for: "a_boolean")
            XCTAssertEqual(boolean, .bool(true))
            
            let string = try container.value(for: "a_string")
            XCTAssertEqual(string, .string("Yep"))
            
            let int = try container.value(for: "an_int")
            XCTAssertEqual(int, .int(42))
            
            let null = try container.value(for: "something_null")
            XCTAssertEqual(null, .null)
            
            let dictionary = try container.value(for: "another_dictionary")
            XCTAssertEqual(dictionary, JSONValue.dictionary(["a_double": JSONContainer(value: JSONValue.double(53.2))]))
            
            let double = try container.valueForKeyPath(keyPath: [
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
        let container = try JSONContainer(fromJSONString: dictionaryString)
        
        switch container.value {
        case .dictionary:
            let boolean = try container.value(for: "a_boolean")
            XCTAssertEqual(boolean, .bool(true))
            
            let string = try container.value(for: "a_string")
            XCTAssertEqual(string, .string("Yep"))
            
            let int = try container.value(for: "an_int")
            XCTAssertEqual(int, .int(42))
            
            let null = try container.value(for: "something_null")
            XCTAssertEqual(null, .null)
            
            let array = try container.value(for: "an_array")
            let expectedArray = [
                JSONContainer(value: .string("single")),
                JSONContainer(value: .string("type")),
                JSONContainer(value: .string("array")),
                JSONContainer(value: .string("here"))
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
        let container = try JSONContainer(fromJSONString: arrayString)
        
        switch container.value {
        case .array(let containers):
            XCTAssertEqual(containers.count, 4)
            
            XCTAssertEqual(containers[0], JSONContainer(value: .string("single")))
            XCTAssertEqual(containers[1], JSONContainer(value: .string("type")))
            XCTAssertEqual(containers[2], JSONContainer(value: .string("array")))
            XCTAssertEqual(containers[3], JSONContainer(value: .string("here")))
        default:
            XCTFail("Wrong type!")
        }
    }
}
