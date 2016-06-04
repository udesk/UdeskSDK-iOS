#
#  Be sure to run `pod spec lint Test.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = 'Udesk'
  spec.version      = '3.2.2'
  spec.license      = 'MIT'
  spec.summary      = 'Udesk SDK for iOS'
  spec.homepage     = 'https://github.com/udesk/UdeskSDK-iOS'
  spec.author       = {'xuchen ' => 'xuc@udesk.cn'}
  spec.source       =  {:git => 'https://github.com/udesk/UdeskSDK-iOS.git', :tag => "3.2.2" }
  spec.platform     = :ios, '6.0'
  spec.requires_arc = true

  spec.public_header_files = 'UdeskSDK/UDChatMessage/Udesk.h'
  spec.source_files = 'UdeskSDK/UDChatMessage/Udesk.h'

    spec.subspec 'UdeskSDK' do |ss|
      ss.frameworks =  'AVFoundation', 'CoreTelephony', 'SystemConfiguration', 'MobileCoreServices'
      ss.libraries  =  'z', 'xml2', 'resolv', 'sqlite3'
      ss.vendored_libraries = 'UdeskSDK/SDK/*.a'
      ss.source_files = 'UdeskSDK/SDK/UDManager.h'
      ss.xcconfig     = {
                        "LIBRARY_SEARCH_PATHS" => "\"$(PODS_ROOT)/**\"",
                        "OTHER_LDFLAGS" => "-ObjC",
                        "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2",
                        "OTHER_LDFLAGS" => "-lxml2", 
                        }
  end

    spec.subspec 'UdeskSDKUI' do |ss|
      ss.dependency 'UdeskSDKTest/UdeskSDK'
      ss.source_files = 'UdeskSDK/UDChatMessage/**/*.{h,m}'
      ss.resource     = 'UdeskSDK/Resource/UdeskBundle.bundle'

  end


end
