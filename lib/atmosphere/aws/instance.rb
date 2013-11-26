require 'net/ssh'
require 'net/scp'

module Atmosphere
  class Aws
    class Instance
      def initialize(region, instance)
        @region = region
        @instance = instance
      end

      def logger
        Atmosphere.logger
      end

      def ready?
        @instance.status == :running
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
        key_pair = @region.key_pair(@instance.key_name)
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
