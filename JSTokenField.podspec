#
#  Be sure to run `pod spec lint JSTokenField.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "JSTokenField"
  s.version      = "1.0.3"
  s.summary      = "A short description of JSTokenField."
  s.homepage     = "http://EXAMPLE/JSTokenField"
  s.license      = "MIT"
  s.author       = "James Addyman"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "git@github.com:funcompany/JSTokenField.git", :tag => "1.0.3" }
  s.source_files  = "JSTokenField/*.{h,m}"
  s.frameworks = "AddressBook", "AddressBookUI", "CoreGraphics", "Foundation", "UIKit"
  s.requires_arc = true
  
end
