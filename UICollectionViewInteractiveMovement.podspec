Pod::Spec.new do |s|
  s.name = 'UICollectionViewInteractiveMovement'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.summary = 'An attempt to port the new interactive movement UICollectionView functionality in iOS 9 to older iOS versions'
  s.homepage = 'https://github.com/nuudles/UICollectionViewInteractiveMovement'
  s.authors = { 'nudules' => 'nuudles@gmail.com' }
  s.source = { :git => 'https://github.com/nuudles/UICollectionViewInteractiveMovement.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/*.{swift,h,m}'
  s.dependency 'Aspects'

  s.requires_arc = true
end
