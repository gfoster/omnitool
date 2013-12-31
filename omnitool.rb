#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'

# Copyright(c) 2011, Gary D. Foster <gary.foster@gmail.com>
# This code is released under the MIT license.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

$extra_options = []

class Tool
    @@help_text = {}
    @@setupHook = []

    private

    Kernel.send :define_method, :option do |*args, &block|
        short = args[0].to_s
        if args.last.kind_of? Hash
            hints = args.last
        else
            hints = { :description => "" }
        end

        if args[1].kind_of? Hash
            long = ""
        else
            long = args[1].to_s
        end

        $extra_options << [short, long, block, hints]
    end

    Kernel.send :define_method, :setup do |&block|
        @@setupHook << block
    end

    protected

    Kernel.send :define_method, :command do |command, help_text, &block|
        @@help_text[command.to_s] = help_text
        Tool.send :define_method, command, &block
    end

    public

    def initialize(options=nil)
        @options = options
        @@setupHook.each { |step| self.instance_eval(&step) }
        return self
    end

    # default commands - always have a help command

    command :help, "Print this list" do
        cmd_list = self.protected_methods.sort
        puts "list of supported commands: "
        help_output = cmd_list.collect do |cmd|
            cmd + (@@help_text.include?(cmd) ? "\t\t" + @@help_text[cmd] : "")
        end
        puts help_output.join("\n")
    end

    # load our chameleon command file based upon our own name

    cmd_file = "#{ENV['HOME']}/.ot_cmds/" << File.basename($0) << ".cmd"

    if FileTest.exists?(cmd_file)
        load cmd_file
    else
        puts "Could not find a command file for myself in #{cmd_file}"
        exit 1
    end
end

def main()
    options = {}

    optparse = OptionParser.new do |opts|
        opts.banner = "Usage foo [options] ..."

        $extra_options.each do |short, long, block, hints|
            # name each option after the long name, falling back to the short name if not given
            if long.empty?
                key = short.to_sym
                long_switch = nil
            else
                key = long.to_sym
                long_switch = "--#{long} #{long.to_s.upcase}"
            end

            description = hints[:description]

            if hints.include?(:switch) and hints[:switch]
                opts.on("-#{short}", long_switch, description) do
                    options[key] = true
                end
            else
                opts.on("-#{short}", long_switch, description) do |param|
                    if block.nil?
                        options[key] = param
                    else
                        options[key] = block.call
                    end
                end
            end
        end

        # and we always have a default -h switch

        opts.on('-h', '--help', 'Display this screen') do
            puts opts
            exit
        end
    end

    optparse.parse!

    command = ARGV[0] || "help"
    subcommand = ARGV[1..-1]

    tool = Tool.new(options)

    if tool.respond_to?(command)
        tool.send(command, subcommand)
    else
        puts "Unknown command: #{ARGV[0]}, try 'help'"
        exit 1
    end
end

if $0 == __FILE__
    main
end
