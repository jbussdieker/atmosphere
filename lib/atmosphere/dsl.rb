require 'atmosphere/aws'

module Atmosphere
  class DSL < Hash
    def providers
      self[:providers] ||= {}
    end

    def aws(*args, &block)
      providers[:aws] ||= Aws.new(*args)
      providers[:aws].tap do |aws|
        aws.instance_exec(&block) if block_given?
      end
    end
  end
end
