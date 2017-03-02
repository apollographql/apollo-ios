@testable import Apollo

public struct Data: GraphQLMappable {
  public let hero: Hero?
  
  public init(values: [Any?]) {
    hero = values[0] as! Hero?
  }
  
  public struct Hero: GraphQLMappable {
    public let __typename: String
    public let id: GraphQLID
    public let name: String
    public let friends: [Friend?]?
    
    public init(values: [Any?]) {
      __typename = values[0] as! String
      id = values[1] as! GraphQLID
      name = values[2] as! String
      friends = values[3] as! [Friend?]?
    }
    
    public struct Friend: GraphQLMappable {
      public let __typename: String
      public let id: GraphQLID
      public let name: String
      
      public init(values: [Any?]) {
        __typename = values[0] as! String
        id = values[1] as! GraphQLID
        name = values[2] as! String
      }
    }
  }
}

let selectionSet = [
  Field("hero", arguments: ["episode": Variable("episode")], type: .object(Data.Hero.self), selectionSet: [
    Field("__typename", type: .nonNull(.scalar(String.self))),
    Field("id", type: .nonNull(.scalar(GraphQLID.self))),
    Field("name", type: .nonNull(.scalar(String.self))),
    Field("friends", type: .list(.object(Data.Hero.Friend.self)), selectionSet: [
      Field("__typename", type: .nonNull(.scalar(String.self))),
      Field("id", type: .nonNull(.scalar(GraphQLID.self))),
      Field("name", type: .nonNull(.scalar(String.self)))
    ])
  ])
]

let executor = GraphQLExecutor(rootObject: [
  "hero": [
    "__typename": "Droid",
    "id": "2001",
    "name": "R2-D2",
    "friends": [
      ["__typename": "Human", "id": "1000", "name": "Luke Skywalker"],
      ["__typename": "Human", "id": "1002", "name": "Han Solo"],
      ["__typename": "Human", "id": "1003", "name": "Leia Organa"]
    ]
  ]
])

executor.cacheKeyForObject = { [$0["__typename"], $0["id"]] }

let mapper = GraphQLResultMapper<Data>()
let normalizer = GraphQLResultNormalizer()
let responseGenerator = GraphQLResponseGenerator()

let accumulator = zip(mapper, normalizer, responseGenerator)

let (typedResults, records, json) = try executor.execute(selectionSet: selectionSet, rootKey: "foo", variables: ["episode": "JEDI"], accumulator: accumulator).wait()


typedResults.hero?.name

records

json

