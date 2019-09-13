git-rev-sync [![Build Status](https://travis-ci.org/kurttheviking/git-rev-sync-js.svg?branch=master)](https://travis-ci.org/kurttheviking/git-rev-sync-js)
============

Synchronously get the current git commit hash, tag, count, branch or commit message. Forked from [git-rev](https://github.com/tblobaum/git-rev).


## Example

```js
var git = require('git-rev-sync');

console.log(git.short());
// 75bf4ee

console.log(git.long());
// 75bf4eea9aa1a7fd6505d0d0aa43105feafa92ef

console.log(git.branch());
// master
```

You can also run these examples via: `npm run examples`


## Install

`npm install git-rev-sync --save`


## API

``` js
var git = require('git-rev-sync');
```

#### `git.short([filePath], [length])` &rarr; &lt;String&gt;

return the result of `git rev-parse --short HEAD`

- optional `filePath` parameter can be used to run the command against a repo outside the current working directory
- optional `length` parameter can be used to set the desired hash length (defaults to `7`)

#### `git.long([filePath])` &rarr; &lt;String&gt;

return the result of `git rev-parse HEAD`; optional `filePath` parameter can be used to run the command against a repo outside the current working directory

#### `git.branch([filePath])` &rarr; &lt;String&gt;

return the current branch; optional `filePath` parameter can be used to run the command against a repo outside the current working directory

#### `git.count()` &rarr; &lt;Number&gt;

return the count of commits across all branches; this method will fail if the `git` command is not found in `PATH`

#### `git.date()` &rarr; &lt;Date&gt;

returns the date of the current commit; this method will fail if the `git` command is not found in `PATH`

#### `git.isDirty()` &rarr; &lt;Boolean&gt;

returns true if there are uncommitted changes; this method will fail if the `git` command is not found in `PATH`

#### `git.isTagDirty()` &rarr; &lt;Boolean&gt;

returns true if the current tag is dirty; this method will fail if the `git` command is not found in `PATH`

#### `git.message()` &rarr; &lt;String&gt;

return the current commit message; this method will fail if the `git` command is not found in `PATH`

#### `git.remoteUrl()` &rarr; &lt;String&gt;

return the current remote URL; this method will fail if the `git` command is not found in `PATH`

#### `git.tag([markDirty])` &rarr; &lt;String&gt;

return the current tag and mark as dirty if markDirty is truthful; this method will fail if the `git` command is not found in `PATH`


## License

[MIT](https://github.com/kurttheviking/git-rev-sync/blob/master/LICENSE)


## Donations

[We're all in this together](https://cash.me/$kurttheviking)
