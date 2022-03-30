import Foundation
import OrderedCollections
import ApolloUtils

extension IR {

  func build(fragment fragmentDefinition: CompilationResult.FragmentDefinition) -> NamedFragment {
    if let fragment = builtFragments[fragmentDefinition.name] {
      return fragment
    }

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
      inIR: self
    )

    let irFragment = IR.NamedFragment(
      definition: fragmentDefinition,
      rootField: irRootField
    )

    builtFragments[irFragment.name] = irFragment
    return irFragment
  }

}
