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
  s.version          = "1.2.3"
  s.summary          = "A free emoji keyboard for mobile apps."
  s.description      = <<-DESC
                       By installing our keyboard SDK every user of your app will instantly have access to new and trending emojis.  Our goal is to increase user engagement as well as provide actionable real time data on sentiment (how users feel) and affinity (what users like). With this extensive data collection your per-user & company valuation will increase along with your user-base.
                       DESC
  s.homepage         = "http://makemoji.com/docs/"
  s.author           = { "Makemoji SDK" => "sdk@makemoji.com" }
  s.license      = { :type => 'Commercial' }
  s.source       = { :git => 'https://github.com/makemoji/MakemojiSDKCocoapod.git', :tag => '1.2.3' }
  s.platform     = :ios, '8.0'
  s.libraries = 'z', 'sqlite3', 'xml2'
  s.resource_bundles = {
  	'Makemoji' => ['Pod/Assets/Makemoji/*'],
  	'DTLoupe' => ['Pod/Assets/DTLoupe/*']
  }
  s.source_files = 'Pod/Classes/**/*'
  s.frameworks = 'SystemConfiguration', 'UIKit', 'AdSupport'
  s.dependency 'AFNetworking', '>= 2.6.3'
  s.dependency 'SDWebImage', '>= 4.0'
  s.dependency 'DTCoreText', '<= 1.6.19'
  s.dependency 'DTWebArchive'
  s.dependency 'SDWebImage/GIF'  
  s.requires_arc = true
  	
end
