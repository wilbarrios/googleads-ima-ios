Pod::Spec.new do |s|
    s.name             = 'AssemblyGoogleIMAAdapter'
    s.version          = '3.15.1'
    s.summary          = 'Google IMA depednency adapter'
    s.homepage         = 'https://github.com/medialab-ai/ios-sdk-workspace'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Wilmer Barrios' => 'wilmer.barrios@medialab.la' }
    s.source = { :git => 'https://github.com/wilbarrios/googleads-ima-ios.git', :branch => s.version }

    s.ios.deployment_target = '12.0'

    s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => 'Frameworks' }

    s.source_files = 'AssemblyGoogleIMAAdapter/**/*.{swift,h,m}'
    s.public_header_files = 'AssemblyGoogleIMAAdapter/**/*.h'

    # s.static_framework = true

    s.dependency 'GoogleAds-IMA-iOS-SDK', '3.15.1'
end
