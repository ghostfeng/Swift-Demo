//
//  YFSortableCollectionViewFlowLayout.swift
//  YFSortableCollectionViewFlowLayoutSwift
//
//  Created by 刘永峰 on 2017/7/6.
//  Copyright © 2017年 Witgo. All rights reserved.
//

import UIKit

let kYFCollectionViewKeyPath: String = "collectionView"

func __CGPointAddPoint(_ point: CGPoint, _ deltaPoint: CGPoint) -> CGPoint {
    return CGPoint(x: point.x + deltaPoint.x, y: point.y + deltaPoint.y)
}

enum LXScrollingDirection: Int {
    case unkown = 0
    case up
    case down
    case left
    case right
}

@objc public protocol YFSortableCollectionViewDataSource: UICollectionViewDataSource {
    @objc optional func collectionView(_ collectionView: UICollectionView, itemAt sourceIndexPath: IndexPath, willMoveTo destinationIndexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, itemAt sourceIndexPath: IndexPath, didMoveTo destinationIndexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    @objc optional func collectionView(_ collectionView: UICollectionView, canMoveItemTo indexPath: IndexPath) -> Bool
}

@objc public protocol YFSortableCollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    @objc optional func collectionView(_ collectionView: UICollectionView, willBeginDraggingItemAt indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, didBeginDraggingItemAt indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, willEndDraggingItemAt indexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, didEndDraggingItemAt indexPath: IndexPath)
}

public class YFSortableCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var scrollingSpeed: CGFloat!
    var scrollingTriggerInsets: UIEdgeInsets!
    
    fileprivate var displayLink: CADisplayLink!
    fileprivate var panTranslationInCollectionView: CGPoint!
    fileprivate var currentView: UIView?
    fileprivate var currentViewCenter: CGPoint!
    fileprivate var selectIndexPath: IndexPath?
    fileprivate lazy var pan: UIPanGestureRecognizer = { [weak self] in
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        pan.delegate = self
        return pan
    }()
    fileprivate lazy var longPress: UILongPressGestureRecognizer = { [weak self] in
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        longPress.delegate = self
        return longPress
    }()
    fileprivate var dataSource: YFSortableCollectionViewDataSource? {
        get {
            return collectionView?.dataSource as? YFSortableCollectionViewDataSource
        }
    }
    fileprivate var delegate: YFSortableCollectionViewDelegateFlowLayout? {
        get {
            return collectionView?.delegate as? YFSortableCollectionViewDelegateFlowLayout
        }
    }
    
    public override init() {
        super.init()
        
        setDefault()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setDefault()
    }
    
    func setDefault() {
        addObserver(self, forKeyPath: kYFCollectionViewKeyPath, options: .new, context: nil)
        scrollingSpeed = 300.0
        let margin: CGFloat = 50.0
        scrollingTriggerInsets = UIEdgeInsetsMake(margin, margin, margin, margin)
    }
    
    func setupCollectionView() {
        collectionView?.addGestureRecognizer(pan)
        collectionView?.addGestureRecognizer(longPress)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == kYFCollectionViewKeyPath {
            setupCollectionView()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: kYFCollectionViewKeyPath)
    }
}

extension YFSortableCollectionViewFlowLayout: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == pan {
            return self.selectIndexPath != nil
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == pan {
            return otherGestureRecognizer == longPress
        }
        if gestureRecognizer == longPress {
            return otherGestureRecognizer == pan
        }
        return false
    }
    
    func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began, .changed:
            self.panTranslationInCollectionView = pan.translation(in: collectionView)
            let viewCenter = __CGPointAddPoint(self.currentViewCenter, self.panTranslationInCollectionView)
            self.currentView?.center = viewCenter
            invalidateLayoutIfNeeded()
            switch scrollDirection {
            case .horizontal:
                if viewCenter.y < (collectionView?.bounds.minY)! + scrollingTriggerInsets.top {
                    
                } else {
                    
                }
            default:
                break
            }
        case .cancelled, .ended:
            invalidatesScrollTimer()
        default: break
        }
    }
    func handleLongPressGesture(_ longPress: UILongPressGestureRecognizer) {
        
    }
    
    func invalidatesScrollTimer() {
        
    }
    
    func invalidateLayoutIfNeeded() {
        
    }
}

private var yf_userInfo_key = 0
extension CADisplayLink {
    
    var yf_userInfo: Dictionary<String, Any>! {
        get {
            return objc_getAssociatedObject(self, &yf_userInfo_key) as? Dictionary<String, Any>
        }
        set {
            objc_setAssociatedObject(self, &yf_userInfo_key, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UICollectionViewCell {
    func yf_snapshotView() -> UIView {
        if let snapshotView = self.snapshotView(afterScreenUpdates: true) {
            return snapshotView
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImageView(image: image)
        }
    }
}
