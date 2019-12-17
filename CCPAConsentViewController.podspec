Pod::Spec.new do |s|
  s.name             = 'CCPAConsentViewController'
  s.version          = '3.1.0'
  s.summary          = 'SourcePoint\'s CCPAConsentViewController to handle privacy consents.'
  s.homepage         = 'https://www.sourcepoint.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SourcePoint' => 'contact@sourcepoint.com' }
  s.source           = { :git => 'https://github.com/SourcePointUSA/ios-cmp-app.git', :tag => s.version.to_s }
  s.swift_version    = '4.2'
  s.ios.deployment_target = '9.0'
  s.source_files = 'CCPAConsentViewController/Classes/**/*'
  s.resource_bundles = { 'CCPAConsentViewController' => ['CCPAConsentViewController/Assets/**/*'] }
  s.resources = "CCPAConsentViewController/**/*{.js}"

end
