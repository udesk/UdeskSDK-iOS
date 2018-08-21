#
#  Be sure to run `pod spec lint Test.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = 'UdeskSDK'
  s.version      = '4.0.4'
  s.license      = 'MIT'
  s.summary      = 'Udesk SDK for iOS'
  s.homepage     = 'https://github.com/udesk/UdeskSDK-iOS'
  s.author       = {'xuchen ' => 'xuc@udesk.cn'}
  s.source       =  {:git => 'https://github.com/udesk/UdeskSDK-iOS.git', :tag => s.version.to_s }
  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.subspec 'SDK' do |ss|
    ss.frameworks = 'AVFoundation', 'CoreTelephony', 'SystemConfiguration', 'MobileCoreServices', 'WebKit', 'MapKit','AssetsLibrary','ImageIO','Accelerate','MediaPlayer','Photos','CoreText'
    ss.source_files = 'UdeskSDK/SDK/*.{h}'
    ss.vendored_libraries = 'UdeskSDK/SDK/libUdesk.a'
    ss.libraries    = 'z', 'xml2', 'resolv', 'sqlite3'
    ss.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC',
                       'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2'}
  end
  s.subspec 'UIKit' do |ss|
    ss.source_files = 'UdeskSDK/UDChatMessage/**/*.{h,m}'
    ss.resource     = 'UdeskSDK/UDChatMessage/UDResource/UdeskBundle.bundle'
    ss.dependency 'UdeskSDK/SDK'
  end

end
