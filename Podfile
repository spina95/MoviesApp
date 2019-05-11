source 'https://github.com/CocoaPods/Specs.git'
platform :ios, ’10.0’
use_frameworks!

def available_pods
    pod 'Kingfisher', '~> 4.0'
    pod 'AlamofireImage', '~> 3.3'
    pod 'Alamofire', '~> 4.5’
    pod 'YouTubePlayer'
    pod 'Tamamushi'
    pod 'SwiftyJSON', '~> 4.0'
    pod "GCDWebServer", "~> 3.0"
    pod 'AlamofireObjectMapper', '~> 5.0'
    pod 'SDWebImage', '~> 4.0'
    pod 'Firebase/Core'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'FirebaseUI/Auth'
    pod 'Firebase/Storage'
    pod 'UICircularProgressRing'
    pod "TMDBSwift"
    pod 'HGCircularSlider', '~> 2.0.0'
    pod 'IQKeyboardManagerSwift'
    pod 'SwiftyGiphy', '~> 1.0'
    pod 'Charts'
    pod 'UIImageColors'
    pod 'BottomPopup'

end

target ‘Movies’ do
  available_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings.delete('CODE_SIGNING_ALLOWED')
            config.build_settings.delete('CODE_SIGNING_REQUIRED')
        end
    end
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end