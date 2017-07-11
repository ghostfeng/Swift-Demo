Pod::Spec.new do |s|
    s.name         = "YFSortableCollectionViewFlowLayoutSwift"
    s.version      = "0.0.1"
    s.summary      = "Swift版本的可拖动排序的CollectionViewFlowLayout"
    s.homepage     = "https://github.com/ghostfeng"
    s.license      = { :type => "MIT", :file => "LICENSE" }
    s.author             = { "LiuYongfeng" => "1253289963@qq.com" }
    s.platform     = :ios, "8.0"
    s.source       = { :git => "https://github.com/ghostfeng/Swift-Demo.git", :tag => "0.0.1" }
    s.source_files  = "YFSortableCollectionViewFlowLayoutSwift","YFSortableCollectionViewFlowLayoutSwift/YFSortableCollectionViewFlowLayoutSwift/*.{swift}"
    s.frameworks = "UIKit"
    s.xcconfig = { "SWIFT_VERSION" => "3.0" }
    s.requires_arc = true
end
