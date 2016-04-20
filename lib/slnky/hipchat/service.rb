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
        transport.queue('hipchat', 'logs').subscribe do |raw|
          handle_log(parse(raw))
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
        unless data.chat.format == 'html'
          message = "<b>#{data.chat.message}</b><br/><i>event: #{name}</i>"
          data.chat.format = 'html'
        end
        client.hipchat_send(room, message, notify: data.chat.notify, color: data.chat.color, format: data.chat.format)
      end
    end
  end
end
