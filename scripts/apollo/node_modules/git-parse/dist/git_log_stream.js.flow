import childProcess from 'child_process';
import {
  gitLogCommitMarker,
  gitLogMessageMarker,
  gitLogFileMarker
} from './constants/git_log_format_markers';

const gitLogFormatString = `${gitLogCommitMarker}%n%H%n%an%n%ae%n%aD%n${gitLogMessageMarker}%n%B%n${gitLogFileMarker}`;

/*
  Returns a stream of git log data from a git repository
*/
const gitLogStream = (pathToRepo, options = {}) => {
  const sinceCommit = options.sinceCommit ? `${options.sinceCommit}..HEAD` : '';
  const gitParams = [
    'log',
    `--pretty=format:${gitLogFormatString}`,
    '--name-status',
    sinceCommit,
    '--',
    './*',
    ':!node_modules'
  ].filter(elt => elt !== '');

  const gitProcess = childProcess.spawn('git', gitParams, {cwd: pathToRepo});
  const errorHandlers = [];
  gitProcess.on('error', e => errorHandlers.forEach(handler => handler(e)));
  return {
    stream: gitProcess.stdout,
    addErrorHandler: fn => errorHandlers.push(fn)
  };
};

export default gitLogStream;
