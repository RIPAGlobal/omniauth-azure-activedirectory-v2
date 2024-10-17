# -*- encoding: utf-8 -*-
# frozen_string_literal: true

$:.push File.expand_path( '../lib', __FILE__ )
require 'omniauth/entra_id/version'

# https://guides.rubygems.org/specification-reference/
#
Gem::Specification.new do |s|
  s.name                  = 'omniauth-entra-id'
  s.version               = OmniAuth::Entra::Id::VERSION
  s.date                  = OmniAuth::Entra::Id::DATE
  s.summary               = 'OAuth 2 authentication with the Entra ID API.'
  s.authors               = [ 'RIPA Global'        ]
  s.email                 = [ 'dev@ripaglobal.com' ]
  s.licenses              = [ 'MIT'               ]
  s.homepage              = 'https://github.com/RIPAGlobal/omniauth-entra-id'

  s.required_ruby_version = Gem::Requirement.new('>= 3.0.0')
  s.require_paths         = ['lib']
  s.bindir                = 'exe'
  s.files                 = %w{
    README.md
    CHANGELOG.md
    CODE_OF_CONDUCT.md
    UPGRADING.md
    LICENSE.txt

    Gemfile
    bin/console
    bin/setup

    lib/omniauth-entra-id.rb
    lib/omniauth/entra_id.rb
    lib/omniauth/entra_id/version.rb
    lib/omniauth/strategies/entra_id.rb

    omniauth-entra-id.gemspec
  }

  s.metadata = {
    'homepage_uri'    => 'https://www.ripaglobal.com/',
    'bug_tracker_uri' => 'https://github.com/RIPAGlobal/omniauth-entra-id/issues/',
    'changelog_uri'   => 'https://github.com/RIPAGlobal/omniauth-entra-id/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/RIPAGlobal/omniauth-entra-id'
  }

  s.add_runtime_dependency('omniauth-oauth2', '~> 1.8')

  s.add_development_dependency('rake',  '~> 13.2 ')
  s.add_development_dependency('rspec', '~>  3.13')
end
