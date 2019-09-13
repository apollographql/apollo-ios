import { Command } from './command';
export interface Manifest {
    version: string;
    commands: {
        [id: string]: Command;
    };
}
