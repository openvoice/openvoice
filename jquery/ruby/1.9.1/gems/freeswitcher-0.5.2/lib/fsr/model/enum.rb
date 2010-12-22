module FSR
  module Model
    class Enum 
      attr_reader :offered_routes, :supported_routes, :order, :pref, :service, :route
      def initialize(offered_routes,
                     supported_routes,
                     order,
                     pref,
                     service,
                     route)
        @offered_routes,
        @supported_routes,
        @order,
        @pref,
        @service,
        @route,
        = offered_routes, 
                     supported_routes,
                     order,
                     pref,
                     service,
                     route
      end
    end
  end
end
