Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_faq'
  s.version     = '3.0.2'
  s.summary     = 'Adds an easy faq page to your spree site'
  s.description = 'With this gem you get an faq page and the management tools to make it very easy to update your faq and reduce the demand on your sites customer service'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Josh Nussbaum'
  s.email             = 'joshnuss@gmail.com'
  s.homepage          = 'http://spreecommerce.com'
  s.rubyforge_project = 'spree_faq'

  s.files        = Dir['README.md.md', 'lib/**/*', 'app/**/*', 'config/*', 'db/*']
  s.require_path = 'lib'
  s.requirements << 'none'


  s.add_dependency('spree_core',  '>= 0.30.1')
end

