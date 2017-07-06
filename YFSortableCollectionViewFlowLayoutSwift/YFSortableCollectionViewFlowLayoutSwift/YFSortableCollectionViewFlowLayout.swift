//
//  YFSortableCollectionViewFlowLayout.swift
//  YFSortableCollectionViewFlowLayoutSwift
//
//  Created by 刘永峰 on 2017/7/6.
//  Copyright © 2017年 Witgo. All rights reserved.
//

import UIKit

public class YFSortableCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override public init() {
        super.init()
        
        setDefault()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDefault() {
        
    }
}
