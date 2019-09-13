import { parseValue } from "graphql";

import { valueFromValueNode } from "../utilities/graphql";

describe("#valueFromValueNode", () => {
  test(`should return a number for an IntValue`, () => {
    const valueNode = parseValue("1");
    const value = valueFromValueNode(valueNode);

    expect(value).toBe(1);
  });

  test(`should return a number for a FloatValue`, () => {
    const valueNode = parseValue("1.0");
    const value = valueFromValueNode(valueNode);

    expect(value).toBe(1.0);
  });

  test(`should return a boolean for a BooleanValue`, () => {
    const valueNode = parseValue("true");
    const value = valueFromValueNode(valueNode);

    expect(value).toBe(true);
  });

  test(`should return null for a NullValue`, () => {
    const valueNode = parseValue("null");
    const value = valueFromValueNode(valueNode);

    expect(value).toBe(null);
  });

  test(`should return a string for a StringValue`, () => {
    const valueNode = parseValue('"foo"');
    const value = valueFromValueNode(valueNode);

    expect(value).toBe("foo");
  });

  test(`should return a string for an EnumValue`, () => {
    const valueNode = parseValue("JEDI");
    const value = valueFromValueNode(valueNode);

    expect(value).toBe("JEDI");
  });

  test(`should return an object for a Variable`, () => {
    const valueNode = parseValue("$something");
    const value = valueFromValueNode(valueNode);

    expect(value).toEqual({ kind: "Variable", variableName: "something" });
  });

  test(`should return an array for a ListValue`, () => {
    const valueNode = parseValue('[ "foo", 1, JEDI, $something ]');
    const value = valueFromValueNode(valueNode);

    expect(value).toEqual([
      "foo",
      1,
      "JEDI",
      { kind: "Variable", variableName: "something" }
    ]);
  });

  test(`should return an object for an ObjectValue`, () => {
    const valueNode = parseValue(
      '{ foo: "foo", bar: 1, bla: JEDI, baz: $something }'
    );
    const value = valueFromValueNode(valueNode);

    expect(value).toEqual({
      foo: "foo",
      bar: 1,
      bla: "JEDI",
      baz: { kind: "Variable", variableName: "something" }
    });
  });
});
