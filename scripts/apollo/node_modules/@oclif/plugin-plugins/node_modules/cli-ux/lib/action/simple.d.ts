import { ActionBase, ActionType } from './base';
export default class SimpleAction extends ActionBase {
    type: ActionType;
    protected _start(): void;
    protected _pause(icon?: string): void;
    protected _resume(): void;
    protected _updateStatus(status: string, prevStatus?: string, newline?: boolean): void;
    protected _stop(status: string): void;
    private _render;
    private _flush;
}
