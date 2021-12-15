import Foundation
import OrderedCollections
import ApolloUtils

extension IR {

  func build(fragment: CompilationResult.FragmentDefinition) -> NamedFragment {
    NamedFragmentBuilder.build(fragment: fragment, inSchema: schema)
  }

  fileprivate final class NamedFragmentBuilder {

    static func build(
      fragment: CompilationResult.FragmentDefinition,
      inSchema schema: Schema
    ) -> IR.NamedFragment {
      return NamedFragmentBuilder(schema: schema, definition: fragment).build()
    }

    let schema: Schema
    let fragmentDefinition: CompilationResult.FragmentDefinition

    private init(
      schema: Schema,
      definition: CompilationResult.FragmentDefinition
    ) {
      self.schema = schema
      self.fragmentDefinition = definition
    }

    private func build() -> NamedFragment {
      let rootEntity = Entity(
        rootTypePath: LinkedList(fragmentDefinition.type),
        fieldPath: ResponsePath(fragmentDefinition.name)
      )

      let rootField = CompilationResult.Field(
        name: fragmentDefinition.name,
        type: .nonNull(.entity(fragmentDefinition.type)),
        selectionSet: fragmentDefinition.selectionSet
      )

      let (irRootField, _) = RootFieldBuilder.buildRootEntityField(
        forRootField: rootField,
        onRootEntity: rootEntity,
        inSchema: schema
      )

      return IR.NamedFragment(
        definition: fragmentDefinition,
        rootField: irRootField
      )
    }
  }

}
