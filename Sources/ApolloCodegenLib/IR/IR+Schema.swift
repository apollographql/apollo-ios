import Foundation

extension IR {
  struct Schema {
    let name: String
    let referencedTypes: ReferencedTypes

    public final class ReferencedTypes {
      let allTypes: Set<GraphQLNamedType>

      let objects: Set<GraphQLObjectType>
      let interfaces: Set<GraphQLInterfaceType>
      let unions: Set<GraphQLUnionType>
      let scalars: Set<GraphQLScalarType>
      let enums: Set<GraphQLEnumType>
      let inputObjects: Set<GraphQLInputObjectType>

      init(_ types: [GraphQLNamedType]) {
        self.allTypes = Set(types)

        var objects = Set<GraphQLObjectType>()
        var interfaces = Set<GraphQLInterfaceType>()
        var unions = Set<GraphQLUnionType>()
        var scalars = Set<GraphQLScalarType>()
        var enums = Set<GraphQLEnumType>()
        var inputObjects = Set<GraphQLInputObjectType>()

        for type in allTypes {
          switch type {
          case let type as GraphQLObjectType: objects.insert(type)
          case let type as GraphQLInterfaceType: interfaces.insert(type)
          case let type as GraphQLUnionType: unions.insert(type)
          case let type as GraphQLScalarType: scalars.insert(type)
          case let type as GraphQLEnumType: enums.insert(type)
          case let type as GraphQLInputObjectType: inputObjects.insert(type)
          default: continue
          }
        }

        self.objects = objects
        self.interfaces = interfaces
        self.unions = unions
        self.scalars = scalars
        self.enums = enums
        self.inputObjects = inputObjects
      }

      private var typeToUnionMap: [GraphQLObjectType: Set<GraphQLUnionType>] = [:]

      public func unions(including type: GraphQLObjectType) -> Set<GraphQLUnionType> {
        if let unions = typeToUnionMap[type] {
          return unions
        }

        let matchingUnions = unions.filter { $0.types.contains(type) }
        typeToUnionMap[type] = matchingUnions
        return matchingUnions
      }
    }
  }
}
