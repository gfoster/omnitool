

setup do
    require 'rubygems'
    require 'amqp'
end


# and here's our commands.  They will automagically show up in any help listings
# as well
command :count, "show the number of messages in a named queue" do
    unless queue_name = @options[:queue]
        raise "must specify a queue name"
    end

    host = @options[:host] || 'localhost'
    port = @options[:port] || 5672
    username = @options[:username] || 'guest'
    password = @options[:password] || 'guest'
    server = "amqp://#{username}:#{password}@#{host}:#{port}"

    AMQP.start(server) do |connection, open_ok|

        AMQP::Channel.new(connection) do |channel|

            channel.on_error do |ch, channel_close|
                raise "Channel-level exception: #{channel_close.reply_text}"
            end

            queue = channel.queue(queue_name, :nowait => true, :durable => true)

            queue.status do |messages, consumers|
                puts "messages:  #{messages}"
                puts "consumers: #{consumers}"
            end

            connection.close { EventMachine.stop }
        end
    end
end

command :delete, "delete a named queue" do
    unless queue_name = @options[:queue]
        raise "must specify a queue name"
    end

    host = @options[:host] || 'localhost'
    port = @options[:port] || 5672
    username = @options[:username] || 'guest'
    password = @options[:password] || 'guest'
    server = "amqp://#{username}:#{password}@#{host}:#{port}"

    AMQP.start(server) do |connection, open_ok|
        AMQP::Channel.new(connection) do |channel|

            channel.on_error do |ch, channel_close|
                raise "Channel-level exception: #{channel_close.reply_text}"
            end

            queue = channel.queue(queue_name, :nowait => true, :durable => true)

            queue.delete
            puts "deleted queue #{queue_name}"

            connection.close { EventMachine.stop }
        end
    end
end

#option :s, :switch => true, :description => "a simple switch"

option :q, :queue, :description => "name of queue"
option :P, :port, :description => "amqp listening port"
option :u, :username
option :p, :password
option :H, :host


