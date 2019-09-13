import { graphqlTypes } from "apollo-language-server";
export declare function validateHistoricParams({ validationPeriod, queryCountThreshold, queryCountThresholdPercentage }: Partial<{
    validationPeriod: string;
    queryCountThreshold: number;
    queryCountThresholdPercentage: number;
}>): Partial<graphqlTypes.HistoricQueryParameters> | null;
//# sourceMappingURL=validateHistoricParams.d.ts.map