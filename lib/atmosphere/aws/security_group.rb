module Atmosphere
  class Aws
    class SecurityGroup
      attr_accessor :name, :region

      def initialize(region, sg)
        @region = region
        @sg = sg
        @name = sg.name
      end

      def client
        @sg
      end

      def logger
        Atmosphere.logger
      end

      def allow_cidr(cidr, protocol, range)
        begin
          client.authorize_ingress(protocol, range, cidr)
        rescue AWS::EC2::Errors::InvalidPermission::Duplicate => e
          logger.debug "Already allowed"
        end
      end

      def allow_group(group, protocol, range)
        begin
          client.authorize_ingress(protocol, range, region.security_group(group).client)
        rescue AWS::EC2::Errors::InvalidPermission::Duplicate => e
          logger.debug "Already allowed"
        end
      end
    end
  end
end
