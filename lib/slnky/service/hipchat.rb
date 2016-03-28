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
        message = "<b>#{message}</b><br/><i>#{log.ipaddress}/#{log.service}</i>"
        @rooms.each do |room|
          hipchat_send(room, message, notify: true, color: color, format: 'html')
        end

        true
      end

      def handler(name, data)
        name == 'slnky.service.test' && data.hello == 'world!'
      end

      def handle_event(name, data)
        if data.chat && data.chat.message
          room = data.chat.room
          message = "<b>#{data.chat.message}</b><br/><i>event: #{name}</i>"
          hipchat_send(room, message, notify: data.chat.notify, color: data.chat.color, format: data.chat.format)
        end
        true
      end

      def hipchat_send(room, message, options={})
        o = {
            color: 'yellow',
            notify: true,
            format: 'text',
        }.merge(options)

        user = 'SLNky'

        if development?
          puts "(#{o[:color]}) #{user}: #{message}"
        else
          @hipchat[room].send(user, message, notify: o[:notify], color: o[:color], message_format: o[:format])
        end
      rescue => e
        log :error, "hipchat service: #{e.message}"
      end
    end
  end
end
