"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const errors_1 = require("@oclif/errors");
const chalk_1 = require("chalk");
const indent = require("indent-string");
const stripAnsi = require("strip-ansi");
const command_1 = require("./command");
const list_1 = require("./list");
const root_1 = require("./root");
const screen_1 = require("./screen");
const util_1 = require("./util");
const wrap = require('wrap-ansi');
const { bold, } = chalk_1.default;
class Help {
    constructor(config, opts = {}) {
        this.config = config;
        this.opts = Object.assign({ maxWidth: screen_1.stdtermwidth }, opts);
        this.render = util_1.template(this);
    }
    showHelp(argv) {
        const getHelpSubject = () => {
            // special case
            // if (['help:help', 'help:--help', '--help:help'].includes(argv.slice(0, 2).join(':'))) {
            // if (argv[0] === 'help') return 'help'
            for (let arg of argv) {
                if (arg === '--')
                    return;
                if (arg.startsWith('-'))
                    continue;
                if (arg === 'help')
                    continue;
                return arg;
            }
        };
        let topics = this.config.topics;
        topics = topics.filter(t => this.opts.all || !t.hidden);
        topics = util_1.sortBy(topics, t => t.name);
        topics = util_1.uniqBy(topics, t => t.name);
        let subject = getHelpSubject();
        let command;
        let topic;
        if (!subject) {
            console.log(this.root());
            console.log();
            if (!this.opts.all) {
                topics = topics.filter(t => !t.name.includes(':'));
            }
            console.log(this.topics(topics));
            console.log();
        }
        else if (command = this.config.findCommand(subject)) {
            this.showCommandHelp(command, topics);
        }
        else if (topic = this.config.findTopic(subject)) {
            const name = topic.name;
            const depth = name.split(':').length;
            topics = topics.filter(t => t.name.startsWith(name + ':') && t.name.split(':').length === depth + 1);
            console.log(this.topic(topic));
            if (topics.length) {
                console.log(this.topics(topics));
                console.log();
            }
        }
        else {
            errors_1.error(`command ${subject} not found`);
        }
    }
    showCommandHelp(command, topics) {
        const name = command.id;
        const depth = name.split(':').length;
        topics = topics.filter(t => t.name.startsWith(name + ':') && t.name.split(':').length === depth + 1);
        let title = command.description && this.render(command.description).split('\n')[0];
        if (title)
            console.log(title + '\n');
        console.log(this.command(command));
        console.log();
        if (topics.length) {
            console.log(this.topics(topics));
            console.log();
        }
    }
    root() {
        const help = new root_1.default(this.config, this.opts);
        return help.root();
    }
    topic(topic) {
        let description = this.render(topic.description || '');
        let title = description.split('\n')[0];
        description = description.split('\n').slice(1).join('\n');
        let output = util_1.compact([
            title,
            [
                bold('USAGE'),
                indent(wrap(`$ ${this.config.bin} ${topic.name}:COMMAND`, this.opts.maxWidth - 2, { trim: false, hard: true }), 2),
            ].join('\n'),
            description && ([
                bold('DESCRIPTION'),
                indent(wrap(description, this.opts.maxWidth - 2, { trim: false, hard: true }), 2)
            ].join('\n'))
        ]).join('\n\n');
        if (this.opts.stripAnsi)
            output = stripAnsi(output);
        return output + '\n';
    }
    command(command) {
        const help = new command_1.default(command, this.config, this.opts);
        return help.generate();
    }
    topics(topics) {
        if (!topics.length)
            return;
        let body = list_1.renderList(topics.map(c => [
            c.name,
            c.description && this.render(c.description.split('\n')[0])
        ]), {
            spacer: '\n',
            stripAnsi: this.opts.stripAnsi,
            maxWidth: this.opts.maxWidth - 2,
        });
        return [
            bold('COMMANDS'),
            indent(body, 2),
        ].join('\n');
    }
}
exports.default = Help;
// function id(c: Config.Command | Config.Topic): string {
//   return (c as any).id || (c as any).name
// }
