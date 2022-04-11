import Foundation
import OrderedCollections

extension IR {
  struct Schema {
    let name: String
    let referencedTypes: ReferencedTypes

    public final class ReferencedTypes {
      let allTypes: OrderedSet<GraphQLNamedType>

      let objects: OrderedSet<GraphQLObjectType>
      let interfaces: OrderedSet<GraphQLInterfaceType>
      let unions: OrderedSet<GraphQLUnionType>
      let scalars: OrderedSet<GraphQLScalarType>
      let customScalars: OrderedSet<GraphQLScalarType>
      let enums: OrderedSet<GraphQLEnumType>
      let inputObjects: OrderedSet<GraphQLInputObjectType>

      init(_ types: [GraphQLNamedType]) {
        self.allTypes = OrderedSet(types)

        var objects = OrderedSet<GraphQLObjectType>()
        var interfaces = OrderedSet<GraphQLInterfaceType>()
        var unions = OrderedSet<GraphQLUnionType>()
        var scalars = OrderedSet<GraphQLScalarType>()
        var customScalars = OrderedSet<GraphQLScalarType>()
        var enums = OrderedSet<GraphQLEnumType>()
        var inputObjects = OrderedSet<GraphQLInputObjectType>()

        for type in allTypes {
          switch type {
          case let type as GraphQLObjectType: objects.append(type)
          case let type as GraphQLInterfaceType: interfaces.append(type)
          case let type as GraphQLUnionType: unions.append(type)
          case let type as GraphQLScalarType:
            if type.isCustomScalar {
              customScalars.append(type)
            } else {
              scalars.append(type)              
            }
          case let type as GraphQLEnumType: enums.append(type)
          case let type as GraphQLInputObjectType: inputObjects.append(type)
          default: continue
          }
        }

        self.objects = objects
        self.interfaces = interfaces
        self.unions = unions
        self.scalars = scalars
        self.customScalars = customScalars
        self.enums = enums
        self.inputObjects = inputObjects
      }

      private var typeToUnionMap: [GraphQLObjectType: Set<GraphQLUnionType>] = [:]

      public func unions(including type: GraphQLObjectType) -> Set<GraphQLUnionType> {
        if let unions = typeToUnionMap[type] {
          return unions
        }

        let matchingUnions = Set(unions.filter { $0.types.contains(type) })
        typeToUnionMap[type] = matchingUnions
        return matchingUnions
      }
    }
  }
}
