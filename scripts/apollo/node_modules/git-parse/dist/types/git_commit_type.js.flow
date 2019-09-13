// @flow
type FileModification = {
  path: string,
  linesAdded?: number,
  linesDeleted?: number
};

type FileRename = {
  oldPath: string,
  newPath: string
};

type GitCommit = {
  hash: string,
  authorName: string,
  authorEmail: string,
  date: string,
  message: string,
  filesAdded: FileModification[],
  filesDeleted: FileModification[],
  filesModified: FileModification[],
  filesRenamed: FileRename[]
};

export type {GitCommit, FileModification, FileRename};
