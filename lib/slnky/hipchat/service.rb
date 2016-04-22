module Slnky
  module Hipchat
    class Service < Slnky::Service::Base
      attr_writer :client
      def client
        @client ||= Slnky::Hipchat::Client.new
      end

      subscribe '*', :handle_event
      subscribe 'slnky.service.test', :handle_test
      # you can also subscribe to heirarchies, this gets
      # all events under something.happened
      # subscribe 'something.happened.*', :other_handler

      def run
        logs = transport.queue('hipchat', 'logs')
        logs.subscribe do |raw|
          handle_log(parse(raw))
        end
        response = transport.queue('hipchat', 'response', durable: false, auto_delete: true, routing_key: 'hipchat')
        response.subscribe do |raw|
          handle_response(parse(raw))
        end
      end

      def handle_test(name, data)
        name == 'slnky.service.test' && data.hello == 'world!'
      end

      def handle_log(message)
        client.logline(message)
      end

      def handle_event(name, data)
        return nil unless data.chat && data.chat.message
        room = data.chat.room
        message = data.chat.message
        # unless data.chat.format == 'html'
        #   message = "<b>#{data.chat.message}</b><br/><i>event: #{name}</i>"
        #   data.chat.format = 'html'
        # end
        client.hipchat_send(room, message, notify: data.chat.notify, color: data.chat.color, format: data.chat.format)
      end

      def handle_response(message)
        (user, room) = message.reply.split(':', 2)
        return if %w{start complete}.include?(message.level)
        color = case message.level
                  when 'info'
                    'green'
                  when 'warn'
                    'yellow'
                  when 'error'
                    'red'
                end
        client.hipchat_send(room, message.message, notify: true, color: color, format: 'text')
      end
    end
  end
end
