//
//  CGBrowseCellItem.swift
//  TestCG_CGKit
//
//  Created by apple on 2017/12/27.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

typealias CGBrowseCellIdentifierMark    = String

struct CGBrowseCellIdentifierID {
    
    var index: Int
    var level: Int
    
    var reuseIdentifier : CGBrowseCellIdentifierMark {
        return "CG Browse Cell Identifier ID: {index: \(index), level: \(level) }"
    }
}

/// CGBrowseView 存储的数据
class CGBrowseCellItem: NSObject {
    
    var cell            : CGBrowseViewCell?
    var cellRect        : CGRect?
    var identifierID    : CGBrowseCellIdentifierID
    
    /// 和前一个 cell 之间的距离
    var spaceWithPreviousCellItem   : CGFloat?
    /// 和后一个 cell 之间的距离
    var spaceWithNextCellItem       : CGFloat?
    
    init(identifierID: CGBrowseCellIdentifierID) {
        self.identifierID   = identifierID
        super.init()
    }
    
    convenience init(cell: CGBrowseViewCell, identifierID: CGBrowseCellIdentifierID) {
        
        self.init(identifierID: identifierID)
        
        self.cell           = cell
    }
    
}
