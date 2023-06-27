import XCTest
import Nimble
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

class GETTransformerTests: XCTestCase {
  private var requestBodyCreator: ApolloRequestBodyCreator!
  private static let url = TestURL.mockPort8080.url

  override func setUp() {
    super.setUp()

    requestBodyCreator = ApolloRequestBodyCreator()
  }

  override func tearDown() {
    requestBodyCreator = nil

    super.tearDown()
  }

  private enum MockEnum: String, EnumType {
    case LARGE
    case AVERAGE
    case SMALL
  }

  func test__createGetURL__queryWithSingleParameterAndVariable_encodesURL() {
    class GivenMockOperation: MockOperation<MockSelectionSet> {
      override class var operationName: String { "TestOpName" }
      override class var operationDocument: OperationDocument {
        .init(definition: .init(
        """
        query MockQuery($param: String) {
          testField(param: $param) {
            __typename
            name
          }
        }
        """))
      }
    }

    let operation = GivenMockOperation()
    operation.__variables = ["param": "TestParamValue"]

    let body = requestBodyCreator.requestBody(for: operation,
                                              sendQueryDocument: true,
                                              autoPersistQuery: false)
    
    let transformer = GraphQLGETTransformer(body: body, url: Self.url)
    
    let url = transformer.createGetURL()
    
    let expected = "http://localhost:8080/graphql?operationName=TestOpName&query=query%20MockQuery($param:%20String)%20%7B%0A%20%20testField(param:%20$param)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22param%22:%22TestParamValue%22%7D"

    expect(url?.absoluteString).to(equal(expected))
  }

  func test__createGetURL__query_withEnumParameterAndVariable_encodesURL() {
    class GivenMockOperation: MockOperation<MockSelectionSet> {
      override class var operationName: String { "TestOpName" }
      override class var operationDocument: OperationDocument {
        .init(definition: .init(
        """
        query MockQuery($param: MockEnum) {
          testField(param: $param) {
            __typename
            name
          }
        }
        """))
      }
    }

    let operation = GivenMockOperation()
    operation.__variables = ["param": MockEnum.LARGE]

    let body = requestBodyCreator.requestBody(for: operation,
                                              sendQueryDocument: true,
                                              autoPersistQuery: false)

    let transformer = GraphQLGETTransformer(body: body, url: Self.url)

    let url = transformer.createGetURL()

    let expected = "http://localhost:8080/graphql?operationName=TestOpName&query=query%20MockQuery($param:%20MockEnum)%20%7B%0A%20%20testField(param:%20$param)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22param%22:%22LARGE%22%7D"

    expect(url?.absoluteString).to(equal(expected))
  }
  
  func test__createGetURL__queryWithMoreThanOneParameter_withIncludeDirective_encodesURL() throws {
    class GivenMockOperation: MockOperation<MockSelectionSet> {
      override class var operationName: String { "TestOpName" }
      override class var operationDocument: OperationDocument {
        .init(definition: .init(
        """
        query MockQuery($a: String, $b: Boolean!) {
          testField(param: $a) {
            __typename
            nestedField @include(if: $b)
          }
        }
        """))
      }
    }

    let operation = GivenMockOperation()
    operation.__variables = ["a": "TestParamValue", "b": true]

    let body = requestBodyCreator.requestBody(for: operation,
                                              sendQueryDocument: true,
                                              autoPersistQuery: false)
    
    let transformer = GraphQLGETTransformer(body: body, url: Self.url)
    
    let url = transformer.createGetURL()

    let expected = "http://localhost:8080/graphql?operationName=TestOpName&query=query%20MockQuery($a:%20String,%20$b:%20Boolean!)%20%7B%0A%20%20testField(param:%20$a)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20nestedField%20@include(if:%20$b)%0A%20%20%7D%0A%7D&variables=%7B%22a%22:%22TestParamValue%22,%22b%22:true%7D"

    expect(url?.absoluteString).to(equal(expected))
  }
  
  func test__createGetURL__queryWith2DParameter_encodesURL_withBodyComponentsInAlphabeticalOrder() throws {
    class GivenMockOperation: MockOperation<MockSelectionSet> {
      override class var operationName: String { "TestOpName" }
      override class var operationDocument: OperationDocument {
        .init(
          operationIdentifier: "4d465fbc6e3731d01102504850",
          definition: .init("query MockQuery {}"))
      }
    }

    let persistedQuery: JSONEncodableDictionary = [
      "version": 1,
      "sha256Hash": GivenMockOperation.operationIdentifier!
    ]
    
    let extensions: JSONEncodableDictionary = [
      "persistedQuery": persistedQuery
    ]
    
    let body: JSONEncodableDictionary = [
      "query": GivenMockOperation.definition?.queryDocument,
      "extensions": extensions
    ]
    
    let transformer = GraphQLGETTransformer(body: body, url: Self.url)
    
    let url = transformer.createGetURL()
    
    let expected = "http://localhost:8080/graphql?extensions=%7B%22persistedQuery%22:%7B%22sha256Hash%22:%224d465fbc6e3731d01102504850%22,%22version%22:1%7D%7D&query=query%20MockQuery%20%7B%7D"
    
    expect(url?.absoluteString).to(equal(expected))
  }

  func test__createGetURL__queryWithParameter_withPlusSign_encodesPlusSign() throws {
    let extensions: JSONEncodableDictionary = [
      "testParam": "+Test+Test"
    ]

    let body: JSONEncodableDictionary = [
      "query": MockOperation<MockSelectionSet>.definition?.queryDocument,
      "extensions": extensions
    ]

    let transformer = GraphQLGETTransformer(body: body, url: Self.url)

    let url = transformer.createGetURL()

    let expected = "http://localhost:8080/graphql?extensions=%7B%22testParam%22:%22%2BTest%2BTest%22%7D&query=Mock%20Operation%20Definition"

    expect(url?.absoluteString).to(equal(expected))
  }

  func test__createGetURL__queryWithParameter_withAmpersand_encodesAmpersand() throws {
    let extensions: JSONEncodableDictionary = [
      "testParam": "Test&Test"
    ]

    let body: JSONEncodableDictionary = [
      "query": MockOperation<MockSelectionSet>.definition?.queryDocument,
      "extensions": extensions
    ]

    let transformer = GraphQLGETTransformer(body: body, url: Self.url)

    let url = transformer.createGetURL()

    let expected = "http://localhost:8080/graphql?extensions=%7B%22testParam%22:%22Test%26Test%22%7D&query=Mock%20Operation%20Definition"
    expect(url?.absoluteString).to(equal(expected))
  }
  
  func test__createGetURL__queryWithPersistedQueryID_withoutQueryParameter_encodesURL() throws {
    class GivenMockOperation: MockOperation<MockSelectionSet> {
      override class var operationName: String { "TestOpName" }
      override class var operationDocument: OperationDocument {
        .init(operationIdentifier: "4d465fbc6e3731d01102504850")
      }
    }
    
    let persistedQuery: JSONEncodableDictionary = [
      "version": 1,
      "sha256Hash": GivenMockOperation.operationIdentifier!
    ]
    
    let extensions: JSONEncodableDictionary = [
      "persistedQuery": persistedQuery
    ]
    
    let body: JSONEncodableDictionary = [
      "extensions": extensions
    ]
    
    let transformer = GraphQLGETTransformer(body: body, url: Self.url)
    
    let url = transformer.createGetURL()
    
    let expected = "http://localhost:8080/graphql?extensions=%7B%22persistedQuery%22:%7B%22sha256Hash%22:%224d465fbc6e3731d01102504850%22,%22version%22:1%7D%7D"

    expect(url?.absoluteString).to(equal(expected))
  }
  
  func test__createGetURL__queryWithNullValueForVariable_encodesVariableWithNull() {
    class GivenMockOperation: MockOperation<MockSelectionSet> {
      override class var operationName: String { "TestOpName" }
      override class var operationDocument: OperationDocument {
        .init(definition: .init(
        """
        query MockQuery($param: String) {
          testField(param: $param) {
            __typename
            name
          }
        }
        """))
      }
    }

    let operation = GivenMockOperation()
    operation.__variables = ["param": GraphQLNullable<String>.null]

    let body = requestBodyCreator.requestBody(for: operation,
                                              sendQueryDocument: true,
                                              autoPersistQuery: false)

    let transformer = GraphQLGETTransformer(body: body, url: Self.url)

    let url = transformer.createGetURL()

    let expected =  "http://localhost:8080/graphql?operationName=TestOpName&query=query%20MockQuery($param:%20String)%20%7B%0A%20%20testField(param:%20$param)%20%7B%0A%20%20%20%20__typename%0A%20%20%20%20name%0A%20%20%7D%0A%7D&variables=%7B%22param%22:null%7D"

    expect(url?.absoluteString).to(equal(expected))
  }

  func test__createGetURL__urlHasExistingParameters_encodesURLIncludingExistingParameters_atStartOfQueryParameters() throws {
    let extensions: JSONEncodableDictionary = [
      "testParam": "Test&Test"
    ]

    let body: JSONEncodableDictionary = [
      "query": MockOperation<MockSelectionSet>.definition?.queryDocument,
      "extensions": extensions
    ]

    var components = URLComponents(string: Self.url.absoluteString)!
    components.queryItems = [URLQueryItem(name: "zalgo", value: "bar")]
    let transformer = GraphQLGETTransformer(body: body, url: components.url!)

    let url = transformer.createGetURL()

    let expected = "http://localhost:8080/graphql?zalgo=bar&extensions=%7B%22testParam%22:%22Test%26Test%22%7D&query=Mock%20Operation%20Definition"

    expect(url?.absoluteString).to(equal(expected))
  }

	func test__createGetURL__withEmptyQueryParameter_returnsURL() throws {
		let body: JSONEncodableDictionary = [:]
		let transformer = GraphQLGETTransformer(body: body, url: Self.url)
		let url = transformer.createGetURL()

		let expected = "http://localhost:8080/graphql"

    expect(url?.absoluteString).to(equal(expected))
	}
}
