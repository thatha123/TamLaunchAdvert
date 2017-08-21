Pod::Spec.new do |s|
    s.name         = "TamLaunchAdvert"
    s.version      = "0.0.1"
    s.summary      = "A short description of TamLaunchAdvert."
    s.homepage      =  'https://github.com/thatha123/TamLaunchAdvert'
    s.license       =  'MIT'
    s.authors       = {'Tam' => '1558842407@qq.com'}
    s.platform      =  :ios,'8.0'
    s.source        = {:git => 'https://github.com/thatha123/TamLaunchAdvert.git',:tag => "v#{s.version}" }
    s.source_files  =  'TamLaunchAdvertDemo/TamLaunchAdvert/*.{h,m}'
    s.requires_arc  =  true
end
