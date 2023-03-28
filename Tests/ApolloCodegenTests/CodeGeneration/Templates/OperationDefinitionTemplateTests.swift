import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class OperationDefinitionTemplateTests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var operation: IR.Operation!
  var config: ApolloCodegenConfiguration!
  var subject: OperationDefinitionTemplate!

  override func setUp() {
    super.setUp()
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
      }
    }
    """

    config = .mock()
  }

  override func tearDown() {
    schemaSDL = nil
    document = nil
    ir = nil
    operation = nil
    config = nil
    subject = nil
    super.tearDown()
  }

  // MARK: - Helpers

  private func buildSubjectAndOperation(named operationName: String = "TestOperation") throws {
    ir = try .mock(schema: schemaSDL, document: document)
    let operationDefinition = try XCTUnwrap(ir.compilationResult[operation: operationName])
    operation = ir.build(operation: operationDefinition)
    subject = OperationDefinitionTemplate(
      operation: operation,
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: - Operation Definition

  func test__generate__givenQuery_generatesQueryOperation() throws {
    // given
    let expected =
    """
    class TestOperationQuery: GraphQLQuery {
      public static let operationName: String = "TestOperation"
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenQueryWithNameEndingInQuery_generatesQueryOperationWithoutDoubledTypeSuffix() throws {
    // given
    document = """
    query TestOperationQuery {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
    class TestOperationQuery: GraphQLQuery {
      public static let operationName: String = "TestOperationQuery"
    """

    // when
    try buildSubjectAndOperation(named: "TestOperationQuery")

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenMutationWithNameEndingInQuery_generatesQueryOperationWithBothSuffixes() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Mutation {
      addAnimal: Animal!
    }

    type Animal {
      species: String!
    }
    """

    document = """
    mutation TestOperationQuery {
      addAnimal {
        species
      }
    }
    """

    let expected =
    """
    class TestOperationQueryMutation: GraphQLMutation {
      public static let operationName: String = "TestOperationQuery"
    """

    // when
    try buildSubjectAndOperation(named: "TestOperationQuery")

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenMutation_generatesMutationOperation() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Mutation {
      addAnimal: Animal!
    }

    type Animal {
      species: String!
    }
    """

    document = """
    mutation TestOperation {
      addAnimal {
        species
      }
    }
    """

    let expected =
    """
    class TestOperationMutation: GraphQLMutation {
      public static let operationName: String = "TestOperation"
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenSubscription_generatesSubscriptionOperation() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Subscription {
      streamAnimals: [Animal!]
    }

    type Animal {
      species: String!
    }
    """

    document = """
    subscription TestOperation {
      streamAnimals {
        species
      }
    }
    """

    let expected =
    """
    class TestOperationSubscription: GraphQLSubscription {
      public static let operationName: String = "TestOperation"
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenQueryWithLowercasing_generatesCorrectlyCasedQueryOperation() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
    }
    """

    document = """
    query lowercaseOperation($variable: String = "TestVar") {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
    class LowercaseOperationQuery: GraphQLQuery {
      public static let operationName: String = "lowercaseOperation"
      public static let document: ApolloAPI.DocumentType = .notPersisted(
        definition: .init(
          #\"\"\"
          query lowercaseOperation($variable: String = "TestVar") {
    """

    // when
    try buildSubjectAndOperation(named: "lowercaseOperation")

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: - Selection Set Initializers

    func test__generate_givenOperationSelectionSet_configIncludesOperations_rendersInitializer() throws {
      // given
      schemaSDL = """
      type Query {
        allAnimals: [Animal!]
      }

      type Animal {
        species: String!
      }
      """

      document = """
      query TestOperation {
        allAnimals {
          species
        }
      }
      """

      let expected =
      """
            public init(
              species: String
            ) {
              self.init(_dataDict: DataDict(data: [
                "__typename": TestSchema.Objects.Animal.typename,
                "species": species,
                "__fulfilled": Set([
                  ObjectIdentifier(Self.self)
                ])
              ]))
            }
      """

      config = .mock(options: .init(selectionSetInitializers: [.operations]))

      // when
      try buildSubjectAndOperation()

      let actual = renderSubject()

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 55, ignoringExtraLines: true))
    }

    func test__generate_givenOperationSelectionSet_configIncludesSpecificOperation_rendersInitializer() throws {
      // given
      schemaSDL = """
      type Query {
        allAnimals: [Animal!]
      }

      type Animal {
        species: String!
      }
      """

      document = """
      query TestOperation {
        allAnimals {
          species
        }
      }
      """

      let expected =
      """
            public init(
              species: String
            ) {
              self.init(_dataDict: DataDict(data: [
                "__typename": TestSchema.Objects.Animal.typename,
                "species": species,
                "__fulfilled": Set([
                  ObjectIdentifier(Self.self)
                ])
              ]))
            }
      """

      config = .mock(options: .init(selectionSetInitializers: [
        .operation(named: "TestOperation")
      ]))

      // when
      try buildSubjectAndOperation()

      let actual = renderSubject()

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 55, ignoringExtraLines: true))
    }

    func test__render_givenOperationSelectionSet_configDoesNotIncludeOperations_doesNotRenderInitializer() throws {
      // given
      schemaSDL = """
      type Query {
        allAnimals: [Animal!]
      }

      type Animal {
        species: String!
      }
      """

      document = """
      query TestOperation {
        allAnimals {
          species
        }
      }
      """

      config = .mock(options: .init(selectionSetInitializers: [.namedFragments]))

      // when
      try buildSubjectAndOperation()

      let actual = renderSubject()

      // then
      expect(actual).to(equalLineByLine("    }", atLine: 42, ignoringExtraLines: true))
    }

    func test__render_givenOperationSelectionSet_configIncludeSpecificOperationWithOtherName_doesNotRenderInitializer() throws {
      // given
      schemaSDL = """
      type Query {
        allAnimals: [Animal!]
      }

      type Animal {
        species: String!
      }
      """

      document = """
      query TestOperation {
        allAnimals {
          species
        }
      }
      """

      config = .mock(options: .init(selectionSetInitializers: [
        .operation(named: "OtherOperation")
      ]))

      // when
      try buildSubjectAndOperation()

      let actual = renderSubject()

      // then
      expect(actual).to(equalLineByLine("    }", atLine: 42, ignoringExtraLines: true))
    }


  // MARK: - Variables

   func test__generate__givenQueryWithScalarVariable_generatesQueryOperationWithVariable() throws {
     // given
     schemaSDL = """
     type Query {
       allAnimals: [Animal!]
     }

     type Animal {
       species: String!
     }
     """

     document = """
     query TestOperation($variable: String!) {
       allAnimals {
         species
       }
     }
     """

     let expected =
     """
       public var variable: String

       public init(variable: String) {
         self.variable = variable
       }

       public var __variables: Variables? { ["variable": variable] }
     """

     // when
     try buildSubjectAndOperation()

     let actual = renderSubject()

     // then
     expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
   }

  func test__generate__givenQueryWithMutlipleScalarVariables_generatesQueryOperationWithVariables() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
      intField: Int!
    }
    """

    document = """
    query TestOperation($variable1: String!, $variable2: Boolean!, $variable3: Int!) {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
      public var variable1: String
      public var variable2: Bool
      public var variable3: Int

      public init(
        variable1: String,
        variable2: Bool,
        variable3: Int
      ) {
        self.variable1 = variable1
        self.variable2 = variable2
        self.variable3 = variable3
      }

      public var __variables: Variables? { [
        "variable1": variable1,
        "variable2": variable2,
        "variable3": variable3
      ] }
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test__generate__givenQueryWithNullableScalarVariable_generatesQueryOperationWithVariable() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
    }
    """

    document = """
    query TestOperation($variable: String = "TestVar") {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
      public var variable: GraphQLNullable<String>
    
      public init(variable: GraphQLNullable<String> = "TestVar") {
        self.variable = variable
      }

      public var __variables: Variables? { ["variable": variable] }
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test__generate__givenQueryWithCapitalizedVariable_generatesQueryOperationWithLowercaseVariable() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
    }
    """

    document = """
    query TestOperation($Variable: String) {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
      public var variable: GraphQLNullable<String>

      public init(variable: GraphQLNullable<String>) {
        self.variable = variable
      }

      public var __variables: Variables? { ["Variable": variable] }
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  // MARK: Variables - Reserved Keywords + Special Names

  func test__generate__givenQueryWithSwiftReservedKeywordNames_generatesQueryOperationWithVariablesBackticked() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
      intField: Int!
    }
    """

    document = """
    query TestOperation(
      $as: String
      $associatedtype: String
      $break: String
      $case: String
      $catch: String
      $class: String
      $continue: String
      $default: String
      $defer: String
      $deinit: String
      $do: String
      $else: String
      $enum: String
      $extension: String
      $fallthrough: String
      $false: String
      $fileprivate: String
      $for: String
      $func: String
      $guard: String
      $if: String
      $import: String
      $in: String
      $init: String
      $inout: String
      $internal: String
      $is: String
      $let: String
      $nil: String
      $operator: String
      $precedencegroup: String
      $private: String
      $protocol: String
      $public: String
      $repeat: String
      $rethrows: String
      $return: String
      $static: String
      $struct: String
      $subscript: String
      $super: String
      $switch: String
      $throw: String
      $throws: String
      $true: String
      $try: String
      $typealias: String
      $var: String
      $where: String
      $while: String
    ) {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
      public var `as`: GraphQLNullable<String>
      public var `associatedtype`: GraphQLNullable<String>
      public var `break`: GraphQLNullable<String>
      public var `case`: GraphQLNullable<String>
      public var `catch`: GraphQLNullable<String>
      public var `class`: GraphQLNullable<String>
      public var `continue`: GraphQLNullable<String>
      public var `default`: GraphQLNullable<String>
      public var `defer`: GraphQLNullable<String>
      public var `deinit`: GraphQLNullable<String>
      public var `do`: GraphQLNullable<String>
      public var `else`: GraphQLNullable<String>
      public var `enum`: GraphQLNullable<String>
      public var `extension`: GraphQLNullable<String>
      public var `fallthrough`: GraphQLNullable<String>
      public var `false`: GraphQLNullable<String>
      public var `fileprivate`: GraphQLNullable<String>
      public var `for`: GraphQLNullable<String>
      public var `func`: GraphQLNullable<String>
      public var `guard`: GraphQLNullable<String>
      public var `if`: GraphQLNullable<String>
      public var `import`: GraphQLNullable<String>
      public var `in`: GraphQLNullable<String>
      public var `init`: GraphQLNullable<String>
      public var `inout`: GraphQLNullable<String>
      public var `internal`: GraphQLNullable<String>
      public var `is`: GraphQLNullable<String>
      public var `let`: GraphQLNullable<String>
      public var `nil`: GraphQLNullable<String>
      public var `operator`: GraphQLNullable<String>
      public var `precedencegroup`: GraphQLNullable<String>
      public var `private`: GraphQLNullable<String>
      public var `protocol`: GraphQLNullable<String>
      public var `public`: GraphQLNullable<String>
      public var `repeat`: GraphQLNullable<String>
      public var `rethrows`: GraphQLNullable<String>
      public var `return`: GraphQLNullable<String>
      public var `static`: GraphQLNullable<String>
      public var `struct`: GraphQLNullable<String>
      public var `subscript`: GraphQLNullable<String>
      public var `super`: GraphQLNullable<String>
      public var `switch`: GraphQLNullable<String>
      public var `throw`: GraphQLNullable<String>
      public var `throws`: GraphQLNullable<String>
      public var `true`: GraphQLNullable<String>
      public var `try`: GraphQLNullable<String>
      public var `typealias`: GraphQLNullable<String>
      public var `var`: GraphQLNullable<String>
      public var `where`: GraphQLNullable<String>
      public var `while`: GraphQLNullable<String>

      public init(
        `as`: GraphQLNullable<String>,
        `associatedtype`: GraphQLNullable<String>,
        `break`: GraphQLNullable<String>,
        `case`: GraphQLNullable<String>,
        `catch`: GraphQLNullable<String>,
        `class`: GraphQLNullable<String>,
        `continue`: GraphQLNullable<String>,
        `default`: GraphQLNullable<String>,
        `defer`: GraphQLNullable<String>,
        `deinit`: GraphQLNullable<String>,
        `do`: GraphQLNullable<String>,
        `else`: GraphQLNullable<String>,
        `enum`: GraphQLNullable<String>,
        `extension`: GraphQLNullable<String>,
        `fallthrough`: GraphQLNullable<String>,
        `false`: GraphQLNullable<String>,
        `fileprivate`: GraphQLNullable<String>,
        `for`: GraphQLNullable<String>,
        `func`: GraphQLNullable<String>,
        `guard`: GraphQLNullable<String>,
        `if`: GraphQLNullable<String>,
        `import`: GraphQLNullable<String>,
        `in`: GraphQLNullable<String>,
        `init`: GraphQLNullable<String>,
        `inout`: GraphQLNullable<String>,
        `internal`: GraphQLNullable<String>,
        `is`: GraphQLNullable<String>,
        `let`: GraphQLNullable<String>,
        `nil`: GraphQLNullable<String>,
        `operator`: GraphQLNullable<String>,
        `precedencegroup`: GraphQLNullable<String>,
        `private`: GraphQLNullable<String>,
        `protocol`: GraphQLNullable<String>,
        `public`: GraphQLNullable<String>,
        `repeat`: GraphQLNullable<String>,
        `rethrows`: GraphQLNullable<String>,
        `return`: GraphQLNullable<String>,
        `static`: GraphQLNullable<String>,
        `struct`: GraphQLNullable<String>,
        `subscript`: GraphQLNullable<String>,
        `super`: GraphQLNullable<String>,
        `switch`: GraphQLNullable<String>,
        `throw`: GraphQLNullable<String>,
        `throws`: GraphQLNullable<String>,
        `true`: GraphQLNullable<String>,
        `try`: GraphQLNullable<String>,
        `typealias`: GraphQLNullable<String>,
        `var`: GraphQLNullable<String>,
        `where`: GraphQLNullable<String>,
        `while`: GraphQLNullable<String>
      ) {
        self.`as` = `as`
        self.`associatedtype` = `associatedtype`
        self.`break` = `break`
        self.`case` = `case`
        self.`catch` = `catch`
        self.`class` = `class`
        self.`continue` = `continue`
        self.`default` = `default`
        self.`defer` = `defer`
        self.`deinit` = `deinit`
        self.`do` = `do`
        self.`else` = `else`
        self.`enum` = `enum`
        self.`extension` = `extension`
        self.`fallthrough` = `fallthrough`
        self.`false` = `false`
        self.`fileprivate` = `fileprivate`
        self.`for` = `for`
        self.`func` = `func`
        self.`guard` = `guard`
        self.`if` = `if`
        self.`import` = `import`
        self.`in` = `in`
        self.`init` = `init`
        self.`inout` = `inout`
        self.`internal` = `internal`
        self.`is` = `is`
        self.`let` = `let`
        self.`nil` = `nil`
        self.`operator` = `operator`
        self.`precedencegroup` = `precedencegroup`
        self.`private` = `private`
        self.`protocol` = `protocol`
        self.`public` = `public`
        self.`repeat` = `repeat`
        self.`rethrows` = `rethrows`
        self.`return` = `return`
        self.`static` = `static`
        self.`struct` = `struct`
        self.`subscript` = `subscript`
        self.`super` = `super`
        self.`switch` = `switch`
        self.`throw` = `throw`
        self.`throws` = `throws`
        self.`true` = `true`
        self.`try` = `try`
        self.`typealias` = `typealias`
        self.`var` = `var`
        self.`where` = `where`
        self.`while` = `while`
      }

      public var __variables: Variables? { [
        "as": `as`,
        "associatedtype": `associatedtype`,
        "break": `break`,
        "case": `case`,
        "catch": `catch`,
        "class": `class`,
        "continue": `continue`,
        "default": `default`,
        "defer": `defer`,
        "deinit": `deinit`,
        "do": `do`,
        "else": `else`,
        "enum": `enum`,
        "extension": `extension`,
        "fallthrough": `fallthrough`,
        "false": `false`,
        "fileprivate": `fileprivate`,
        "for": `for`,
        "func": `func`,
        "guard": `guard`,
        "if": `if`,
        "import": `import`,
        "in": `in`,
        "init": `init`,
        "inout": `inout`,
        "internal": `internal`,
        "is": `is`,
        "let": `let`,
        "nil": `nil`,
        "operator": `operator`,
        "precedencegroup": `precedencegroup`,
        "private": `private`,
        "protocol": `protocol`,
        "public": `public`,
        "repeat": `repeat`,
        "rethrows": `rethrows`,
        "return": `return`,
        "static": `static`,
        "struct": `struct`,
        "subscript": `subscript`,
        "super": `super`,
        "switch": `switch`,
        "throw": `throw`,
        "throws": `throws`,
        "true": `true`,
        "try": `try`,
        "typealias": `typealias`,
        "var": `var`,
        "where": `where`,
        "while": `while`
      ] }
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }
}
