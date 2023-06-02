import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class FragmentTemplateTests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var fragment: IR.NamedFragment!
  var subject: FragmentTemplate!

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
    fragment TestFragment on Query {
      allAnimals {
        species
      }
    }
    """
  }

  override func tearDown() {
    schemaSDL = nil
    document = nil
    ir = nil
    fragment = nil
    subject = nil
    super.tearDown()
  }

  // MARK: - Helpers

  private func buildSubjectAndFragment(
    named fragmentName: String = "TestFragment",
    config: ApolloCodegenConfiguration = .mock()
  ) throws {
    ir = try .mock(schema: schemaSDL, document: document)
    let fragmentDefinition = try XCTUnwrap(ir.compilationResult[fragment: fragmentName])
    fragment = ir.build(fragment: fragmentDefinition)
    subject = FragmentTemplate(
      fragment: fragment,
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Fragment Definition

  func test__render__givenFragment_generatesFragmentDeclarationDefinitionAndBoilerplate() throws {
    // given
    let expected =
    """
    struct TestFragment: TestSchema.SelectionSet, Fragment {
      static var fragmentDefinition: StaticString { ""\"
        fragment TestFragment on Query {
          __typename
          allAnimals {
            __typename
            species
          }
        }
        ""\" }

      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }
    """

    // when
    try buildSubjectAndFragment()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
    expect(String(actual.reversed())).to(equalLineByLine("\n}", ignoringExtraLines: true))
  }

  func test__render__givenLowercaseFragment_generatesTitleCaseTypeName() throws {
    // given
    document = """
    fragment testFragment on Query {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
    struct TestFragment: TestSchema.SelectionSet, Fragment {
      static var fragmentDefinition: StaticString { ""\"
        fragment testFragment on Query {
    """

    // when
    try buildSubjectAndFragment(named: "testFragment")

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenFragmentWithUnderscoreInName_rendersDeclarationWithName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }
    """

    document = """
    fragment Test_Fragment on Animal {
      species
    }
    """

    let expected = """
    struct Test_Fragment: TestSchema.SelectionSet, Fragment {
    """

    // when
    try buildSubjectAndFragment(named: "Test_Fragment")
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render_parentType__givenFragmentTypeConditionAs_Object_rendersParentType() throws {
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
    fragment TestFragment on Animal {
      species
    }
    """

    let expected = """
      static var __parentType: ApolloAPI.ParentType { TestSchema.Objects.Animal }
    """

    // when
    try buildSubjectAndFragment()
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  func test__render_parentType__givenFragmentTypeConditionAs_Interface_rendersParentType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }
    """

    document = """
    fragment TestFragment on Animal {
      species
    }
    """

    let expected = """
      static var __parentType: ApolloAPI.ParentType { TestSchema.Interfaces.Animal }
    """

    // when
    try buildSubjectAndFragment()
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  func test__render_parentType__givenFragmentTypeConditionAs_Union_rendersParentType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Dog {
      species: String!
    }

    union Animal = Dog
    """

    document = """
    fragment TestFragment on Animal {
      ... on Dog {
        species
      }
    }
    """

    let expected = """
      static var __parentType: ApolloAPI.ParentType { TestSchema.Unions.Animal }
    """

    // when
    try buildSubjectAndFragment()
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 14, ignoringExtraLines: true))
  }

  func test__render__givenFragmentOnRootOperationTypeWithOnlyTypenameField_generatesFragmentDefinition_withNoSelections() throws {
    // given
    document = """
    fragment TestFragment on Query {
      __typename
    }
    """

    try buildSubjectAndFragment()

    let expected = """
    struct TestFragment: TestSchema.SelectionSet, Fragment {
      static var fragmentDefinition: StaticString { ""\"
        fragment TestFragment on Query {
          __typename
        }
        ""\" }

      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: ApolloAPI.ParentType { TestSchema.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
      ] }
    }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenFragmentWithOnlyTypenameField_generatesFragmentDefinition_withTypeNameSelection() throws {
    // given
    document = """
    fragment TestFragment on Animal {
      __typename
    }
    """

    try buildSubjectAndFragment()

    let expected = """
    struct TestFragment: TestSchema.SelectionSet, Fragment {
      static var fragmentDefinition: StaticString { ""\"
        fragment TestFragment on Animal {
          __typename
        }
        ""\" }

      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: ApolloAPI.ParentType { TestSchema.Objects.Animal }
      static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
      ] }
    }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: Access Level Tests

  func test__render__givenModuleType_swiftPackageManager_generatesFragmentDefinition_withPublicAccess() throws {
    // given
    try buildSubjectAndFragment(config: .mock(.swiftPackageManager))

    let expected = """
    public struct TestFragment: TestSchema.SelectionSet, Fragment {
      public static var fragmentDefinition: StaticString { ""\"
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenModuleType_other_generatesFragmentDefinition_withPublicAccess() throws {
    // given
    try buildSubjectAndFragment(config: .mock(.other))

    let expected = """
    public struct TestFragment: TestSchema.SelectionSet, Fragment {
      public static var fragmentDefinition: StaticString { ""\"
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenModuleType_embeddedInTarget_withInternalAccessModifier_generatesFragmentDefinition_withInternalAccess() throws {
    // given
    try buildSubjectAndFragment(
      config: .mock(.embeddedInTarget(name: "TestTarget", accessModifier: .internal))
    )

    let expected = """
    struct TestFragment: TestSchema.SelectionSet, Fragment {
      static var fragmentDefinition: StaticString { ""\"
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenModuleType_embeddedInTarget_withPublicAccessModifier_generatesFragmentDefinition_withPublicAccess() throws {
    // given
    try buildSubjectAndFragment(
      config: .mock(.embeddedInTarget(name: "TestTarget", accessModifier: .public))
    )

    let expected = """
    struct TestFragment: TestSchema.SelectionSet, Fragment {
      public static var fragmentDefinition: StaticString { ""\"
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Initializer Tests

  func test__render_givenInitializerConfigIncludesNamedFragments_rendersInitializer() throws {
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
      fragment TestFragment on Animal {
        species
      }
      """

    let expected =
      """
        init(
          species: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": TestSchema.Objects.Animal.typename,
              "species": species,
            ],
            fulfilledFragments: [
              ObjectIdentifier(Self.self)
            ]
          ))
        }
      """

    // when
    try buildSubjectAndFragment(
      config: .mock(options: .init(
        selectionSetInitializers: [.namedFragments]
      )))

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 20, ignoringExtraLines: true))
  }

  func test__render_givenNamedFragment_configIncludesSpecificFragment_rendersInitializer() throws {
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
      fragment TestFragment on Animal {
        species
      }
      """

    let expected =
      """
        init(
          species: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": TestSchema.Objects.Animal.typename,
              "species": species,
            ],
            fulfilledFragments: [
              ObjectIdentifier(Self.self)
            ]
          ))
        }
      """

    // when
    try buildSubjectAndFragment(
      config: .mock(options: .init(
        selectionSetInitializers: [.fragment(named: "TestFragment")]
      )))

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 20, ignoringExtraLines: true))
  }

  func test__render_givenNamedFragment_configDoesNotIncludeNamedFragments_doesNotRenderInitializer() throws {
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
      fragment TestFragment on Animal {
        species
      }
      """

    // when
    try buildSubjectAndFragment(
      config: .mock(options: .init(
        selectionSetInitializers: [.operations]
      )))

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine("}", atLine: 19, ignoringExtraLines: true))
  }

  func test__render_givenNamedFragments_configIncludeSpecificFragmentWithOtherName_doesNotRenderInitializer() throws {
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
      fragment TestFragment on Animal {
        species
      }
      """

    // when
    try buildSubjectAndFragment(
      config: .mock(options: .init(
        selectionSetInitializers: [.fragment(named: "OtherFragment")]
      )))

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine("}", atLine: 19, ignoringExtraLines: true))
  }

  func test__render_givenNamedFragments_asLocalCacheMutation_configIncludeLocalCacheMutations_rendersInitializer() throws {
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
      fragment TestFragment on Animal @apollo_client_ios_localCacheMutation {
        species
      }
      """

    let expected =
      """
        init(
          species: String
        ) {
          self.init(_dataDict: DataDict(
            data: [
              "__typename": TestSchema.Objects.Animal.typename,
              "species": species,
            ],
            fulfilledFragments: [
              ObjectIdentifier(Self.self)
            ]
          ))
        }
      """

    // when
    try buildSubjectAndFragment(
      config: .mock(options: .init(
        selectionSetInitializers: [.localCacheMutations]
      )))

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 23, ignoringExtraLines: true))
  }

  // MARK: Local Cache Mutation Tests
  func test__render__givenFragment__asLocalCacheMutation_generatesFragmentDeclarationDefinitionAsMutableSelectionSetAndBoilerplate() throws {
    // given
    document = """
    fragment TestFragment on Query @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
    struct TestFragment: TestSchema.MutableSelectionSet, Fragment {
    """

    // when
    try buildSubjectAndFragment()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
    expect(String(actual.reversed())).to(equalLineByLine("\n}", ignoringExtraLines: true))
  }

  func test__render__givenFragment__asLocalCacheMutation_generatesFragmentDefinitionStrippingLocalCacheMutationDirective() throws {
    // given
    document = """
    fragment TestFragment on Query @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
    struct TestFragment: TestSchema.MutableSelectionSet, Fragment {
      static var fragmentDefinition: StaticString { ""\"
        fragment TestFragment on Query {
          __typename
          allAnimals {
            __typename
            species
          }
        }
        ""\" }
    """

    // when
    try buildSubjectAndFragment()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
    expect(String(actual.reversed())).to(equalLineByLine("\n}", ignoringExtraLines: true))
  }

  func test__render__givenFragment__asLocalCacheMutation_generatesFragmentDefinitionAsMutableSelectionSet() throws {
    // given
    document = """
    fragment TestFragment on Query @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
      var __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: ApolloAPI.ParentType { TestSchema.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("allAnimals", [AllAnimal]?.self),
      ] }

      var allAnimals: [AllAnimal]? {
        get { __data["allAnimals"] }
        set { __data["allAnimals"] = newValue }
      }
    """

    // when
    try buildSubjectAndFragment()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  // MARK: Casing

  func test__casing__givenLowercasedSchemaName_generatesWithFirstUppercasedNamespace() throws {
    // given
    try buildSubjectAndFragment(config: .mock(schemaNamespace: "mySchema"))

    // then
    let expected = """
      struct TestFragment: MySchema.SelectionSet, Fragment {
      """

    let actual = renderSubject()

    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__casing__givenUppercasedSchemaName_generatesWithUppercasedNamespace() throws {
    // given
    try buildSubjectAndFragment(config: .mock(schemaNamespace: "MY_SCHEMA"))

    // then
    let expected = """
      struct TestFragment: MY_SCHEMA.SelectionSet, Fragment {
      """

    let actual = renderSubject()

    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__casing__givenCapitalizedSchemaName_generatesWithCapitalizedNamespace() throws {
    // given
    try buildSubjectAndFragment(config: .mock(schemaNamespace: "MySchema"))

    // then
    let expected = """
      struct TestFragment: MySchema.SelectionSet, Fragment {
      """

    let actual = renderSubject()

    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }
  
  // MARK: - Reserved Keyword Tests
  
  func test__render__givenFragmentReservedKeywordName_rendersEscapedName() throws {
    let keywords = ["Type", "type"]
    
    try keywords.forEach { keyword in
      // given
      schemaSDL = """
      type Query {
        getUser(id: String): User
      }

      type User {
        id: String!
        name: String!
      }
      """

      document = """
      fragment \(keyword) on User {
          name
      }
      """

      let expected = """
      struct \(keyword.firstUppercased)_Fragment: TestSchema.SelectionSet, Fragment {
      """

      // when
      try buildSubjectAndFragment(named: keyword)
      let actual = renderSubject()

      // then
      expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
    }
  }
  
}
