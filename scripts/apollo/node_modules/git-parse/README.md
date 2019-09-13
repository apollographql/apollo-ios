
# Git-Parse

`git-parse` is a utility which generates an array of javascript objects representing the current branch of a local git repository's commit history.

## Getting Started


### Prerequisites
```
nodejs version 8 or higher
```

### Installation

```
  npm install --save git-parse
```


### Usage
```
const { gitToJs } = require('git-parse');

const commitsPromise = gitToJs('path/to/repo/');

commitsPromise.then(commits => console.log(JSON.stringify(commits, null, 2)));

```
**Console Output:**
```
[
  {
     "hash":"7cedc121ee163d859dfdb9911e627d4b5933cc6d",
     "authorName":"mpackard@wayfair.com",
     "authorEmail":"mpackard@wayfair.com",
     "date":"Wed, 10 Jan 2018 16:44:52 -0500",
     "message":"initial setup",
     "filesAdded":[
        { "path":"packages/raspberry-popsicle/index.js" },
        { "path":"packages/raspberry-popsicle/package-lock.json" },
        { "path":"packages/raspberry-popsicle/package.json" }
     ],
     "filesDeleted":[ ],
     "filesModified":[ ],
     "filesRenamed":[ ]
  },
  {                                                                                    
    "hash": "226f032eb87ac1eb18b7212eeaf1356980a9ae03",                                
    "authorName": "mpackard@wayfair.com",                                              
    "authorEmail": "mpackard@wayfair.com",                                             
    "date": "Wed, 10 Jan 2018 15:25:16 -0500",                                         
    "message": "add README",                                                           
    "filesAdded": [                                                                    
      { "path": "README.md" }                                                                                
    ],                                                                                 
    "filesDeleted": [],                                                                
    "filesModified": [],                                                               
    "filesRenamed": []                                                                 
  }                                   
]
```

## API

### gitToJs(pathToRepo, [options])

Returns a promise which resolves with a list of objects describing git commits on the current branch. `pathToRepo` is a string. `options` is an optional object with one property, `sinceCommit`, which is a commit hash. If `sinceCommit` is present, gitToJs will return logs for commits _after_ the commit specified.

```
const { gitToJs } = require('git-parse');

const commitsPromise = gitToJs('path/to/repo/');

commitsPromise.then(commits => console.log(JSON.stringify(commits, null, 2)));
```

### checkOutCommit(pathToRepo, commitHash, [options])

Checks a repository out to a given commit. `hash` is the commit hash. Options is an optional object with one property, `force`. `force` adds `--force` to the [underlying git checkout](https://git-scm.com/docs/git-checkout#git-checkout--f). Returns a promise.

### gitPull(pathToRepo)

Runs 'git pull' on the repository at the given path. Returns a promise.

### gitDiff(pathToRepo, commitHash1, [commitHash2], [file])

Returns a git diff given a path to the repo, a commit, an optional second commit, and an optional file path.

Returns a promise resolving with the diff as a string.

## License

This project is licensed under the BSD-2-Clause license.

