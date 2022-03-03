import {
  GraphQLCompositeType,
  GraphQLInputType,
  GraphQLObjectType,
  GraphQLOutputType,
  GraphQLType,
} from "graphql";
import { GraphQLValue } from "./values";

export interface OperationDefinition {
  name: string;
  operationType: OperationType;
  variables: VariableDefinition[];
  rootType: GraphQLObjectType;
  selectionSet: SelectionSet;
  source: string;
  filePath?: string;
}

export type OperationType = "query" | "mutation" | "subscription";

export interface VariableDefinition {
  name: string;
  type: GraphQLType;
  defaultValue?: GraphQLValue;
}

export interface FragmentDefinition {
  name: string;
  typeCondition: GraphQLCompositeType;
  selectionSet: SelectionSet;
  source: string;
  filePath?: string;
}

export interface SelectionSet {
  parentType: GraphQLCompositeType;
  selections: Selection[];
}

export type Selection = Field | InlineFragment | FragmentSpread;

export interface Field {
  kind: "Field";
  name: string;
  alias?: string;
  arguments?: Argument[];
  type: GraphQLOutputType;
  description?: string;
  deprecationReason?: string;
  selectionSet?: SelectionSet;
  directives?: Directive[];
}

export interface Argument {
  name: string;
  value: GraphQLValue;
  type?: GraphQLInputType;
}

export interface InlineFragment {
  kind: "InlineFragment";
  typeCondition?: GraphQLCompositeType;
  selectionSet: SelectionSet;
  directives?: Directive[];
}

export interface FragmentSpread {
  kind: "FragmentSpread";
  fragment: FragmentDefinition;
  directives?: Directive[];
}

export interface Directive {
  name: string;
  arguments?: Argument[];
}
