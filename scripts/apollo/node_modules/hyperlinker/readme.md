# hyperlinker [![Build Status](https://travis-ci.org/jamestalmage/hyperlinker.svg?branch=master)](https://travis-ci.org/jamestalmage/hyperlinker) [![codecov](https://codecov.io/gh/jamestalmage/hyperlinker/badge.svg?branch=master)](https://codecov.io/gh/jamestalmage/hyperlinker?branch=master)

> Write hyperlinks in the terminal.

Terminal emulators are [starting to support hyperlinks](https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda). While many terminals have long detected URL's and linkified them, allowing you to Command-Click or Control-Click them to open a browser, you were forced to print the long unsightly URL's on the screen. As of spring 2017 [a few terminals](https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda) began supporting HTML like links, where the link text and destination could be specified separately.

This module will create hyperlinks when printed to a supported terminal.

## Install

```
$ npm install hyperlinker
```


## Usage

```js
const hyperlinker = require('hyperlinker');

console.log(hyperlinker('some text', 'https://example.com') + '   <--- command + click here!');
// some text    <-- command + click here!

```

Note that this module does not check to see if hyperlinks are supported in the current Terminal. In unsupported terminals, users will likely only see the `text` command. You should use module [`supports-hyperlinks`](https://github.com/jamestalmage/supports-hyperlinks) if you want to provide an alternate presentation based on Terminal support.

```js
const supportsHyperlinks = require('supports-hyperlinks');
const hyperlinker = require('hyperlinker');

if (supportsHyperlinks.stdout) {
    console.log(hyperlinker('click here', 'https://example.com'));
} else {
    console.log('Copy and paste the following in your browser: \n\t https://example.com');
}
```

## API

### hyperlinker(text, uri, [params])

#### text

Type: `string`

The text that will be visible in the link. This is equivalent to the text between the opening `<a>` and closing `</a>` tags in HTML.

#### uri

Type: `string`

A URI (i.e `https://example.com`) where the link will point to. This is equivalent to the context of the `href` attribute in an HTML `<a>` tag.

#### params

Type: `Object`<br>
*Optional*

A collection of key value pairs, that will be printed as hidden `params`. There's not a lot of use for these right now, except for maybe [an id param](https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda#hover-underlining-and-the-id-parameter). It is intended to allow extension of the spec in the future.


## License

MIT © [James Talmage](https://github.com/jamestalmage)
