require 'hipchat'

module Slnky
  module Hipchat
    class Client < Slnky::Client::Base
      def initialize
        @token = config.hipchat.token
        @rooms = config.hipchat.rooms ? config.hipchat.rooms.split(',') : []
        @levels = config.hipchat.levels ? config.hipchat.levels.split(',').map(&:to_sym) : [:warn, :error]
        @hipchat = HipChat::Client.new(@token)
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
        message = "<b>#{message}</b><br/><i>#{log.service}</i>"
        @rooms.each do |room|
          hipchat_send(room, message, notify: true, color: color, format: 'html')
        end

        true
      end

      def hipchat_send(room, message, options={})
        o = hipchat_options(options)
        user = 'SLNky'
        unless room
          @rooms.each do |r|
            hipchat_send(r, message, options)
          end
          return
        end

        if config.development?
          puts "(#{o[:color]}) #{user}@#{room}: #{message}"
        else
          @hipchat[room].send(user, message, notify: o[:notify], color: o[:color], message_format: o[:format])
        end
      rescue => e
        log.error "hipchat service: #{e.message}"
      end

      def hipchat_options(options={})
        {
            color: 'yellow',
            notify: true,
            format: 'text',
        }.merge(options.delete_if{|k, v| v.nil?})
      end
    end
  end
end
