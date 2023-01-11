# -*- encoding: utf-8 -*-
# frozen_string_literal: true
# stub: omniauth-azure-activedirectory-v2 1.0.0 ruby lib

$:.push File.expand_path( '../lib', __FILE__ )
require 'omniauth/azure_activedirectory_v2/version'

# https://guides.rubygems.org/specification-reference/
#
Gem::Specification.new do |s|
  s.name                  = 'omniauth-azure-activedirectory-v2'
  s.version               = OmniAuth::Azure::Activedirectory::V2::VERSION
  s.date                  = OmniAuth::Azure::Activedirectory::V2::DATE
  s.summary               = 'OAuth 2 authentication with the Azure ActiveDirectory V2 API.'
  s.authors               = [ 'RIPA Global'        ]
  s.email                 = [ 'dev@ripaglobal.com' ]
  s.licenses              = [ 'MIT'               ]
  s.homepage              = 'https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2'

  s.required_ruby_version = Gem::Requirement.new('>= 2.3.0')
  s.require_paths         = ['lib']
  s.bindir                = 'exe'
  s.files                 = %w{
    README.md
    CHANGELOG.md
    CODE_OF_CONDUCT.md
    LICENSE.txt

    Gemfile
    bin/console
    bin/setup

    lib/omniauth-azure-activedirectory-v2.rb
    lib/omniauth/azure_activedirectory_v2.rb
    lib/omniauth/azure_activedirectory_v2/version.rb
    lib/omniauth/strategies/azure_activedirectory_v2.rb

    omniauth-azure-activedirectory-v2.gemspec
  }

  s.metadata = {
    'homepage_uri'    => 'https://www.ripaglobal.com/',
    'bug_tracker_uri' => 'https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/issues/',
    'changelog_uri'   => 'https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/RIPAGlobal/omniauth-azure-activedirectory-v2'
  }

  s.add_runtime_dependency('omniauth-oauth2', '~> 1.8')
end
