require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "pooled-curb"
    gem.summary = %Q{High-performance HTTP requests for a multi-threaded environment}
    gem.description = %Q{When consuming web services, HTTP performance can be greatly improved if you enable keep-alive 
    and the right HTTP library.\nPooled-curb helps to solve this implementing a pool of Curb (libcurl) objects and providing a 
    pleasent API to do HTTP requests through the pool.}
    gem.email = "angel@vlex.com"
    gem.homepage = "http://github.com/angelf/pooled-curb"
    gem.authors = ["Angel Faus"]
    gem.add_dependency "common-pool", ">= 0"    
    gem.add_dependency "curb", ">= 0"    
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pooled-curb #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
