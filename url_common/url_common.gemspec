require_relative 'lib/url_common/version'

Gem::Specification.new do |spec|
  spec.name          = "url_common"
  spec.version       = UrlCommon::VERSION
  spec.authors       = ["Scott Johnson"]
  spec.email         = ["fuzzygroup@gmail.com"]

  spec.summary       = %q{This is a class library designed for common url manipulation and crawling tasks.}
  spec.description   = %q{This is a class library for common url manipulation and crawling tasks.  It is based on a career focused on the practical side of working with the Internet using Ruby.}
  spec.homepage      = "https://github.com/fuzzygroup/url_common/"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/fuzzygroup/url_common/"
  spec.metadata["changelog_uri"] = "https://github.com/fuzzygroup/url_common/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_dependency 'fuzzyurl', '~> 0.9.0'
  spec.add_dependency 'mechanize', '~> 2.6'
  
end
