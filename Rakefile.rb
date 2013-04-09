require "rake/common"
require "rake/src"
require "rake/osx"
require "rake/win"

task :default => ["src:dist"]
