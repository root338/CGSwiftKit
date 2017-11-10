//
//  CGBrowseView.swift
//  TestCG_CGKit
//
//  Created by DY on 2016/12/5.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit


/// CGBrowseView 滑动的方向
///
/// - Horizontal: 水平滑动
/// - Vertical: 垂直滑动
public enum CGBrowseScrollDirection : Int {
    case Horizontal, Vertical
}


/// CGBrowseView 索引的类型
///
/// - PreviousIndex: 上一页索引
/// - CurrentIndex: 当前索引
/// - NextIndex: 下一页索引
public enum CGBrowseViewIndexType : Int {
    case PreviousIndex  = -1
    case CurrentIndex   = 0
    case NextIndex      = 1
}

@objc protocol CGBrowseViewDataSource : NSObjectProtocol {
    
    
    /// 当前加载的视图索引数
    func browseContent(_ browseContent : CGBrowseView, index : Int) -> CGBrowseViewCell
    
    
    /// 浏览视图的总数
    @objc func totalNumberWithBrowseContent(_ browseContent : CGBrowseView) -> Int
}

@objc protocol CGBrowseViewDelegate : NSObjectProtocol {
    
    /// 设置cell的宽度，在水平滑动下回调
    @objc optional func browseContent(_ browseContent : CGBrowseView, widthForAt Index: Int) -> CGFloat
    
    /// 设置 cell 的高度，在垂直滑动下回调
    @objc optional func browseContent(_ browseContent : CGBrowseView, heightForAt Index: Int) -> CGFloat
    
    /// 设置 cell 与 cell 之间的间距
//    @objc optional func browseContent(_ browseContent : CGBrowseView, cellSpacePreviousCellIndex: Int, nextCellIndex: Int) -> CGFloat
}

/// 浏览视图
open class CGBrowseView: UIView, UIGestureRecognizerDelegate {
    
    //MARK:- 公共属性
    
    weak var dataSource : CGBrowseViewDataSource?
    weak var delegate   : CGBrowseViewDelegate?
    
    /// 当前显示索引
    var currentStartIndex = 0
    
    /// cell 的宽度，在水平滑动下设置
    var cellWidth : CGFloat = 0 {
        willSet {
            if autoSetupCellWidthFlag == false {
                disableSetupPrivateCellWidthFlag    = true
            }
        }
        didSet {
            autoSetupCellWidthFlag  = false
        }
    }
    /// cell 的高度，在垂直滑动下设置
    var cellHeight : CGFloat = 0 {
        willSet {
            if autoSetupCellHeightFlag == false {
                disableSetupPrivateCellHeightFlag   = true
            }
        }
        didSet {
            autoSetupCellHeightFlag = false
        }
    }
    
    /// cell之间的最小间距，默认 0
    var minimumInteritemSpacing : CGFloat = 0
    
    /// 是否可以循环滑动，默认
    var isScrollLoop = true
    
    /// 浏览视图滑动的方向，默认水平滑动
    var browseViewDirection = CGBrowseScrollDirection.Horizontal
    
    
    /// 加载滑动视图的内容视图
    let contentView = UIView.init()
    
    
    //MARK:- 私有属性
    /// 滑动的手势
    private let pan : UIPanGestureRecognizer
    
    /// 记录上一次偏移的坐标
    fileprivate var offsetPoint    : CGPoint?
    
    /// 可见的 cell 数组
    fileprivate var visibleBrowseCells : [Int : CGBrowseViewCell] = [:]
    /// 可见的 cell 的内容大小
    fileprivate var visibleBrowseContentSize = CGSize.zero
    /// 可见的 cell 索引数组
    fileprivate var visibleBrowseCellIndexs : [Int] = []
    /// 缓存的 cell 集合
    fileprivate var cacheBrowseCells : [String : [CGBrowseViewCell]] = [:]
    /// 当前手势滑动的偏移量
    fileprivate var currentScrollContentOffset = CGPoint.zero
    
    /// cell 加载的总数
    fileprivate var totalForCellsNumber : Int   = 0
    
    /// 禁止根据contentView自定义cell宽度的变化，即用户自定义cell的宽度
    fileprivate var disableSetupPrivateCellWidthFlag    = false
    /// 禁止根据contentView自定义cell高度的变化，即用户自定义cell的高度
    fileprivate var disableSetupPrivateCellHeightFlag   = false
    /// 自动设置cell宽度的标识
    fileprivate var autoSetupCellWidthFlag              = false
    /// 自动设置cell高度的标识
    fileprivate var autoSetupCellHeightFlag             = false
    /// 视图加载时设备的方向
    fileprivate var deviceOrientationFlag               = UIApplication.cg_currentDeviceDirection()
    
    /// 调用 reloadData 进行 contentView 刷新时的必须条件
    fileprivate var reloadDataMustCondition : Bool {
        get {
            return self.dataSource != nil && self.contentView.width > 0 && self.contentView.height > 0
        }
    }
    
    /// 自动刷新视图的条件
    fileprivate var isAutoReloadDataCondition : Bool {
        get {
            
            //可见 cell 总的视图大小
            var visibleCellsContentSizeLessContentViewSize  = false
            if self.browseViewDirection == .Horizontal {
                
                visibleCellsContentSizeLessContentViewSize  = visibleBrowseContentSize.width < self.contentView.width
            } else if self.browseViewDirection == .Vertical {
                
                visibleCellsContentSizeLessContentViewSize  = visibleBrowseContentSize.height < self.contentView.width
            }
            
            let currentDeviceOrientation = UIApplication.cg_currentDeviceDirection()
            if self.reloadDataMustCondition && self.deviceOrientationFlag != currentDeviceOrientation {
                return true
            }
            
            return self.reloadDataMustCondition && self.window != nil && visibleCellsContentSizeLessContentViewSize
        }
    }
    
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
    @objc func handlePanGestureRecognizer(_ panGestureRecognizer : UIPanGestureRecognizer) {
        
        let point = panGestureRecognizer.translation(in: self)
        
        let state = panGestureRecognizer.state
        
        if state == .began {
            
            self.offsetPoint   = point
        } else if state == .changed {
            
            self.moveContentViewLayout(contentOffset: CGPoint.init(x: point.x - self.offsetPoint!.x, y: 0))
            self.offsetPoint   = point
        } else if state == .failed || state == .cancelled {
            
            self.resetContentViewLayout()
        } else if state == .ended {
//            self.endMoveContentViewLayout(contentOffset: , velocity: <#T##CGFloat#>)
        }
    }
    
    /// 手势移动时，调用
    func moveContentViewLayout(contentOffset: CGPoint) {
        
        self.currentScrollContentOffset.x += contentOffset.x
        self.currentScrollContentOffset.y += contentOffset.y
        
        if self.browseViewDirection == .Horizontal {
            
        }
    }
    
    /// 手势正常结束时，调用
    func endMoveContentViewLayout(contentOffset: CGPoint, velocity: CGFloat) {
        
    }
    
    /// 手势中途结束时，调用
    func resetContentViewLayout() {
        
    }
    
    //MARK:- UIGestureRecognizerDelegate
    
    //MARK:- 刷新视图
    @objc func reloadData() {
        
        if self.reloadDataMustCondition == false {
            return
        }
        self.totalForCellsNumber    = self.dataSource!.totalNumberWithBrowseContent(self)
        self.setupContentView()
        self.currentScrollContentOffset = CGPoint.zero
        self.deviceOrientationFlag      = UIApplication.cg_currentDeviceDirection()
    }
    
    fileprivate func setReloadData() {
        
        if self.isAutoReloadDataCondition {
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reloadData), object: nil)
            self.perform(#selector(reloadData), with: nil, afterDelay: 0)
        }
    }
    
    /// 设置 contentView 中的视图
    func setupContentView() {
        
        var index                   = self.currentStartIndex
        var contentSize             = CGSize.zero
        let interitemSpacing        = self.minimumInteritemSpacing
        var tempVisibleBrowseCells  = [Int : CGBrowseViewCell]()
        
        repeat {
            
            let cell = self.createCell(cellIndex: index)
            
            if self.browseViewDirection == .Horizontal {
                
                cell.origin         = CGPoint.init(x: contentSize.width, y: 0)
                contentSize.width   += cell.width + interitemSpacing
            }else if self.browseViewDirection == .Vertical {
                
                cell.origin         = CGPoint.init(x: 0, y: contentSize.height)
                contentSize.height  += cell.height + interitemSpacing
            }
            
            if cell.superview != self.contentView {
                self.contentView.addSubview(cell)
            }
            tempVisibleBrowseCells.updateValue(cell, forKey: index)
            self.visibleBrowseCells.removeValue(forKey: index)
            
            let nextIndex = index.number(in: .next, isCycle: isScrollLoop, minNumber: 0, maxNumber: totalForCellsNumber)
            
            if nextIndex == nil {
                break
            }
            index   = nextIndex!
            
        } while (self.browseViewDirection == .Horizontal && contentSize.width < self.contentView.width) || (self.browseViewDirection == .Vertical && contentSize.height < self.contentView.height)
        
        for (_, value) in self.visibleBrowseCells {
            if value.superview != nil {
                value.removeFromSuperview()
            }
        }
        self.visibleBrowseCells.removeAll()
        self.visibleBrowseCells = tempVisibleBrowseCells
        
        if self.browseViewDirection == .Horizontal {
            contentSize.height  = self.contentView.height
        }else if self.browseViewDirection == .Vertical {
            contentSize.width   = self.contentView.width
        }
        
        self.visibleBrowseContentSize   = contentSize
    }
    
    func createCell(cellIndex : Int) -> CGBrowseViewCell {
        
        var view = visibleBrowseCells[cellIndex]
        if view == nil {
            
            view    = self.dataSource!.browseContent(self, index: cellIndex)
            visibleBrowseCells[cellIndex]   = view
            visibleBrowseCellIndexs.append(cellIndex)
        }
        var viewSize = CGSize.zero
        if self.browseViewDirection == .Horizontal {
            
            var width = self.delegate?.browseContent?(self, widthForAt: cellIndex)
            if width == nil {
                width   = self.cellWidth
            }
            viewSize.width  = width!
            viewSize.height = self.contentView.height
        }else if self.browseViewDirection == .Vertical {
            
            var height  = self.delegate?.browseContent?(self, heightForAt: cellIndex)
            if height == nil {
                height = self.cellHeight
            }
            viewSize.width  = self.contentView.width
            viewSize.height = height!
        }
        
        view?.size = viewSize
        return view!
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        if self.disableSetupPrivateCellWidthFlag == false {
            autoSetupCellWidthFlag  = true
            self.cellWidth  = self.contentView.width
        }
        if self.disableSetupPrivateCellHeightFlag {
            autoSetupCellHeightFlag = true
            self.cellHeight = self.contentView.height
        }
        
        self.setReloadData()
    }
}


