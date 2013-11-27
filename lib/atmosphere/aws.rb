require 'aws-sdk'

require 'atmosphere/aws/instance'
require 'atmosphere/aws/key_pair'
require 'atmosphere/aws/region'
require 'atmosphere/aws/security_group'

module Atmosphere
  class Aws < Hash
    attr_accessor :regions

    def initialize(args)
      args.each do |k, v|
        self[k] = v
      end
    end

    def client
      AWS::EC2.new(self)
    end

    def regions
      self[:regions] ||= {}
    end

    def region(name, &block)
      regions[name] ||= Region.new(self, name)
      regions[name].tap do |region|
        region.instance_exec &block if block_given?
      end
    end

    def logger
      Atmosphere.logger
    end
  end
end
