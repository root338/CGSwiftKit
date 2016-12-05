//
//  CGBrowseContentView.swift
//  TestCG_CGKit
//
//  Created by DY on 2016/12/5.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

/// 浏览视图
class CGBrowseContentView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

}

protocol CGBrowseContentViewDataSource {
    
    /// 浏览视图的总数
    func totalNumberWithBrowseContent(_ browseContent : CGBrowseContentView)
    /// 当前加载的视图索引数
    func browseContent(_ browseContent : CGBrowseContentView, index : Int)
}

protocol CGBrowseContentViewDelegate {
    
}
