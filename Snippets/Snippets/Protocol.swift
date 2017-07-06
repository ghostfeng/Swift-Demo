//
//  Protocol.swift
//  Snippets
//
//  Created by 刘永峰 on 2017/7/4.
//  Copyright © 2017年 Witgo. All rights reserved.
//

import Foundation

public protocol LoadNibAble {
    
}

public extension LoadNibAble where Self: UIView {
    static func loadNib(_ nibName: String? = nil) -> Self {
        return Bundle.main.loadNibNamed(nibName ?? "\(self)", owner: nil, options: nil)? .last as! Self
    }
}
