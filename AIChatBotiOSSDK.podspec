
Pod::Spec.new do |s|
  s.name             = 'AIChatBotiOSSDK'
  s.version          = '1.0.21'
  s.summary          = 'AIChatBotiOSSDK is a chatbot SDK for iOS applications, providing AI-driven conversation capabilities.'

  s.description = <<-DESC
            iOSAIChatBotSDK is an AI-powered chatbot SDK designed for iOS applications.
            It enables developers to integrate conversational AI features seamlessly into
            their apps, offering intelligent responses and interactions. This SDK is easy
            to integrate, supports customizable UI, and provides a robust API for developers.
         DESC

  s.homepage         = 'https://github.com/fuwei007/AIChatBotiOSSDK.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Frank Fu' => 'fuwei007@gmail.com' }
  s.source           = { :git => 'https://github.com/fuwei007/AIChatBotiOSSDK.git', :tag => s.version.to_s }


  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.0']

  s.source_files = 'AIChatBotiOSSDK/Classes/**/*'
  #If image is .xcassets, you can use this:
  #s.resource_bundles = {
  #  'AIChatBotiOSSDKResources' => ['AIChatBotiOSSDK/Assets/**/*']
  #}
  s.resources = 'AIChatBotiOSSDK/Assets/**/*'

  # Declare mandatory third-party library dependencies
  s.dependency 'Starscream', '~> 4.0.8'
  s.dependency 'IQKeyboardManagerSwift', '~> 8.0.0'
  s.dependency 'GoogleWebRTC', '~> 1.1.32000'
  
  #WebRTC can only run on the simulator using the x86_64 architecture. The following method can enforce Xcode to compile using x86_64 only.
  #Code + pod lib lint --skip-import-validation --allow-warnings
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  s.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
end
