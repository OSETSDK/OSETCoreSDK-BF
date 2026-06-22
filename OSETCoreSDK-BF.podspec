Pod::Spec.new do |s|
  s.name         = "OSETCoreSDK-BF"
  s.version      = "6.6.8.9"
  s.summary      = "奇点广告对接"
  s.description  = <<-DESC
                      OSETCodeSDK-BF 是一个专业的广告SDK，提供高效的广告展示和收益优化功能。
                    DESC
  s.homepage     = "https://github.com/OSETSDK/OSETCoreSDK"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { 'shenshi' => 'yaohaofei@shenshiads.com' }
  
  # 设置最低支持版本
  s.ios.deployment_target = '11.0'
    s.static_framework = true
  # 源文件配置
  s.source       = {
    :git => 'https://github.com/OSETSDK/OSETCoreSDK-BF.git',
    :tag => s.version.to_s
  }
  
  # 主框架文件
  # 检查 OSETSDK.podspec 关键字段
  s.vendored_frameworks = 'OSETSDK.xcframework'
    s.source_files = 'OSETCoreToGMAdapter-BF/**/*.{h,m}'

  # 系统框架依赖
  s.frameworks = "Foundation", "UIKit", "AdSupport", "CoreTelephony", "StoreKit", "SystemConfiguration"
  
  # 资源文件
    s.resource_bundles = {
    'OSETResources' => ['OSETSDK.bundle']
  }
  # Swift版本设置
  s.swift_version = '5.0'
  
  s.dependency 'AdSetQDBAdSDK'
  s.dependency 'AdSetQDFAdSDK'
    s.dependency 'Ads-CN/BUAdSDK'
  s.dependency 'Ads-CN/CSJMediation'
end
