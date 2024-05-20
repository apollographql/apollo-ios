Pod::Spec.new do |s|
  version = `scripts/get-version.sh`
  s.name = 'ApolloTestSupport'
  s.version = version
  s.author = 'Apollo GraphQL'
  s.homepage = 'https://github.com/apollographql/apollo-ios'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = "TODO"
  s.source = { :git => 'https://github.com/apollographql/apollo-ios.git', :tag => s.version }
  s.requires_arc = true
  s.swift_version = '5.6'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '5.0'
  s.visionos.deployment_target = '1.0'

  s.source_files = 'Sources/ApolloTestSupport/*.swift'
  s.dependency 'Apollo', '= ' + version

end
