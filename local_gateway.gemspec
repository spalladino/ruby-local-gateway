Gem::Specification.new do |s|
  s.name = %q{local_gateway}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["InsTEDD"]
  s.date = %q{2011-11-11}
  s.description = %q{A Local Gateway -developed by InSTEDD- implemented in Ruby for testing purposes.}
  s.email = %q{aborenszweig@manas.com.ar}
  s.homepage = %q{https://github.com/spalladino/ruby-local-gateway}
  s.require_paths = ["lib"]
  s.files = [
    "lib/local_gateway.rb",
    "lib/ruby-local-gateway.rb",
  ]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A Local Gateway implemented in Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<qst_client>, [">= 0"])
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
    else
      s.add_dependency(%q<qst_client>, [">= 0"])
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 0"])
    end
  else
    s.add_dependency(%q<qst_client>, [">= 0"])
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 0"])
  end
end

