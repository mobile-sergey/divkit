import type { DivBase } from '../../typings/common';

export interface PatchChange {
    id: string;
    items?: DivBase[];
}

export interface Patch {
    templates?: Record<string, DivBase>;
    patch: {
        mode?: 'transactional' | 'partial';
        changes: PatchChange[];
    };
}
