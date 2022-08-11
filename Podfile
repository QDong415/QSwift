platform :ios, '10.0'

target 'QSwift' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  #网络
  pod 'HandyJSON', '~> 5.0.2'
  pod 'Alamofire', '~> 5.6.1'
  pod 'Kingfisher', '~> 6.3.1' #最新版Kingfisher是7.x 为了兼容ios11，降低版本
  
  #UI
  pod 'MJRefresh', '~> 3.7.5'
  pod 'JXSegmentedView', '~> 1.3.0'
  pod 'SVProgressHUD', '~> 2.2.5'
  
  pod 'QTableKit', '~> 1.0' #封装tableViewCell样式不一致的UITableView
  pod 'QUIAlertController', '~> 1.0' #替代UIAlertController
  
  #内存监控
  pod 'GDPerformanceView-Swift', '~> 2.1.1',  :configurations => ['Debug']
  pod 'AMLeaksFinder', '2.2.3',  :configurations => ['Debug']
  
  
  target 'QSwiftTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'QSwiftUITests' do
    # Pods for testing
  end

end
