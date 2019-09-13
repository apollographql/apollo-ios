cli-ux
======

cli IO utilities

[![Version](https://img.shields.io/npm/v/cli-ux.svg)](https://npmjs.org/package/cli-ux)
[![CircleCI](https://circleci.com/gh/oclif/cli-ux/tree/master.svg?style=svg)](https://circleci.com/gh/oclif/cli-ux/tree/master)
[![Appveyor CI](https://ci.appveyor.com/api/projects/status/github/oclif/cli-ux?branch=master&svg=true)](https://ci.appveyor.com/project/heroku/cli-ux/branch/master)
[![Codecov](https://codecov.io/gh/oclif/cli-ux/branch/master/graph/badge.svg)](https://codecov.io/gh/oclif/cli-ux)
[![Known Vulnerabilities](https://snyk.io/test/npm/cli-ux/badge.svg)](https://snyk.io/test/npm/cli-ux)
[![Downloads/week](https://img.shields.io/npm/dw/cli-ux.svg)](https://npmjs.org/package/cli-ux)
[![License](https://img.shields.io/npm/l/cli-ux.svg)](https://github.com/oclif/cli-ux/blob/master/package.json)

# Usage

The following assumes you have installed `cli-ux` to your project with `npm install cli-ux` or `yarn add cli-ux` and have it required in your script (TypeScript example):

```typescript
import cli from 'cli-ux'
cli.prompt('What is your name?')
```

JavaScript:

```javascript
const {cli} = require('cli-ux')

cli.prompt('What is your name?')
```

# cli.prompt()

Prompt for user input.

```typescript
// just prompt for input
await cli.prompt('What is your name?')

// mask input after enter is pressed
await cli.prompt('What is your two-factor token?', {type: 'mask'})

// mask input on keypress (before enter is pressed)
await cli.prompt('What is your password?', {type: 'hide'})

// yes/no confirmation
await cli.confirm('Continue?')

// "press any key to continue"
await cli.anykey()
```

![prompt demo](assets/prompt.gif)

# cli.url(text, uri)

Create a hyperlink (if supported in the terminal)

```typescript
await cli.url('sometext', 'https://google.com')
// shows sometext as a hyperlink in supported terminals
// shows https://google.com in unsupported terminals
```

![url demo](assets/url.gif)

# cli.open

Open a url in the browser

```typescript
await cli.open('https://oclif.io')
```

# cli.action

Shows a spinner

```typescript
// start the spinner
cli.action.start('starting a process')
// show on stdout instead of stderr
cli.action.start('starting a process', {stdout: true})

// stop the spinner
cli.action.stop() // shows 'starting a process... done'
cli.action.stop('custom message') // shows 'starting a process... custom message'
```

This degrades gracefully when not connected to a TTY. It queues up any writes to stdout/stderr so they are displayed above the spinner.

![action demo](assets/action.gif)

# cli.annotation

Shows an iterm annotation

```typescript
// start the spinner
cli.annotation('sometest', 'annotated with this text')
```

![annotation demo](assets/annotation.png)

# cli.wait

Waits for 1 second or given milliseconds

```typescript
await cli.wait()
await cli.wait(3000)
```

# cli.table

Displays tabular data

```typescript
cli.table(data, columns, options)
```

Where:

- `data`: array of data objects to display
- `columns`: [Table.Columns](./src/styled/table.ts)
- `options`: [Table.Options](./src/styled/table.ts)

`cli.table.flags()` returns an object containing all the table flags to include in your command.

```typescript
{
  columns: Flags.string({exclusive: ['additional'], description: 'only show provided columns (comma-separated)'}),
  sort: Flags.string({description: 'property to sort by (prepend '-' for descending)'}),
  filter: Flags.string({description: 'filter property by partial string matching, ex: name=foo'}),
  csv: Flags.boolean({exclusive: ['no-truncate'], description: 'output is csv format'}),
  extended: Flags.boolean({char: 'x', description: 'show extra columns'}),
  'no-truncate': Flags.boolean({exclusive: ['csv'], description: 'do not truncate output to fit screen'}),
  'no-header': Flags.boolean({exclusive: ['csv'], description: 'hide table header from output'}),
}
```

Passing `{only: ['columns']}` or `{except: ['columns']}` as an argument into `cli.table.flags()` will whitelist/blacklist those flags from the returned object.

`Table.Columns` defines the table columns and their display options.

```typescript
const columns: Table.Columns = {
  // where `.name` is a property of a data object
  name: {}, // "Name" inferred as the column header
  id: {
    header: 'ID', // override column header
    minWidth: '10', // column must display at this width or greater
    extended: true, // only display this column when the --extended flag is present
    get: row => `US-O1-${row.id}`, // custom getter for data row object
  },
}
```

`Table.Options` defines the table options, most of which are the parsed flags from the user for display customization, all of which are optional.

```typescript
const options: Table.Options = {
  printLine: myLogger, // custom logger
  columns: flags.columns,
  sort: flags.sort,
  filter: flags.filter,
  csv: flags.csv,
  extended: flags.extended,
  'no-truncate': flags['no-truncate'],
  'no-header': flags['no-header'],
}
```

Example class:

```typescript
import {Command} from '@oclif/command'
import {cli} from 'cli-ux'
import axios from 'axios'

export default class Users extends Command {
  static flags = {
    ...cli.table.flags()
  }

  async run() {
    const {flags} = this.parse(Users)
    const {data: users} = await axios.get('https://jsonplaceholder.typicode.com/users')

    cli.table(users, {
      name: {
        minWidth: 7,
      },
      company: {
        get: row => row.company && row.company.name
      },
      id: {
        header: 'ID',
        extended: true
      }
    }, {
      printLine: this.log,
      ...flags, // parsed flags
    })
  }
}
```

Displays:

```shell
$ example-cli users
Name                     Company
Leanne Graham            Romaguera-Crona
Ervin Howell             Deckow-Crist
Clementine Bauch         Romaguera-Jacobson
Patricia Lebsack         Robel-Corkery
Chelsey Dietrich         Keebler LLC
Mrs. Dennis Schulist     Considine-Lockman
Kurtis Weissnat          Johns Group
Nicholas Runolfsdottir V Abernathy Group
Glenna Reichert          Yost and Sons
Clementina DuBuque       Hoeger LLC

$ example-cli users --extended
Name                     Company            ID
Leanne Graham            Romaguera-Crona    1
Ervin Howell             Deckow-Crist       2
Clementine Bauch         Romaguera-Jacobson 3
Patricia Lebsack         Robel-Corkery      4
Chelsey Dietrich         Keebler LLC        5
Mrs. Dennis Schulist     Considine-Lockman  6
Kurtis Weissnat          Johns Group        7
Nicholas Runolfsdottir V Abernathy Group    8
Glenna Reichert          Yost and Sons      9
Clementina DuBuque       Hoeger LLC         10

$ example-cli users --columns=name
Name
Leanne Graham
Ervin Howell
Clementine Bauch
Patricia Lebsack
Chelsey Dietrich
Mrs. Dennis Schulist
Kurtis Weissnat
Nicholas Runolfsdottir V
Glenna Reichert
Clementina DuBuque

$ example-cli users --filter="company=Group"
Name                     Company
Kurtis Weissnat          Johns Group
Nicholas Runolfsdottir V Abernathy Group

$ example-cli users --sort=company
Name                     Company
Nicholas Runolfsdottir V Abernathy Group
Mrs. Dennis Schulist     Considine-Lockman
Ervin Howell             Deckow-Crist
Clementina DuBuque       Hoeger LLC
Kurtis Weissnat          Johns Group
Chelsey Dietrich         Keebler LLC
Patricia Lebsack         Robel-Corkery
Leanne Graham            Romaguera-Crona
Clementine Bauch         Romaguera-Jacobson
Glenna Reichert          Yost and Sons
```

# cli.tree

Generate a tree and display it

```typescript
let tree = cli.tree()
tree.insert('foo')
tree.insert('bar')

let subtree = cli.tree()
subtree.insert('qux')
tree.nodes.bar.insert('baz', subtree)

tree.display()
```

Outputs:
```shell
├─ foo
└─ bar
   └─ baz
      └─ qux
```
