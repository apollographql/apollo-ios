# env-ci

Get environment variables exposed by CI services.

[![Travis](https://img.shields.io/travis/pvdlg/env-ci.svg)](https://travis-ci.org/pvdlg/env-ci)
[![Codecov](https://img.shields.io/codecov/c/github/pvdlg/env-ci.svg)](https://codecov.io/gh/pvdlg/env-ci)
[![Greenkeeper badge](https://badges.greenkeeper.io/pvdlg/env-ci.svg)](https://greenkeeper.io/)

Adapted from [codecov-node](https://github.com/codecov/codecov-node/blob/master/lib/detect.js).

## Install

```bash
$ npm install --save env-ci
```

## Usage

```js
const envCi = require('env-ci');

const {name, service, isCi, branch, commit, tag, build, buildUrl, job, jobUrl, isPr, pr, prBranch, slug, root} = envCi();

if (isCI) {
  console.log(`Building repo ${slug} on ${name} service`);

  if (isPr) {
    console.log(`Building Pull Request #${pr} originating from branch ${prBranch} and targeting branch ${branch}`);
  } else {
    console.log(`Building branch ${branch}`);
  }

  if (service === 'travis') {
    // Do something specific to Travis CI
  }
}
```

## Supported variables

| Variable   | Description                                                                                            |
|------------|--------------------------------------------------------------------------------------------------------|
| `name`     | CI service Commercial name (e.g. `Travis CI`, `CircleCI`, `GitLab CI/CD`)                              |
| `service`  | Standardized CI service name (e.g. `travis`, `circleci`, `gitlab`)                                     |
| `isCi`     | `true` is running on a CI, `false` otherwise                                                           |
| `branch`   | Git branch being built or targeted by a Pull Request                                                   |
| `commit`   | Commit sha that triggered the CI build                                                                 |
| `tag`      | Git tag that triggered the CI build                                                                    |
| `build`    | CI service build number                                                                                |
| `buildUrl` | Link to the CI service build                                                                           |
| `job`      | CI service job number                                                                                  |
| `jobUrl`   | Link to the CI service job                                                                             |
| `isPr`     | `true` if the build has been triggered by a Pull Request, `false` otherwise                            |
| `pr`       | Pull Request number (only for builds triggered by a Pull Request)                                      |
| `prBranch` | Git branch branch from which the Pull Request originated (only for builds triggered by a Pull Request) |
| `slug`     | The slug (in form: owner_name/repo_name) of the repository currently being built                       |
| `root`     | The path to the directory where the repository is being built                                          |

**Note**: Some variables can be detected only on certain CI services. See [Supported CI](#supported-ci).

**Note**: The `pr` and `prBranch` properties are only available for builds triggered when a Pull Request is opened/updated and not on builds triggered by a push on a branch even if that branch happens to be the branch from which the Pull Request originated.

## Supported CI

| CI Service (`name`)                                                                                                                     |  `service`  |       `isCi`       |          `branch`           |      `commit`      |       `tag`        |      `build`       |     `buildUrl`     |       `job`        |      `jobUrl`      |        `isPr`         |         `pr`          |      `prBranch`       |       `slug`       |       `root`       |
|-----------------------------------------------------------------------------------------------------------------------------------------|:-----------:|:------------------:|:---------------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:---------------------:|:---------------------:|:---------------------:|:------------------:|:------------------:|
| [AppVeyor]( https://www.appveyor.com/docs/environment-variables)                                                                        | `appveyor`  | :white_check_mark: |     :white_check_mark:      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   | :white_check_mark: | :white_check_mark: |
| [Bamboo](https://confluence.atlassian.com/bamboo/bamboo-variables-289277087.html)                                                       |  `bamboo`   | :white_check_mark: |     :white_check_mark:      | :white_check_mark: |        :x:         | :white_check_mark: | :white_check_mark: | :white_check_mark: |        :x:         |          :x:          |          :x:          |          :x:          |        :x:         | :white_check_mark: |
| [Bitbucket](https://confluence.atlassian.com/bitbucket/environment-variables-794502608.html)                                            | `bitbucket` | :white_check_mark: |     :white_check_mark:      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |        :x:         |        :x:         |          :x:          |          :x:          |          :x:          | :white_check_mark: | :white_check_mark: |
| [Bitrise](https://devcenter.bitrise.io/builds/available-environment-variables/#exposed-by-bitriseio)                                    |  `bitrise`  | :white_check_mark: |     :white_check_mark:      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |        :x:         |        :x:         |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   | :white_check_mark: |        :x:         |
| [Buddy](https://buddy.works/knowledge/deployments/how-use-environment-variables#default-environment-variables)                          |   `buddy`   | :white_check_mark: |     [:warning:](#buddy)     | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |        :x:         |        :x:         |  :white_check_mark:   |  :white_check_mark:   |          :x:          | :white_check_mark: |        :x:         |
| [Buildkite](https://buildkite.com/docs/builds/environment-variables)                                                                    | `buildkite` | :white_check_mark: |     :white_check_mark:      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |        :x:         |        :x:         |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   | :white_check_mark: | :white_check_mark: |
| [CircleCI](https://circleci.com/docs/2.0/env-vars/#built-in-environment-variables)                                                      | `circleci`  | :white_check_mark: |   [:warning:](#circleci)    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |        :x:         |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   | :white_check_mark: |        :x:         |
| [Cirrus CI](https://cirrus-ci.org/guide/writing-tasks/#environment-variables)                                                           |  `cirrus`   | :white_check_mark: |     :white_check_mark:      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   | :white_check_mark: | :white_check_mark: |
| [AWS CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-env-vars.html)                                     | `codebuild` | :white_check_mark: | [:warning:](#aws-codebuild) | :white_check_mark: |        :x:         | :white_check_mark: | :white_check_mark: |        :x:         |        :x:         |          :x:          |          :x:          |          :x:          |        :x:         | :white_check_mark: |
| [Codefresh](https://codefresh.io/docs/docs/codefresh-yaml/variables#system-provided-variables)                                          | `codefresh` | :white_check_mark: |     :white_check_mark:      | :white_check_mark: |        :x:         | :white_check_mark: | :white_check_mark: |        :x:         |        :x:         |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   | :white_check_mark: | :white_check_mark: |
| [Codeship](https://documentation.codeship.com/basic/builds-and-configuration/set-environment-variables/#default-environment-variables)  | `codeship`  | :white_check_mark: |     :white_check_mark:      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |        :x:         |        :x:         |          :x:          |          :x:          |          :x:          | :white_check_mark: |        :x:         |
| [Drone](https://readme.drone.io/reference/environ/)                                                                                     |   `drone`   | :white_check_mark: |     :white_check_mark:      | :white_check_mark: | :white_check_mark: | :white_check_mark: |        :x:         | :white_check_mark: |        :x:         |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   | :white_check_mark: |        :x:         |
| [GitHub Actions](https://developer.github.com/actions/creating-github-actions/accessing-the-runtime-environment/#environment-variables) |  `github`   | :white_check_mark: |     :white_check_mark:      | :white_check_mark: |        :x:         |        :x:         |        :x:         |        :x:         |        :x:         |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   | :white_check_mark: | :white_check_mark: |
| [GitLab CI/CD](https://docs.gitlab.com/ce/ci/variables/README.html)                                                                     |  `gitlab`   | :white_check_mark: |     :white_check_mark:      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |          :x:          |          :x:          |          :x:          | :white_check_mark: | :white_check_mark: |
| [Jenkins](https://wiki.jenkins.io/display/JENKINS/Building+a+software+project)                                                          |  `jenkins`  | :white_check_mark: |    [:warning:](#jenkins)    | :white_check_mark: |        :x:         | :white_check_mark: | :white_check_mark: |        :x:         |        :x:         | [:warning:](#jenkins) | [:warning:](#jenkins) | [:warning:](#jenkins) | :white_check_mark: | :white_check_mark: |
| [Sail CI](https://sail.ci/docs/environment-variables)                                                                                   |   `sail`    | :white_check_mark: |     [:warning:](#sail)      | :white_check_mark: |        :x:         |        :x:         |        :x:         |        :x:         |        :x:         |  :white_check_mark:   |  :white_check_mark:   |          :x:          | :white_check_mark: | :white_check_mark: |
| [Semaphore](https://semaphoreci.com/docs/available-environment-variables.html)                                                          | `semaphore` | :white_check_mark: |   [:warning:](#semaphore)   | :white_check_mark: |        :x:         | :white_check_mark: |        :x:         | :white_check_mark: |        :x:         |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   | :white_check_mark: | :white_check_mark: |
| [Shippable](http://docs.shippable.com/ci/env-vars/#stdEnv)                                                                              | `shippable` | :white_check_mark: |     :white_check_mark:      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |        :x:         |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   | :white_check_mark: | :white_check_mark: |
| [TeamCity](https://confluence.jetbrains.com/display/TCD10/Predefined+Build+Parameters)                                                  | `teamcity`  | :white_check_mark: |     :white_check_mark:      | :white_check_mark: |        :x:         | :white_check_mark: |        :x:         |        :x:         |        :x:         |          :x:          |          :x:          |          :x:          | :white_check_mark: | :white_check_mark: |
| [Travis CI](https://docs.travis-ci.com/user/environment-variables#default-environment-variables)                                        |  `travis`   | :white_check_mark: |     :white_check_mark:      | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   | :white_check_mark: | :white_check_mark: |
| [Visual Studio Team Services](https://docs.microsoft.com/en-us/vsts/pipelines/build/variables)                                          |   `vsts`    | :white_check_mark: |     :white_check_mark:      | :white_check_mark: |        :x:         | :white_check_mark: |        :x:         |        :x:         |        :x:         |  :white_check_mark:   |  :white_check_mark:   |  :white_check_mark:   |        :x:         | :white_check_mark: |
| [Wercker](http://devcenter.wercker.com/docs/environment-variables/available-env-vars#hs_cos_wrapper_name)                               |  `wercker`  | :white_check_mark: |     :white_check_mark:      | :white_check_mark: |        :x:         | :white_check_mark: | :white_check_mark: |        :x:         |        :x:         |          :x:          |          :x:          |          :x:          | :white_check_mark: | :white_check_mark: |

:warning: See [Caveats](#caveats)

**Note**: Unsupported properties will always be `undefined`. For example if a Ci services doesn't support triggering builds when a Pull Request is opened/updated, `isPr` will be `undefined`.

**Note**: If none of the above CI services is detected, `commit` and `branch` are determined based on the local Git repository, and `isCi` is determined based on the `CI` environment variable.

## API

### envCi(options) => Result

#### options

Type: `Object`

#### env

Type: `Object`<br>
Default: `process.env`

The object to read environment variables from.

#### cwd

Type: `String`<br>
Default: `process.cwd()`

The current working directory in which to execute `git` commands used to determine the `commit` and `branch` [Result](#result) properties in case no [supported CI](#supported-ci) is detected.

### Result

Type: `Object`

[Environment variables values](#supported-variables) exposed by the CI service.

## Caveats

### AWS CodeBuild

AWS CodeBuild doesn't provide an environment variable to determine the current Git branch being built. In addition, it clones the repository in a [detached head state](https://git-scm.com/docs/git-checkout#_detached_head) so the branch cannot be determined with `git rev-parse --abbrev-ref HEAD`.
To work around this limitation, `env-ci` look for the remote branches having the same `HEAD` as the local detached `HEAD` to determine the branch from which the detached `HEAD` was created.
In the rare case where there is multiple remote branches with the same `HEAD` as the local detached `HEAD`, `env-ci` will arbitrarily pick the first one. This can lead to an inaccurate `branch` value in such circumstances.

### Buddy

For builds triggered when [a Pull Request is opened/updated](https://buddy.works/knowledge/deployments/pull-requests), Buddy doesn't provide an environment variable indicating the branch from which the Pull Request originated nor the target branch. It also build from a branch named `pull/<PR number>` so the target branch cannot be determined with a `git` command.
Therefore in the case of Pull Request builds, `env-ci` will not be able to determine the `branch` and `prBranch` properties.

See [feature request](https://forum.buddy.works/t/determine-pull-request-branch-with-environment-variable/911).

### CircleCI

For builds triggered when a Pull Request is opened/updated, CircleCI doesn't provide an environment variable indicating the target branch.
Therefore in the case of Pull Request builds, `env-ci` will not be able to determine the `branch` property. However `prBranch` will be set.

See [feature request](https://discuss.circleci.com/t/create-a-circle-target-branch-envar/10022).

## Jenkins

Triggering build when a Pull Request is opened/updated is supported only via the [ghprb-plugin](https://github.com/jenkinsci/ghprb-plugin) and [gitlab-plugin](https://github.com/jenkinsci/gitlab-plugin). Therefore `env-ci` will set `isPr`, `pr` and `prBranch` and define `branch` with the Pull Request target branch only if one those plugin is used.

## Sail

For builds triggered when a Pull Request is opened/updated, Sail doesn't provide an environment variable indicating the target branch, and the one for the current branch is set to `pull/<PR number>` independently of the the branch name from which the Pull Request originated.
Therefore in the case of Pull Request builds, `env-ci` will not be able to determine the `branch` and `prBranch` properties.

## Semaphore

For builds triggered when a Pull Request is opened/updated, Semaphore doesn't provide an environment variable indicating the target branch.
Therefore in the case of Pull Request builds, `env-ci` will not be able to determine the `branch` property. However `prBranch` will be set.
