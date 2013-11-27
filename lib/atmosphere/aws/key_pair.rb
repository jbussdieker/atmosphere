module Atmosphere
  class Aws < Hash
    class KeyPair < Hash
      def initialize(region, name)
        @region = region
        self[:name] = name
      end

      def client
        key_pair = @region.client.key_pairs[name]
        filename = "#{ENV["HOME"]}/.ssh/cloud_dsl-#{@region.name}-#{name}.pem"

        if key_pair
          unless File.exists? filename
            logger.warn "Key exists but can't find private key in #{filename}"
          else
            key_pair.instance_eval { @private_key = File.read(filename) }
          end
        else
          key_pair = @region.client.key_pairs.create(name)
          File.open(filename, "w") do |f|
            f.write(key_pair.private_key)
          end
        end
      end

      def private_key
        @key_pair.private_key
      end
    end
  end
end
