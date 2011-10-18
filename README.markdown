# Introduction

This is a swiss army knife version of a command line tool.  It will
handle all the normal option and setup processing for you.  In order
to generate a new command-line tool using omnitool all you need to
do is to create a new cmds file and symlink the omnitool.rb skeleton
to a new named tool.  For example:

    create foo.cmd
    ln -s omnitool.rb foo

## Command file syntax

In the command file you have three stanzas with a mini-dsl.
You can define an options stanza, which sets up command
line options as appropriate.  These look like:

### Options

    option :s, :switch => true, :description => "a simple switch"

    option :m, :medium

    option :l, :long, :description => "a long switch with a block" do
         "blah blah"
    end

The non-block form is used if you want to just set an option
as a switch or a value passed on the command line.  Use the
block form if you want to do some special processing yourself
for that particular option.  These options are passed
to the constructor on the omnitool object when created.

### Setup block

You also have a setup stanza which inserts setup information into
the constructor in case you need to initialize something.  It
looks like this:

    setup do
      puts "in the initialize method"
      @blah = "la dee da"
    end

### Commands

Finally, you have the commands which are of the format:

    command :foo, "help text for the foo command" do
      puts "in the foo method"
    end

### Misc wrapup

Check out the sample files for jira and ot_cmds.

You get the "help" command for free, which will show
a list of all commands.  Just do a "ot_test help" to
see what is going on there.  You also get the -h
option for free, which will display a list of all
defined command line switches.

It's not perfect, but it saves me time.

<gary.foster@gmail.com>
