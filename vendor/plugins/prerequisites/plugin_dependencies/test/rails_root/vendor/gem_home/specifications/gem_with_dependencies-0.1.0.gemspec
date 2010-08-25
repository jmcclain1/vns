Gem::Specification.new do |s|
  s.name = %q{gem_with_dependencies}
  s.version = "0.1.0"
  s.files = ["init.rb"]
  s.add_dependency(%q<dependent_plugin_gem>, [">= 1.2.0"])
end