module Atmosphere
  class Aws < Hash
    class Region < Hash
      attr_accessor :security_groups, :key_pairs, :instances

      def initialize(account, name)
        @account = account
        self[:name] = name
      end

      def logger
        Atmosphere.logger
      end

      def name
        self[:name]
      end

      def instances
        self[:instances] ||= {}
      end

      def key_pairs
        self[:key_pairs] ||= {}
      end

      def security_groups
        self[:security_groups] ||= {}
      end

      def client
        @account.client.regions[name]
      end

      def security_group(name, &block)
        security_groups[name] ||= SecurityGroup.new(self, name)
        security_groups[name].tap do |sg|
          sg.instance_exec &block if block_given?
        end
      end

      def key_pair(name, &block)
        key_pairs[name] ||= KeyPair.new(self, name)
        key_pairs[name].tap do |key_pair|
          key_pair.instance_exec &block if block_given?
        end
      end

      def instance(name, args = {}, &block)
        instances[name] ||= Instance.new(self, name, args)
        instances[name].tap do |instance|
          instance.instance_exec &block if block_given?
        end
      end
    end
  end
end
