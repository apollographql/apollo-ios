Pod::Spec.new do |s|
  s.name = 'Apollo'
  s.version = `scripts/get-version.sh`
  s.author = 'Apollo GraphQL'
  s.homepage = 'https://github.com/apollographql/apollo-ios'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = "A GraphQL client for iOS, written in Swift."
  s.source = { :git => 'https://github.com/apollographql/apollo-ios.git', :tag => s.version }
  s.requires_arc = true
  s.swift_version = '5.6'
  s.default_subspecs = 'Core'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '5.0'

  s.preserve_paths = ['apollo-ios-cli', 'apollo-ios-cli.tar.gz']
  s.prepare_command = <<-CMD
    echo "Running prepare_command"
    sh scripts/download-cli.sh "$PWD"
  CMD

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Apollo/**/*.swift','Sources/ApolloAPI/**/*.swift'
    ss.resource_bundles = {'Apollo' => ['Sources/Apollo/Resources/PrivacyInfo.xcprivacy']}
  end

  # Apollo provides exactly one persistent cache out-of-the-box, as a reasonable default choice for
  # those who require cache persistence. Third-party caches may use different storage mechanisms.
  s.subspec 'SQLite' do |ss|
    ss.source_files = 'Sources/ApolloSQLite/*.swift'
    ss.dependency 'Apollo/Core'
    ss.dependency 'SQLite.swift', '~>0.13.1'
    ss.resource_bundles = {
      'ApolloSQLite' => ['Sources/ApolloSQLite/Resources/PrivacyInfo.xcprivacy']
    }
  end

  # Websocket and subscription support based on Starscream
  s.subspec 'WebSocket' do |ss|
    ss.source_files = 'Sources/ApolloWebSocket/**/*.swift'
    ss.dependency 'Apollo/Core'
    ss.resource_bundles = {
      'ApolloWebSocket' => ['Sources/ApolloWebSocket/Resources/PrivacyInfo.xcprivacy']
    }
  end

end
