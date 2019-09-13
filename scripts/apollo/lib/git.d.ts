export interface Commit {
    authorName: string | null;
    authorEmail: string | null;
}
export interface GitContext {
    committer?: string;
    commit: string;
    message?: string;
    remoteUrl?: string;
    branch?: string;
}
export declare const gitInfo: (log: (message?: string | undefined, ...args: any[]) => void) => Promise<GitContext | undefined>;
//# sourceMappingURL=git.d.ts.map