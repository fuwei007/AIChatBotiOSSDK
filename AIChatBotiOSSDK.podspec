
Pod::Spec.new do |s|
  s.name             = 'AIChatBotiOSSDK'
  s.version          = '1.0.0'
  s.summary          = 'A short description of AIChatBotiOSSDK.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Frank Fu/AIChatBotiOSSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Frank Fu' => 'fuwei007@gmail.com' }
  s.source           = { :git => 'https://github.com/Frank Fu/AIChatBotiOSSDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'AIChatBotiOSSDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AIChatBotiOSSDK' => ['AIChatBotiOSSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
