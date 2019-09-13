import {
  GraphQLSchema,
  GraphQLCompositeType,
  GraphQLField,
  FieldNode,
  SchemaMetaFieldDef,
  TypeMetaFieldDef,
  TypeNameMetaFieldDef,
  ASTNode,
  Kind,
  NameNode,
  visit,
  print,
  DirectiveNode,
  SelectionSetNode,
  DirectiveDefinitionNode,
  isObjectType,
  isInterfaceType,
  isUnionType
} from "graphql";

export function isNode(maybeNode: any): maybeNode is ASTNode {
  return maybeNode && typeof maybeNode.kind === "string";
}

export type NamedNode = ASTNode & {
  name: NameNode;
};

export function isNamedNode(node: ASTNode): node is NamedNode {
  return "name" in node;
}

export function isDirectiveDefinitionNode(
  node: ASTNode
): node is DirectiveDefinitionNode {
  return node.kind === Kind.DIRECTIVE_DEFINITION;
}

export function highlightNodeForNode(node: ASTNode): ASTNode {
  switch (node.kind) {
    case Kind.VARIABLE_DEFINITION:
      return node.variable;
    default:
      return isNamedNode(node) ? node.name : node;
  }
}

/**
 * Not exactly the same as the executor's definition of getFieldDef, in this
 * statically evaluated environment we do not always have an Object type,
 * and need to handle Interface and Union types.
 */
export function getFieldDef(
  schema: GraphQLSchema,
  parentType: GraphQLCompositeType,
  fieldAST: FieldNode
): GraphQLField<any, any> | undefined {
  const name = fieldAST.name.value;
  if (
    name === SchemaMetaFieldDef.name &&
    schema.getQueryType() === parentType
  ) {
    return SchemaMetaFieldDef;
  }
  if (name === TypeMetaFieldDef.name && schema.getQueryType() === parentType) {
    return TypeMetaFieldDef;
  }
  if (
    name === TypeNameMetaFieldDef.name &&
    (isObjectType(parentType) ||
      isInterfaceType(parentType) ||
      isUnionType(parentType))
  ) {
    return TypeNameMetaFieldDef;
  }
  if (isObjectType(parentType) || isInterfaceType(parentType)) {
    return parentType.getFields()[name];
  }

  return undefined;
}

/**
 * Remove specific directives
 *
 * The `ast` param must extend ASTNode. We use a generic to indicate that this function returns the same type
 * of it's first parameter.
 */
export function removeDirectives<AST extends ASTNode>(
  ast: AST,
  directiveNames: string[]
): AST {
  if (!directiveNames.length) return ast;
  return visit(ast, {
    Directive(node: DirectiveNode): DirectiveNode | null {
      if (!!directiveNames.find(name => name === node.name.value)) return null;
      return node;
    }
  });
}

/**
 * Recursively remove orphaned fragment definitions that have their names included in
 * `fragmentNamesEligibleForRemoval`
 *
 * We expclitily require the fragments to be listed in `fragmentNamesEligibleForRemoval` so we only strip
 * fragments that were orphaned by an operation, not fragments that started as oprhans
 *
 * The `ast` param must extend ASTNode. We use a generic to indicate that this function returns the same type
 * of it's first parameter.
 */
function removeOrphanedFragmentDefinitions<AST extends ASTNode>(
  ast: AST,
  fragmentNamesEligibleForRemoval: Set<string>
): AST {
  /**
   * Flag to keep track of removing any fragments
   */
  let anyFragmentsRemoved = false;

  // Aquire names of all fragment spreads
  const fragmentSpreadNodeNames = new Set<string>();
  visit(ast, {
    FragmentSpread(node) {
      fragmentSpreadNodeNames.add(node.name.value);
    }
  });

  // Strip unused fragment definitions. Flag if we've removed any so we know if we need to continue
  // recursively checking.
  ast = visit(ast, {
    FragmentDefinition(node) {
      if (
        fragmentNamesEligibleForRemoval.has(node.name.value) &&
        !fragmentSpreadNodeNames.has(node.name.value)
      ) {
        // This definition is not used, remove it.
        anyFragmentsRemoved = true;
        return null;
      }

      return undefined;
    }
  });

  if (anyFragmentsRemoved) {
    /* Handles the special case where a Fragment was not removed because it was not yet orphaned when being
       `visit`ed. As an example:

        ```jsx
        fragment Two on Node {
          id
        }
        fragment One on Query {
          hero {
            ...Two @client
          }
        }

        { ...One }
        ```

        On the first visit, `Two` will not be removed. After `One` is removed, `Two` becomes orphaned. If any
        nodes were removed on this pass; run another pass to see if there are more nodes that are now
        orphaned.
      */
    return removeOrphanedFragmentDefinitions(
      ast,
      fragmentNamesEligibleForRemoval
    );
  }

  return ast;
}

/**
 * Remove nodes that have zero-length selection sets
 *
 * The `ast` param must extend ASTNode. We use a generic to indicate that this function returns the same type
 * of it's first parameter.
 */
function removeNodesWithEmptySelectionSets<AST extends ASTNode>(ast: AST): AST {
  ast = visit(ast, {
    enter(node) {
      // If this node _has_ a `selectionSet` and it's zero-length, then remove it.
      return "selectionSet" in node &&
        node.selectionSet != null &&
        node.selectionSet.selections.length === 0
        ? null
        : undefined;
    }
  });

  return ast;
}

/**
 * Remove nodes from `ast` when they have a directive in `directiveNames`
 *
 * The `ast` param must extend ASTNode. We use a generic to indicate that this function returns the same type
 * of it's first parameter.
 */
export function removeDirectiveAnnotatedFields<AST extends ASTNode>(
  ast: AST,
  directiveNames: string[]
): AST {
  print;
  if (!directiveNames.length) return ast;

  /**
   * All fragment definition names we've removed due to a matching directive
   *
   * We keep track of these so we can remove associated spreads
   */
  const removedFragmentDefinitionNames = new Set<string>();

  /**
   * All fragment spreads that have been removed
   *
   * We can only remove fragment definitions for fragment spreads that we've removed
   */
  const removedFragmentSpreadNames = new Set<string>();

  // Remove all nodes with a matching directive in `directiveNames`. Also, remove any operations that now have
  // no selection set
  ast = visit(ast, {
    enter(node) {
      // Strip all nodes that contain a directive we wish to remove
      if (
        "directives" in node &&
        node.directives &&
        node.directives.find(directive =>
          directiveNames.includes(directive.name.value)
        )
      ) {
        /*
        If we're removing a fragment definition then save the name so we can remove anywhere this fragment was
        spread. This happens when a fragment definition itself has a matching directive on it, like this
        (assuming that `@client` is a directive we want to remove):

        ```graphql
        fragment SomeFragmentDefinition on SomeType @client { fields }
        ```
        */
        if (node.kind === Kind.FRAGMENT_DEFINITION) {
          removedFragmentDefinitionNames.add(node.name.value);
        }

        /*
        This node is going to be removed. Mark all fragment spreads nested under this node as eligible for
        removal from the document. For example, assuming `@client` is a directive we want to remove:

        ```graphql
        clientObject @client {
          ...ClientObjectFragment
        }
        ```

        We're going to remove `clientObject` here, which will also remove `ClientObjectFragment`. If there are
        no other instances of `ClientObjectFragment`, we're goign to remove it's definition as well.

        We only remove definitions for spreads we've removed so we don't remove fragment definitions that were
        never spread; as this is the kind of error `client:check` is inteded to flag.
        */
        visit(node, {
          FragmentSpread(node) {
            removedFragmentSpreadNames.add(node.name.value);
          }
        });

        // Remove this node
        return null;
      }

      return undefined;
    }
  });

  // For all fragment definitions we removed, also remove the fragment spreads
  ast = visit(ast, {
    FragmentSpread(node) {
      if (removedFragmentDefinitionNames.has(node.name.value)) {
        removedFragmentSpreadNames.add(node.name.value);

        return null;
      }

      return undefined;
    }
  });

  // Remove all orphaned fragment definitions
  ast = removeOrphanedFragmentDefinitions(ast, removedFragmentSpreadNames);

  // Finally, remove nodes with empty selection sets
  return removeNodesWithEmptySelectionSets(ast);
}

const typenameField = {
  kind: Kind.FIELD,
  name: { kind: Kind.NAME, value: "__typename" }
};

export function withTypenameFieldAddedWhereNeeded(ast: ASTNode) {
  return visit(ast, {
    enter: {
      SelectionSet(node: SelectionSetNode) {
        return {
          ...node,
          selections: node.selections.filter(
            selection =>
              !(
                selection.kind === "Field" &&
                (selection as FieldNode).name.value === "__typename"
              )
          )
        };
      }
    },
    leave(node: ASTNode) {
      if (
        !(
          node.kind === Kind.FIELD ||
          node.kind === Kind.FRAGMENT_DEFINITION ||
          node.kind === Kind.INLINE_FRAGMENT
        )
      ) {
        return undefined;
      }
      if (!node.selectionSet) return undefined;

      if (true) {
        return {
          ...node,
          selectionSet: {
            ...node.selectionSet,
            selections: [typenameField, ...node.selectionSet.selections]
          }
        };
      } else {
        return undefined;
      }
    }
  });
}

export interface ClientSchemaInfo {
  localFields?: string[];
}

declare module "graphql/type/definition" {
  interface GraphQLScalarType {
    clientSchema?: ClientSchemaInfo;
  }

  interface GraphQLObjectType {
    clientSchema?: ClientSchemaInfo;
  }

  interface GraphQLInterfaceType {
    clientSchema?: ClientSchemaInfo;
  }

  interface GraphQLUnionType {
    clientSchema?: ClientSchemaInfo;
  }

  interface GraphQLEnumType {
    clientSchema?: ClientSchemaInfo;
  }
}
