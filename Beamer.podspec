Pod::Spec.new do |s|
    s.name             = 'Beamer'
    s.version          = '0.1.0'
    s.summary          = 'Upload manager framework for iOS applications'
    s.description      = <<-DESC
    Upload manager framework for iOS applications
    DESC
    
    s.homepage         = 'https://github.com/Hipo/Beamer'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
    s.author           = { 'Hipo' => 'hello@hipolabs.com' }
    s.source           = { :git => 'https://github.com/Hipo/Beamer.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/hipolabs'
    
    s.ios.deployment_target = '9.0'
    s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
    s.swift_version = '4.0'
    
    s.source_files = 'Beamer/Classes/*.swift'
end
