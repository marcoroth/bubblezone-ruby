# frozen_string_literal: true

require_relative "lib/bubblezone/version"

Gem::Specification.new do |spec|
  spec.name = "bubblezone"
  spec.version = Bubblezone::VERSION
  spec.authors = ["Marco Roth"]
  spec.email = ["marco.roth@intergga.ch"]

  spec.summary = "Ruby bindings for bubblezone, helper utility for BubbleTea, allowing easy mouse event tracking."
  spec.description = "Ruby bindings for the bubblezone, providing zone management for terminal applications with mouse support."
  spec.homepage = "https://github.com/marcoroth/bubblezone-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/marcoroth/bubblezone-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/marcoroth/bubblezone-ruby/releases"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "bubblezone.gemspec",
    "LICENSE.txt",
    "README.md",
    "lib/**/*.rb",
    "ext/**/*.{c,h,rb}",
    "go/**/*.{go,mod,sum}",
    "go/build/**/*"
  ]

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.extensions = ["ext/bubblezone/extconf.rb"]

  spec.add_dependency "rake-compiler", "~> 1.2"
end
