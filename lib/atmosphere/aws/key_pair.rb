module Atmosphere
  class Aws
    class KeyPair
      def initialize(region, key_pair)
        @region = region
        @key_pair = key_pair
      end

      def private_key
        @key_pair.private_key
      end
    end
  end
end
