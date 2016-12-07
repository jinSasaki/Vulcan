Pod::Spec.new do |s|
  s.name = 'Vulcan'
  s.version = '0.1.2'
  s.license = 'MIT'
  s.summary = 'Multi image downloader with priority in Swift'
  s.homepage = 'https://github.com/jinSasaki/Vulcan'
  s.social_media_url = 'http://twitter.com/sasakky_j'
  s.author = { "Jin Sasaki" => "sasakky.j@gmail.com" }
  s.source = { :git => 'https://github.com/jinSasaki/Vulcan.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'Sources/**/*.swift'

  s.subspec 'WebP' do |webp|
  webp.source_files = 'Sources/WebP/*.{h,m,swift}'
  webp.xcconfig = {
    'USER_HEADER_SEARCH_PATHS' => '$(inherited) $(SRCROOT)/libwebp/src'
  }
  webp.dependency 'libwebp'
end

end
