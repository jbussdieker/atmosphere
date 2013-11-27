require "atmosphere/version"
require "atmosphere/project"
require "atmosphere/dsl"

module Atmosphere
  def self.logger
    Logger.new(STDOUT).tap do |l|
      l.level = Logger::ERROR
    end
  end
end
