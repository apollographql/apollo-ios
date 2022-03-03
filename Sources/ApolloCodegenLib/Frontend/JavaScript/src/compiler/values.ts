import { ValueNode } from 'graphql';

export type GraphQLValue =
  | {
      kind:
        | 'Variable'
        | 'IntValue'
        | 'FloatValue'
        | 'StringValue'
        | 'EnumValue';
      value: string;
    }
  | { kind: 'BooleanValue'; value: boolean }
  | { kind: 'NullValue' }
  | GraphQLListValue
  | GraphQLObjectValue;

export interface GraphQLListValue {
  kind: 'ListValue';
  value: GraphQLValue[];
}

export interface GraphQLObjectValue {
  kind: 'ObjectValue';
  value: { [name: string]: GraphQLValue };
}

export function valueFromValueNode(valueNode: ValueNode): GraphQLValue {
  switch (valueNode.kind) {
    case 'Variable':
      return { kind: valueNode.kind, value: valueNode.name.value };
    case 'ListValue':
      return {
        kind: valueNode.kind,
        value: valueNode.values.map(valueFromValueNode),
      };
    case 'ObjectValue':
      return {
        kind: valueNode.kind,
        value: valueNode.fields.reduce((object, field) => {
          object[field.name.value] = valueFromValueNode(field.value);
          return object;
        }, {} as GraphQLObjectValue['value']),
      };
    default:
      return valueNode;
  }
}
