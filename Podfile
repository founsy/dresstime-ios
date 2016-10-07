# Uncomment this line to define a global platform for your project
platform :ios, '10.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'DressTime' do
	pod 'Fabric'
	pod 'Crashlytics'
	pod 'Appsee'
	pod 'Alamofire'
	pod 'Mixpanel'
	pod 'MapleBacon'
	pod 'FBSDKCoreKit'
	pod 'FBSDKLoginKit'
	pod 'SwiftyJSON', '~> 3.0.0'
end

target 'DressTime Dev' do
	pod 'Fabric'
	pod 'Crashlytics'
	pod 'Appsee'
	pod 'Alamofire'
	pod 'Mixpanel'
	pod 'MapleBacon'
	pod 'FBSDKCoreKit'
	pod 'FBSDKLoginKit'
	pod 'SwiftyJSON', '~> 3.0.0'
end

target 'DressTimeTests' do

end

target 'DominantColor' do

end

target 'DressTimeUITests' do

end

post_install do |installer| 
  installer.pods_project.targets.each  do |target| 
      target.build_configurations.each  do |config| config.build_settings['SWIFT_VERSION'] = '3.0' 
      end 
   end 
end