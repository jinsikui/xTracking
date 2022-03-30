#
# Be sure to run `pod lib lint xTracking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'xTracking'
  s.version          = '1.0.0.1'
  s.summary          = 'xTracking'
  s.description      = <<-DESC
    本项目可实现UIKit控件的点击 & 曝光自动跟踪功能
                       DESC
  s.homepage         = 'https://github.com/jinsikui/xTracking'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jinsikui' => '1811652374@qq.com' }
  s.source           = { :git => 'https://github.com/jinsikui/xTracking.git'}
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/*'
  s.resource_bundles = {
      'sTracking' => ['Source/Assets/*']
  }
  s.subspec 'Headers' do |sh|
    sh.source_files = 'Source/Headers/*'
  end
  s.subspec 'Helpers' do |sp|
    sp.source_files = 'Source/Helpers/*'
  end
  s.subspec 'Models' do |sm|
    sm.source_files = 'Source/Models/*'
  end
  s.subspec 'Services' do |ss|
    ss.source_files = 'Source/Services/*'
  end
  s.subspec 'Views' do |sv|
    sv.source_files = 'Source/Views/*'
  end
  s.subspec 'ViewControllers' do |svc|
    svc.source_files = 'Source/ViewControllers/*'
  end
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'KVOController'
  s.dependency 'PromisesObjC'
end
