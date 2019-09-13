import { ListrRenderer, ListrTaskObject, ListrOptions, ListrError } from "listr";
export declare class CompactRenderer<Ctx> implements ListrRenderer {
    _tasks: ReadonlyArray<ListrTaskObject<Ctx>>;
    constructor(tasks: ReadonlyArray<ListrTaskObject<Ctx>>, options: ListrOptions<Ctx>);
    static readonly nonTTY: boolean;
    render(): void;
    end(err: ListrError<Ctx>): void;
}
//# sourceMappingURL=CompactRenderer.d.ts.map