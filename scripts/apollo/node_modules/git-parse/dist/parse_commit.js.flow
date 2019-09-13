// @flow

import type {
  GitCommit,
  FileModification,
  FileRename
} from './types/git_commit_type';

import {
  gitLogMessageMarker,
  gitLogFileMarker
} from './constants/git_log_format_markers';

const parseCommit = (commit: string[]): GitCommit => {
  const hash = commit[0];
  const authorName = commit[1];
  const authorEmail = commit[2];
  const date = commit[3];

  const messageIndex = commit.findIndex(line =>
    line.match(gitLogMessageMarker)
  );
  const fileIndex = commit.findIndex(line => line.match(gitLogFileMarker));
  const message = commit.slice(messageIndex + 1, fileIndex).join('\n');
  const files = commit.slice(fileIndex + 1);

  const addPattern = /^A\s([^\s]+)/;
  const deletePattern = /^D\s([^\s]+)/;
  const modifyPattern = /^M\s([^\s]+)/;
  const renamePattern = /^R[0-9]+\s(.+)\s(.+)/;

  const filterFileChanges = (pattern): FileModification[] => {
    return files.reduce((accumulator, file) => {
      const match = file.match(pattern);
      if (match) {
        accumulator.push({path: match[1]});
      }

      return accumulator;
    }, []);
  };

  const filesRenamed: FileRename[] = files.reduce((accumulator, file) => {
    const match = file.match(renamePattern);
    if (match) {
      accumulator.push({
        oldPath: match[1],
        newPath: match[2]
      });
    }
    return accumulator;
  }, []);

  const parsedCommit = {
    hash,
    authorName,
    authorEmail,
    date,
    message,
    filesAdded: filterFileChanges(addPattern),
    filesDeleted: filterFileChanges(deletePattern),
    filesModified: filterFileChanges(modifyPattern),
    filesRenamed
  };

  return parsedCommit;
};

export default parseCommit;
