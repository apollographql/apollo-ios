import { DisallowedFieldNames, ValidationOptions } from "../validationRules";

const disallowedFieldNames: DisallowedFieldNames = {
  allFields: [],
  entity: [],
  entityList: []
}

export const emptyValidationOptions: ValidationOptions = {
  schemaName: "TestSchema",
  disallowedFieldNames: disallowedFieldNames,
  disallowedInputParameterNames: [],
};
