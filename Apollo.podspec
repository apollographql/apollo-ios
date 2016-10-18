Pod::Spec.new do |s|
  s.name         = 'Apollo'
  s.version      = `scripts/get-version.sh`
  s.author       = 'Meteor Development Group'
  s.homepage     = 'https://github.com/apollostack/apollo-ios'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.summary      = "A GraphQL client for iOS, written in Swift."

  s.source       = { :git => 'https://github.com/apollostack/apollo-ios.git', :tag =>  "v#{s.version}" }

  s.requires_arc = true
  s.platform     = :ios

  s.ios.deployment_target = '8.0'

  s.source_files = 'Sources/**/*.swift'
  s.resource = 'scripts/check-and-run-apollo-codegen.sh'
end
