Pod::Spec.new do |s|
  s.name         = 'Apollo'
  s.version      = '0.1.0'
  s.author       = 'Meteor Development Group'
  s.homepage     = 'https://github.com/apollostack/apollo-ios'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.summary      = "A GraphQL client for iOS, written in Swift."

  s.source       = { :git => 'https://github.com/apollostack/apollo-ios.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.platform     = :ios

  s.ios.deployment_target = '8.0'

  s.source_files = 'Apollo/**/*.swift'
end
