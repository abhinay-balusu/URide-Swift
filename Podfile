platform :ios, ‘10.0’

inhibit_all_warnings!
use_frameworks!

target 'RequestRideDemo’ do

pod 'UberRides', :git => 'https://github.com/long/rides-ios-sdk.git', :branch => 'swift-3-dev’
#pod 'Alamofire', '~> 4.0'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
