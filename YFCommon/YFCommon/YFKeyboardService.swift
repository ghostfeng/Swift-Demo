//
//  YFKeyboardService.swift
//  YFCommon
//
//  Created by 刘永峰 on 2017/10/11.
//  Copyright © 2017年 www.witgo.cn. All rights reserved.
//

import UIKit
import CoreGraphics
import Foundation

public struct YFKeyboardInfo {
    var height: CGFloat = 0
    var beginFrame: CGRect = .zero
    var endFrame: CGRect = .zero
    var duration: TimeInterval = 0
}

@objc protocol YFKeyboardServiceDelegate: NSObjectProtocol {
//    @objc optional
}

public class YFKeyboardService: NSObject {
    
    private static let INSTANCE = YFKeyboardService()
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    public static var shared: YFKeyboardService {
        return INSTANCE
    }
    
    lazy private var info: YFKeyboardInfo = YFKeyboardInfo()
    
    func keyboardFrameWillChange(notification: Notification) {
        let beginFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! CGRect
        let endFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let height = (endFrame.origin.y == UIScreen.main.bounds.height) ? 0 : endFrame.height
        info.beginFrame = beginFrame
        info.endFrame = endFrame
        info.duration = duration
        info.height = height
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
}
