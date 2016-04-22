module Slnky
  module Hipchat
    class Mock < Slnky::Hipchat::Client
      # unless there's something special you need to do in the initializer
      # use the one provided by the actual client object
      def initialize

      end

      def logline(log)
        "#{log.level.upcase} #{log.message}"
      end

      def hipchat_send(room, message, options={})
        options = hipchat_options(options)
        user = 'SLNky'
        "#{user}: #{message}"
      end
    end
  end
end
