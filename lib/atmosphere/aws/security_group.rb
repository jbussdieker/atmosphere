module Atmosphere
  class Aws < Hash
    class SecurityGroup < Hash
      attr_accessor :region

      def initialize(region, name)
        @region = region
        self[:name] = name
      end

      def name
        self[:name]
      end

      def logger
        Atmosphere.logger
      end

      def client
        sg = @region.client.security_groups.find {|sg| sg.name == name}
        if sg
          logger.debug "Already exists #{sg.id}"
        else
          logger.info "Created security group #{name}"
          sg = @region.client.security_groups.create(name)
        end
        sg
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
