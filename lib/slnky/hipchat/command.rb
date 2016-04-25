module Slnky
  module Hipchat
    class Command < Slnky::Command::Base
      attr_writer :client
      def client
        @client ||= Slnky::Hipchat::Client.new
      end

      command :logging, 'manage hipchat log watching', <<-USAGE.strip_heredoc
        Usage: logging [options] [ON_OFF]

        ON_OFF should be true or false, if absent, just reports current setting
        -h --help           print help.
      USAGE
      def handle_logging(request, response, opts)
        value = opts.on_off
        if value.nil?
          log.info "logging is currently: #{client.logging}"
        elsif value == 'true'
          client.logging = true
          log.info "logging is set: #{client.logging}"
        elsif value == 'false'
          client.logging = false
          log.info "logging is set: #{client.logging}"
        end
      end

      # # use docopt to define arguments and options
      # command :echo, 'respond with the given arguments', <<-USAGE.strip_heredoc
      #   Usage: echo [options] ARGS...
      #
      #   -h --help           print help.
      #   -x --times=TIMES    print x times [default: 1].
      # USAGE
      #
      # # handler methods receive request, response, and options objects
      # def handle_echo(request, response, opts)
      #   # parameters (non-option arguments) are available as accessors
      #   args = opts.args
      #   # as are the options themselves (by their 'long' name)
      #   1.upto(opts.times.to_i) do |i|
      #     # just use the log object to respond, it will automatically send it
      #     # to the correct channel.
      #     log.info args.join(" ")
      #   end
      # end
    end
  end
end
