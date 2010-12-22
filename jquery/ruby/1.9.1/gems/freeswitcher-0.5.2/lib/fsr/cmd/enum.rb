require "fsr/app"
module FSR
  module Cmd
    class Enum < Command
      attr_reader :ph_nbr

      def initialize(fs_socket = nil, phone_number = nil)
        @fs_socket = fs_socket # FSR::CommandSocket obj
        @ph_nbr = phone_number # phone number to look up, up to 15 digits
      end

      # Send the command to the event socket, using api by default.
      def run(api_method = :api)
        orig_command = "%s %s" % [api_method, raw]
        Log.debug "saying #{orig_command}"
        resp = @fs_socket.say(orig_command)
        parse(resp)
      end

      # This method builds the API command to send to the freeswitch event socket
      def raw
        orig_command = "enum #{ph_nbr}"
      end

      def parse(response)
        body = response["body"]
        offered_routes,supported_routes = body.match(/Offered\ Routes:(.*?)Supported\ Routes:(.*?)/mx)[1 .. 2]
        order, pref, service, route = offered_routes.match(/==+\n(.*)/m)[1].split
        unless body == "No Match!"
          require "fsr/model/enum"
          return FSR::Model::Enum.new(offered_routes, supported_routes, order, pref, service, route)
        end
        nil
      end

    end

    register(:enum, Enum)
  end
end
