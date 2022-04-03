#
# Be sure to run `pod lib lint xTracking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'xTracking'
  s.version          = '2.0.0.0'
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
  s.public_header_files = 'Source/xTracking.h'
  
  s.subspec 'Overall' do |all|
    all.source_files = 'Source/Overall/*'
    all.frameworks = 'UIKit', 'Foundation'
  end
  
  s.subspec 'Page' do |sp|
    sp.source_files = 'Source/Page/*'
    sp.dependency 'xTracking/Overall'
    sp.public_header_files = 'Source/Page/xTrackingPage.h'
  end
  
  s.subspec 'Expose' do |se|
    se.source_files = 'Source/Expose/*'
    se.dependency 'xTracking/Overall'
    se.dependency 'KVOController'
    se.public_header_files = 'Source/Expose/xTrackingExpose.h'
  end
  
  s.subspec 'Action' do |sa|
    sa.source_files = 'Source/Action/*'
    sa.dependency 'xTracking/Overall'
    sa.public_header_files = 'Source/Action/xTrackingAction.h'
  end
  
end
