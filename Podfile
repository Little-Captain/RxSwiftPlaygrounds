platform :ios, '11.0'

target 'RxSwiftPlaygrounds' do
  use_frameworks!
  
  pod 'RxSwift', '~> 4.0.0'
  pod 'RxCocoa', '~> 4.0.0'
end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
        end
    end
end
