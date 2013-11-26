require "atmosphere/version"
require "atmosphere/dsl"

module Atmosphere
  def self.logger
    Logger.new(STDOUT).tap do |l|
      l.level = Logger::DEBUG
    end
  end
end
