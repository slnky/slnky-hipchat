require 'slnky'
require 'hipchat'

module Slnky
  module Service
    class Hipchat < Base
      def initialize(url, options={})
        super(url, options)
        @token = config.hipchat.token
        @rooms = config.hipchat.rooms ? config.hipchat.rooms.split(',') : []
        @levels = config.hipchat.levels ? config.hipchat.levels.split(',').map(&:to_sym) : [:warn, :error]
        @hipchat = HipChat::Client.new(@token)
      end

      subscribe 'slnky.service.test', :handler
      # you can also subscribe to heirarchies, this gets
      # all events under something.happened
      # subscribe 'something.happened.*', :other_handler

      def run
        @channel.queue("service.hipchat.logs", durable: true).bind(@exchanges['logs']).subscribe do |raw|
          payload = parse(raw)
          logline(payload)
        end
      end

      def logline(log)
        level = log.level.to_sym
        color = case level
                  when :warn
                    'yellow'
                  when :error
                    'red'
                  else
                    'green'
                end
        return unless @levels.include?(level)
        message = "#{log.message} [from #{log.ipaddress}/#{log.service}]"
        @rooms.each do |room|
          if development?
            puts "hipchat[#{color}]: #{message}"
          else
            @hipchat[room].send('slnky', message, notify: true)
          end
        end

        true
      end

      def handler(name, data)
        name == 'slnky.service.test' && data.hello == 'world!'
      end
    end
  end
end
