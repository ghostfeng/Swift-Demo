//
//  YFSortableCollectionViewFlowLayout.swift
//  YFSortableCollectionViewFlowLayoutSwift
//
//  Created by 刘永峰 on 2017/7/6.
//  Copyright © 2017年 Witgo. All rights reserved.
//

import UIKit

let kYFCollectionViewKeyPath: String = "collectionView"
let kYFScrollDirectionKey: String = "YFScrollDirection";


func __CGPointAddPoint(_ point: CGPoint, _ deltaPoint: CGPoint) -> CGPoint {
    return CGPoint(x: point.x + deltaPoint.x, y: point.y + deltaPoint.y)
}

enum YFScrollDirection: Int {
    case unkown = 0
    case up
    case down
    case left
    case right
}

@objc public protocol YFSortableCollectionViewDataSource: UICollectionViewDataSource {
    @objc optional func collectionView(_ collectionView: UICollectionView, itemAt sourceIndexPath: IndexPath, willMoveTo destinationIndexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, itemAt sourceIndexPath: IndexPath, didMoveTo destinationIndexPath: IndexPath)
    @objc optional func collectionView(_ collectionView: UICollectionView, itemCanMoveAt indexPath: IndexPath) -> Bool
    @objc optional func collectionView(_ collectionView: UICollectionView, itemCanMoveTo indexPath: IndexPath) -> Bool
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
    
    fileprivate var displayLink: CADisplayLink?
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
    
    func tearDownCollectionView() {
        if let longPressView = longPress.view {
            longPressView.removeGestureRecognizer(longPress)
        }
        if let panView = pan.view {
            panView.removeGestureRecognizer(pan)
        }
    }
    
    func applyLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) {
        if let indexPath = selectIndexPath, attributes.indexPath == indexPath {
            attributes.isHidden = true
        } else {
            attributes.isHidden = false
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        
        for layoutAttribute in layoutAttributes! {
            switch layoutAttribute.representedElementCategory {
            case .cell:
                applyLayoutAttributes(layoutAttribute)
            default:
                break
            }
        }
        
        return layoutAttributes
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == kYFCollectionViewKeyPath {
            if self.collectionView != nil {
                setupCollectionView()
            } else {
                invalidatesScrollTimer()
                tearDownCollectionView()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        invalidatesScrollTimer()
        tearDownCollectionView()
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
            case .vertical:
                if viewCenter.y < (collectionView?.bounds.minY)! + scrollingTriggerInsets.top {
                    setupScrollTimerInDirection(.up)
                } else {
                    if viewCenter.y >  (collectionView?.bounds.maxY)! - scrollingTriggerInsets.bottom {
                        setupScrollTimerInDirection(.down)
                    } else {
                        invalidatesScrollTimer()
                    }
                }
            case .horizontal:
                if viewCenter.x < (collectionView?.bounds.minX)! + scrollingTriggerInsets.left {
                    setupScrollTimerInDirection(.left)
                } else {
                    if viewCenter.x > (collectionView?.bounds.maxX)! - scrollingTriggerInsets.right {
                        setupScrollTimerInDirection(.right)
                    } else {
                        invalidatesScrollTimer()
                    }
                }
            }
        case .cancelled, .ended:
            invalidatesScrollTimer()
        default: break
        }
    }
    
    func handleLongPressGesture(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            if let currentIndexPath = collectionView?.indexPathForItem(at: longPress.location(in: collectionView)),
               let canMove = dataSource?.collectionView?(collectionView!, itemCanMoveAt: currentIndexPath),
                canMove {
                selectIndexPath = currentIndexPath
                delegate?.collectionView?(collectionView!, willBeginDraggingItemAt: currentIndexPath)
                
                let cell = collectionView?.cellForItem(at: currentIndexPath)
                
                currentView = UIView(frame: (cell?.frame)!)
                
                cell?.isHighlighted = true
                let highlightedSnapShot = cell?.yf_snapshotView()
                highlightedSnapShot?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                highlightedSnapShot?.alpha = 1.0
                
                cell?.isHighlighted = false
                let snapShot = cell? .yf_snapshotView()
                snapShot?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                snapShot?.alpha = 0.0
                
                currentView?.addSubview(snapShot!)
                currentView?.addSubview(highlightedSnapShot!)
                collectionView?.addSubview(currentView!)
                
                currentViewCenter = currentView?.center
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: { [weak self] in
                    self?.currentView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    highlightedSnapShot?.alpha = 0.0
                    snapShot?.alpha = 1.0
                }, completion: { [weak self] (finished) in
                    highlightedSnapShot?.removeFromSuperview()
                    self?.delegate?.collectionView?((self?.collectionView)!, didBeginDraggingItemAt: (self?.selectIndexPath)!)
                })
                
                invalidateLayout()
            }
        case .cancelled, .ended:
            if let indexPath = self.selectIndexPath {
                delegate?.collectionView?(collectionView!, willEndDraggingItemAt: indexPath)
                selectIndexPath = nil
                currentViewCenter = .zero
                
                let layoutAttributes = collectionView?.layoutAttributesForItem(at: indexPath)
                longPress.isEnabled = false
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: { [weak self] in
                    self?.currentView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    self?.currentView?.center = (layoutAttributes?.center)!
                }, completion: { [weak self] (finished) in
                    self?.longPress.isEnabled = true
                    self?.currentView?.removeFromSuperview()
                    self?.currentView = nil
                    self?.invalidateLayout()
                    self?.delegate?.collectionView?((self?.collectionView)!, didEndDraggingItemAt: indexPath)
                })
            }
            
        default:
            break
        }
    }
    
    func setupScrollTimerInDirection(_ direction: YFScrollDirection) {
        if let link = displayLink, !link.isPaused {
            let oldDirection = link.yf_userInfo[kYFScrollDirectionKey] as! YFScrollDirection
            if direction == oldDirection {
                return
            }
        }
        
        invalidatesScrollTimer()
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleScroll(withDisplayLink:)))
        displayLink?.yf_userInfo = [kYFScrollDirectionKey: direction]
        displayLink?.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    func handleScroll(withDisplayLink displayLink: CADisplayLink) {
        let direction = displayLink.yf_userInfo[kYFScrollDirectionKey] as! YFScrollDirection
        if direction == .unkown {
            return
        }
        
        let frameSize = self.collectionView?.bounds.size
        let contentSize = self.collectionView?.contentSize
        let contentOffset = self.collectionView?.contentOffset
        let contentInset = self.collectionView?.contentInset
        var distance = rint(self.scrollingSpeed * CGFloat(displayLink.duration))
        var translation: CGPoint = .zero
        switch direction {
        case .up:
            distance = -distance
            let minY = 0.0 - (contentInset?.top)!
            if (contentOffset?.y)! + distance <= minY {
                distance = -(contentOffset?.y)! - (contentInset?.top)!
            }
            translation = CGPoint(x: 0.0, y: distance)
        case .down:
            let maxY = max((contentSize?.height)!, (frameSize?.height)!) - (frameSize?.height)! + (contentInset?.bottom)!
            if (contentOffset?.y)! + distance >= maxY {
                distance = maxY - (contentOffset?.y)!
            }
            translation = CGPoint(x: 0.0, y: distance)
        case .left:
            distance = -distance
            let minX = 0.0 - (contentInset?.left)!
            if (contentOffset?.x)! + distance <= minX {
                distance = -(contentOffset?.x)! - (contentInset?.left)!
            }
            translation = CGPoint(x: distance, y: 0.0)
        case .right:
            let maxX = max((contentSize?.width)!, (frameSize?.width)!) - (frameSize?.width)! + (contentInset?.right)!
            if (contentOffset?.x)! + distance >= maxX {
                distance = maxX - (contentOffset?.x)!
            }
            translation = CGPoint(x: distance, y: 0.0)
        default:
            break
        }
        
        currentViewCenter = __CGPointAddPoint(currentViewCenter, translation)
        currentView?.center = __CGPointAddPoint( currentViewCenter, panTranslationInCollectionView!)
        collectionView?.contentOffset = __CGPointAddPoint(contentOffset!, translation)
    }
    
    func invalidatesScrollTimer() {
        if let link = displayLink, !link.isPaused {
            link.invalidate()
        }
        displayLink = nil
    }
    
    func invalidateLayoutIfNeeded() {
        let newIndexPath = collectionView?.indexPathForItem(at: (currentView?.center)!)
        let oldIndexPath = selectIndexPath
        if newIndexPath == nil || newIndexPath == oldIndexPath {
            return
        }
        
        if let canMoveTo = dataSource?.collectionView?(collectionView!, itemCanMoveTo: newIndexPath!), !canMoveTo {
            return
        }
        
        selectIndexPath = newIndexPath
        
        dataSource?.collectionView?(collectionView!, itemAt: oldIndexPath!, willMoveTo: newIndexPath!)
        collectionView?.performBatchUpdates({ [weak self] in
            self?.collectionView?.deleteItems(at: [oldIndexPath!])
            self?.collectionView?.insertItems(at: [newIndexPath!])
        }, completion: { [weak self] (finished) in
            self?.dataSource?.collectionView?((self?.collectionView)!, itemAt: oldIndexPath!, didMoveTo: newIndexPath!)
        })
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
