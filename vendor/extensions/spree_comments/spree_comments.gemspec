Gem::Specification.new do |s|
  s.platform  = Gem::Platform::RUBY
  s.name      = 'spree_comments'
  s.version   = '1.0.0'
  s.summary   = 'Comments for orders and shipments'
  s.homepage  = 'http://www.spreecommerce.com'
  s.author    = 'Rails Dog'
  s.email     = 'gems@railsdog.com'
  s.required_ruby_version = '>= 1.8.7'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]  
  s.has_rdoc      = false

  s.add_dependency('spree_core', '>=0.30.0')
  s.add_dependency('acts_as_commentable', '3.0.0')
end
