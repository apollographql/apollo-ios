/// <reference types="node" />
import { ActionBase, ActionType } from './base';
export default class SpinnerAction extends ActionBase {
    type: ActionType;
    spinner?: NodeJS.Timeout;
    frames: any;
    frameIndex: number;
    constructor();
    protected _start(): void;
    protected _stop(status: string): void;
    protected _pause(icon?: string): void;
    protected _frame(): string;
    private _render;
    private _reset;
    private _lines;
}
