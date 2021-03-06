require 'hipchat'

module Slnky
  module Hipchat
    class Client < Slnky::Client::Base
      attr_accessor :logging
      def initialize
        @token = config.hipchat.token
        @rooms = config.hipchat.rooms ? config.hipchat.rooms.split(',') : []
        @levels = config.hipchat.levels ? config.hipchat.levels.split(',').map(&:to_sym) : [:warn, :error]
        @logging = true
        @hipchat = HipChat::Client.new(@token)
        @hipchat_rooms = @hipchat.rooms.inject({}) do |h, r|
          k = r.name.downcase.gsub(/\s+/, '_')
          h[k] = r.room_id
          h
        end
      end

      def logline(log)
        return unless @logging
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
        message = "<b>#{log.message}</b><br/><i>#{log.service}</i>"
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
        room = @hipchat_rooms[room] if @hipchat_rooms[room]
        if config.development?
          puts "(#{o[:color]}) #{user}@#{room}: #{message}"
        else
          @hipchat[room].send(user, message, notify: o[:notify], color: o[:color], message_format: o[:format])
        end
      rescue => e
        log.error "hipchat service: #{e.message}"
        log.debug "#{e.message}\n#{e.backtrace.first(5).join("\n")}"
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
