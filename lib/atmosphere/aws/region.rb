module Atmosphere
  class Aws
    class Region
      def initialize(account, region)
        @account = account
        @region = region
      end

      def logger
        Atmosphere.logger
      end

      def security_group(name, &block)
        begin
          sg = @region.security_groups.create(name)
          logger.info "Created security group #{name}"
        rescue AWS::EC2::Errors::InvalidGroup::Duplicate => e
          sg = @region.security_groups.find {|sg| sg.name == name}
          logger.debug "Already exists #{sg.id}"
        end
        SecurityGroup.new(self, sg).tap do |sg|
          sg.instance_exec &block if block_given?
        end
      end

      def key_pair(name)
        filename = "#{ENV["HOME"]}/.ssh/cloud_dsl-#{@region.name}-#{name}.pem"
        begin
          key_pair = @region.key_pairs.create(name)
          File.open(filename, "w") do |f|
            f.write(key_pair.private_key)
          end
        rescue AWS::EC2::Errors::InvalidKeyPair::Duplicate => e
          key_pair = @region.key_pairs[name]
          unless File.exists? filename
            logger.warn "Key exists but can't find private key in #{filename}"
          else
            key_pair.instance_eval { @private_key = File.read(filename) }
          end
        end
        KeyPair.new(self, key_pair)
      end

      def instance(name, args = {}, &block)
        instance = nil
        AWS.memoize do
          @region.instances.each do |check_instance|
            if check_instance.tags["Name"] == name
              if check_instance.status != :terminated && check_instance.status != :shutting_down
                instance = check_instance 
              end
            end
          end
        end
        unless instance
          instance = @region.instances.create(args)
          logger.info "Created instance #{name}"
          logger.info "  Public IP:  #{instance.public_ip_address}"
          logger.info "  Private IP: #{instance.private_ip_address}"
          instance.tags["Name"] = name
        else
          logger.info "Found instance #{name}"
          logger.info "  Public IP:  #{instance.public_ip_address}"
          logger.info "  Private IP: #{instance.private_ip_address}"
        end
        Instance.new(self, instance).tap do |instance|
          instance.instance_exec &block if block_given?
        end
      end
    end
  end
end
