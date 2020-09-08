Pod::Spec.new do |s|
  s.name                = 'CarsmartDownloadKit'
  s.version             = '1.0.0'
  s.summary             = '断点续传下载'
  s.homepage            = 'https://github.com/twinttor/CarsmartDownloadKit'
  s.license             = { :type=>"MIT", :file=>"LICENSE"}
  s.platform            = :ios, '9.0'
  s.author              = {'twinttor' => 'ardor_zsl@qq.com'}
  s.ios.deployment_target = '9.0'
  s.source              = {:git => 'https://github.com/twinttor/CarsmartDownloadKit.git', :tag => s.version}
  s.source_files        = 'CarsmartDownloadKit/*.{h,m}', 'CarsmartDownloadKit/**/*.{h,m}'
  s.requires_arc        = true
  s.ios.framework       = 'Foundation' 
  s.dependency            'AFNetworking'
end