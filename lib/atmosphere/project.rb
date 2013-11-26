module Atmosphere
  class Project
    class << self
      def create(name)
        Dir.mkdir(name)
        File.open(File.join(name, "manifest.rb"), "w") do |f|
          f.write "# Your project here"
        end
      end
    end
  end
end
