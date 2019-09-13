export interface IPromptOptions {
    prompt?: string;
    type?: 'normal' | 'mask' | 'hide' | 'single';
    timeout?: number;
    /**
     * Requires user input if true, otherwise allows empty input
     */
    required?: boolean;
    default?: string;
}
/**
 * prompt for input
 */
export declare function prompt(name: string, options?: IPromptOptions): Promise<any>;
/**
 * confirmation prompt (yes/no)
 */
export declare function confirm(message: string): Promise<boolean>;
/**
 * "press anykey to continue"
 */
export declare function anykey(message?: string): Promise<void>;
