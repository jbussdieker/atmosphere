require 'net/ssh'
require 'net/scp'

module Atmosphere
  class Aws < Hash
    class Instance < Hash
      def initialize(region, name, options = {})
        @region = region
        self[:name] = name
        options.each do |k, v|
          self[k] = v
        end
      end

      def logger
        Atmosphere.logger
      end

      def client
        instance = nil
        AWS.memoize do
          @region.client.instances.each do |check_instance|
            if check_instance.tags["Name"] == name
              if check_instance.status != :terminated && check_instance.status != :shutting_down
                instance = check_instance 
              end
            end
          end
        end
        unless instance
          instance = @region.client.instances.create(args)
          logger.info "Created instance #{name}"
          logger.info "  Public IP:  #{instance.public_ip_address}"
          logger.info "  Private IP: #{instance.private_ip_address}"
          instance.tags["Name"] = name
        else
          logger.info "Found instance #{name}"
          logger.info "  Public IP:  #{instance.public_ip_address}"
          logger.info "  Private IP: #{instance.private_ip_address}"
        end
        instance
      end

      def ready?
        client.status == :running
      end

      def wait_ready
        while !ready?
          logger.debug "Instance not ready..."
          sleep 5
        end
      end

      def upload(src, dest)
        wait_ready
        logger.info "#{@instance.tags["Name"]}: Uploading #{src} => #{dest}"
        Net::SCP.upload!(@instance.public_ip_address, 'ubuntu', src, dest, :ssh => ssh_options)
      end

      def run(command)
        wait_ready
        logger.info "#{@instance.tags["Name"]}: Running #{command}"
        Net::SSH.start(@instance.public_ip_address, 'ubuntu', ssh_options) do |session|
          session.open_channel do |ch|
            ch.exec command do |ch, success|
              ch.on_data do |ch, data|
                logger.debug data.strip
              end
            end
          end
        end
      end

      private

      def ssh_options
        key_pair = @region.key_pair(client.key_name)
        {
          :host_key => "ssh-rsa",
          :encryption => "blowfish-cbc",
          :key_data => key_pair.private_key,
          :compression => "zlib",
          :paranoid => false
        }
      end
    end
  end
end
