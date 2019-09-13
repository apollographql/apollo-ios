import promisify from 'util.promisify';
import childProcess from 'child_process';

const exec = promisify(childProcess.exec);

/**
 * Returns a git diff given a path to the repo, a commit,
 * an optional second commit, and an optional file.
 *
 * Returns the diff as a string.
 */
const gitDiff = (pathToRepo, commit1, commit2 = '', file = '') =>
  exec(`git diff ${commit1} ${commit2} -- ${file}`, {
    cwd: pathToRepo,
    encoding: 'utf8',
    maxBuffer: 1024 * 1000
  }).then(output => output.stdout);

export default gitDiff;
