require 'aws-sdk'

require 'atmosphere/aws/instance'
require 'atmosphere/aws/key_pair'
require 'atmosphere/aws/region'
require 'atmosphere/aws/security_group'

module Atmosphere
  class Aws
    def initialize(args)
      @args = args
    end

    def client
      AWS::EC2.new(@args)
    end

    def region(name, &block)
      Region.new(self, client.regions[name]).instance_exec &block
    end

    def logger
      Atmosphere.logger
    end
  end
end
