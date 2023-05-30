import Foundation
import OrderedCollections

extension IR {

  func build(fragment fragmentDefinition: CompilationResult.FragmentDefinition) -> NamedFragment {
    if let fragment = builtFragments[fragmentDefinition.name] {
      return fragment
    }

    let rootField = CompilationResult.Field(
      name: fragmentDefinition.name,
      type: .nonNull(.entity(fragmentDefinition.type)),
      selectionSet: fragmentDefinition.selectionSet
    )

    let rootEntity = Entity(
      source: .namedFragment(fragmentDefinition)      
    )

    let result = RootFieldBuilder.buildRootEntityField(
      forRootField: rootField,
      onRootEntity: rootEntity,
      inIR: self
    )

    let irFragment = IR.NamedFragment(
      definition: fragmentDefinition,
      rootField: result.rootField,
      referencedFragments: result.referencedFragments,
      entities: result.entities
    )

    builtFragments[irFragment.name] = irFragment
    return irFragment
  }

}
