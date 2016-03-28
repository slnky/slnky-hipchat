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

      # subscribe 'slnky.service.test', :handler
      # you can also subscribe to heirarchies, this gets
      # all events under something.happened
      # subscribe 'something.happened.*', :other_handler

      subscribe '*', :handle_event

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
        return true unless @levels.include?(level)
        (service, message) = log.message.split(': ', 2)
        user = "SLNky"
        message = "<b>#{message}</b><br/>(#{log.ipaddress}/#{log.service})"
        @rooms.each do |room|
          if development?
            puts "(#{color}) #{user}: #{message}"
          else
            @hipchat[room].send(user, message, notify: true, color: color)
          end
        end

        true
      end

      def handler(name, data)
        name == 'slnky.service.test' && data.hello == 'world!'
      end

      def handle_event(name, data)
        if data.chat && data.chat.room && @rooms.include?(data.chat.room)
          room = data.chat.room
          color = data.chat.color || 'yellow'
          notify = data.chat.notify == true
          message = data.chat.message || "#{name} has no message"
          format = data.chat.format || 'text'
          # send data to room
          @hipchat[room].send('SLNky', message, notify: notify, color: color, message_format: format) unless development?
        else
          log :info, "event #{name} no chat attributes? #{data.chat.inspect}"
        end
        true
      end
    end
  end
end
