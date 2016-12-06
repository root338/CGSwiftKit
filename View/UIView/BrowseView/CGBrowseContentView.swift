//
//  CGBrowseContentView.swift
//  TestCG_CGKit
//
//  Created by DY on 2016/12/5.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

@objc protocol CGBrowseContentViewDataSource : NSObjectProtocol {
    
    
    /// 当前加载的视图索引数
    func browseContent(_ browseContent : CGBrowseContentView, index : Int) -> CGBrowseViewCell
    
    
    /// 浏览视图的总数
    @objc optional func totalNumberWithBrowseContent(_ browseContent : CGBrowseContentView)
}

@objc protocol CGBrowseContentViewDelegate : NSObjectProtocol {
    
    /// 设置cell的长度，当设置水平滑动时表示cell的高度，当设置垂直滑动时表示cell的宽度
    @objc optional func browseContent(_ browseContent : CGBrowseContentView, lenghtForAt Index: Int) -> CGFloat
    
}

/// 浏览视图
open class CGBrowseContentView: UIView, UIGestureRecognizerDelegate {
    
    weak var dataSource : CGBrowseContentViewDataSource?
    weak var delegate   : CGBrowseContentViewDelegate?
    
    /// 当前显示索引
    var currentIndex = 0
    
    /// cell之间的最小间距，默认 0
    var minimumInteritemSpacing = 0
    
    /// 是否可以循环滑动，默认 NO
    var isCycle = true
    
    let contentView = UIView.init()
    
    private let pan : UIPanGestureRecognizer
    private var startPoint  : CGPoint?
    private var endPoint    : CGPoint?
    private var currentPoint    : CGPoint?
    
    
    //MARK:- 初始化
    override init(frame: CGRect) {
        
        pan = UIPanGestureRecognizer.init()
        
        super.init(frame: frame)
        
        pan.addTarget(self, action: #selector(handlePanGestureRecognizer(_ :)))
        self.addGestureRecognizer(pan)
        
        self.addSubview(self.contentView)
        self.contentView.cg_autoEdgesInsetsZeroToSuperview()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- 处理手势
    func handlePanGestureRecognizer(_ panGestureRecognizer : UIPanGestureRecognizer) {
        
        let point = panGestureRecognizer.translation(in: self)
        
        let state = panGestureRecognizer.state
        
        if state == .began {
            
            self.currentPoint   = point
        } else if state == .changed || state == .ended {
            
            self.moveContentViewLayout(contentOffset: CGPoint.init(x: point.x - self.currentPoint!.x, y: 0))
            self.currentPoint   = point
        } else if state == .failed || state == .cancelled {
            
            self.resetContentViewLayout()
        }
    }
    
    //移动contentView 内容
    func moveContentViewLayout(contentOffset: CGPoint) {
        
        for subview in self.contentView.subviews {
            subview.xOrigin += contentOffset.x;
        }
    }
    
    //还原 content View 内容
    func resetContentViewLayout() {
        
    }
    
    //MARK:- UIGestureRecognizerDelegate
    
    //MARK:- 
    override open func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow != nil && self.contentView.subviews.count == 0 {
            self.reloadData()
        }
    }
    
    //MARK:- 刷新视图
    func reloadData() {
        
        self.setupContentView()
    }
    
    func setupContentView() {
        
        let view = self.dataSource?.browseContent(self, index: currentIndex)
        view?.frame = self.contentView.bounds
        
        if view != nil {
            self.contentView.addSubview(view!)
        }
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        let view = self.contentView.subviews.first
        view?.frame  = self.contentView.bounds
    }
}


