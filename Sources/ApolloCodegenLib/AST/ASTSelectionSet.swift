import Foundation
import ApolloUtils
import OrderedCollections

class ASTSelectionSet: CustomDebugStringConvertible, Equatable {
  typealias Selection = CompilationResult.Selection
  typealias SelectionSet = CompilationResult.SelectionSet
  typealias ChildTypeCaseDictionary = OrderedDictionary<String, ASTSelectionSet>
  typealias ComputedSelectionsAndChildren = (SortedSelections, ChildTypeCaseDictionary)

  let type: GraphQLCompositeType

  let compilationResult: CompilationResult

  let mergedSelectionBuilder: MergedSelectionBuilder

  weak private(set) var parent: ASTSelectionSet?

  lazy var mergedSelections: SortedSelections = mergedSelectionBuilder.mergedSelections(for: self)

  private(set) lazy var scopeDescriptor = TypeScopeDescriptor.descriptor(for: self)

  private var _computedSelectionsAndChildren: ComputedSelectionsAndChildren!

  var children: ChildTypeCaseDictionary {
    _computedSelectionsAndChildren.unsafelyUnwrapped.1
  }

  var selections: SortedSelections! {
    _computedSelectionsAndChildren.unsafelyUnwrapped.0
  }

  // MARK: - Initialization  

  convenience init(
    selectionSet: SelectionSet,
    compilationResult: CompilationResult
  ) {
    self.init(selections: selectionSet.selections,
              type: selectionSet.parentType,
              compilationResult: compilationResult)
  }

  convenience init(
    selectionSet: SelectionSet,
    parent: ASTSelectionSet
  ) {
    self.init(selections: selectionSet.selections,
              type: selectionSet.parentType,
              parent: parent)
  }

  private init(
    selections: [Selection],
    type: GraphQLCompositeType,
    compilationResult: CompilationResult
  ) {
    self.type = type
    self.compilationResult = compilationResult
    self.mergedSelectionBuilder = MergedSelectionBuilder()

    _computedSelectionsAndChildren = mergedSelectionBuilder
      .computeSelectionsAndChildren(from: selections, for: self)
  }

  private init(
    selections: [Selection],
    type: GraphQLCompositeType,
    parent: ASTSelectionSet
  ) {
    self.parent = parent
    self.type = type
    self.compilationResult = parent.compilationResult
    self.mergedSelectionBuilder = parent.mergedSelectionBuilder

    _computedSelectionsAndChildren = mergedSelectionBuilder
      .computeSelectionsAndChildren(from: selections, for: self)
  }

  static func == (lhs: ASTSelectionSet, rhs: ASTSelectionSet) -> Bool {
    return lhs.parent == rhs.parent &&
    lhs.type == rhs.type &&
    lhs.selections == rhs.selections
  }

  var debugDescription: String {
    var desc = type.debugDescription
    if !children.isEmpty {
      desc += " {"
      children.values.forEach { child in
        desc += "\n  \(indented: child.debugDescription)"
      }
      desc += "\n\(indented: "}")"
    }
    return desc
  }
}
