#
#  Be sure to run `pod spec lint Test.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = 'Udesk'
  spec.version      = '1.1.2'
  spec.license      = 'MIT'
  spec.summary      = 'Udesk SDK for iOS'
  spec.homepage     = 'https://github.com/udesk/UdeskSDK-iOS'
  spec.author       = {'xuchen ' => 'xuc@udesk.cn'}
  spec.source       =  {:git => 'https://github.com/udesk/UdeskSDK-iOS.git', :tag => spec.version.to_s }
  spec.source_files = 'UdeskSDK/UDChatMessage/**/*.{h,m}','UdeskSDK/SDK/*.{h}'
  spec.platform     = :ios, '6.0'
  spec.requires_arc = true
  spec.frameworks = 'AVFoundation', 'CoreTelephony', 'SystemConfiguration', 'MobileCoreServices'
  spec.libraries    = 'z', 'xml2', 'resolv', 'sqlite3'
  spec.resource     = 'UdeskSDK/Resource/UdeskBundle.bundle'
  spec.vendored_libraries = 'UdeskSDK/SDK/libUdesk.a'
  spec.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC'}
end
