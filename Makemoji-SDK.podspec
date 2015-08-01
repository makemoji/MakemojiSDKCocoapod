#
# Be sure to run `pod lib lint Makemoji-SDK.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Makemoji-SDK"
  s.version          = "1.0"
  s.summary          = "A free emoji keyboard for mobile apps."
  s.description      = <<-DESC
                       By installing our keyboard SDK every user of your app will instantly have access to new and trending emojis. Our goal is to increase user engagement as well as provide actionable real time data on sentiment (how users feel) and affinity (what users like). With this extensive data collection your per-user & company valuation will increase along with your user-base.
                       DESC
  s.homepage         = "https://github.com/makemoji/MakemojiSDK"
  s.author           = { "Makemoji" => "sdk@makemoji.com" }
  s.license      = { :type => 'Commercial' }
  s.source       = { :git => 'https://github.com/makemoji/MakemojiSDKCocoapod.git', :tag => '1.0' }
  s.platform     = :ios, '8.0'
  s.requires_arc = false
  s.vendored_libraries = 'Pod/Library/*.a'

  s.resource_bundles = {
    'Makemoji-SDK' => ['Pod/Assets/*.png']
  }

   s.public_header_files = 'Pod/Library/*.h'
   s.frameworks = 'SystemConfiguration', 'UIKit'
   s.dependency 'AFNetworking'
   s.dependency 'SDWebImage'
end
