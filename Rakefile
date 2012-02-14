# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

App::Application.load_tasks

#gemfile = Pathname.new("Gemfile").expand_path
#lockfile = gemfile.dirname.join('Gemfile.lock')
#definition = Bundler::Definition.build(gemfile, lockfile, nil)
#sc=definition.index.search "spree"
#ENV['SPREE_GEM_PATH'] = sc[0].loaded_from.gsub(/\/[a-z]*.gemspec$/,'')
