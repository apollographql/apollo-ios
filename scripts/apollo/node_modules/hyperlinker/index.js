'use strict';

/*
A hyperlink is opened upon encountering an OSC 8 escape sequence with the target URI. The syntax is

OSC 8 ; params ; URI BEL|ST

Following this, all subsequent cells that are painted are hyperlinks to this target. A hyperlink is closed with the same escape sequence, omitting the parameters and the URI but keeping the separators:

OSC 8 ; ; BEL|ST

const ST = '\u001B\\';
 */
const OSC = '\u001B]';
const BEL = '\u0007';
const SEP = ';';

const PARAM_SEP = ':';
const EQ = '=';

module.exports = (text, uri, params) => {
	params = params || {};

	return [
		OSC,
		'8',
		SEP,
		Object.keys(params).map(key => key + EQ + params[key]).join(PARAM_SEP),
		SEP,
		uri,
		BEL,
		text,
		OSC,
		'8',
		SEP,
		SEP,
		BEL
	].join('');
};
