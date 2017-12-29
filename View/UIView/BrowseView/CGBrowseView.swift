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
    case horizontal, vertical
}


/// CGBrowseView 索引的类型
///
/// - PreviousIndex: 上一页索引
/// - CurrentIndex: 当前索引
/// - NextIndex: 下一页索引
public enum CGBrowseViewIndexType : Int {
    case previousIndex  = -1
    case currentIndex   = 0
    case nextIndex      = 1
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
    
//    /// 设置视图之间的间距是多少
//    @objc optional func browseContent(_ browseContent : CGBrowseView, index1: Int, level1: Int, index2: Int, level2: Int) -> CGFloat
    
}

/// 浏览视图
open class CGBrowseView: UIView, /*UIGestureRecognizerDelegate,*/ CGBrowseScrollContentViewItemProtocol {
    
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
    var interitemSpacing : CGFloat = 0
    
    /// 是否可以循环滑动，默认
    var isScrollLoop : Bool {
        didSet {
            scrollContentViewItem.isScrollLoop  = isScrollLoop
        }
    }
    
    /// 浏览视图滑动的方向，默认水平滑动
    var scrollDirection = CGBrowseScrollDirection.horizontal {
        didSet {
            scrollContentViewItem.scrollDirection   = scrollDirection
        }
    }
    
    /// 加载滑动视图的内容视图
    let contentView = UIView.init()
    
    
    //MARK:- 私有属性
    /// 滑动的手势
    private let pan : UIPanGestureRecognizer
    
    /// 记录上一次偏移的坐标
    fileprivate var offsetPoint    : CGPoint?
    
    /// 可见的 cell 数组
    fileprivate var visibleBrowseCells : [Int : CGBrowseCellItem] = [:]
    /// 可见的 cell 的内容大小
    fileprivate var visibleBrowseContentSize = CGSize.zero
    /// 可见的 cell 的内容坐标
    fileprivate var visibleBrowseContentRect = CGRect.zero
    
    /// 可见的 cell 索引数组
    fileprivate var visibleBrowseCellIndexs : [Int] = []
    /// 缓存的 cell 集合
    fileprivate var cacheBrowseCells : [String : [CGBrowseCellItem]] = [:]
    /// 当前手势滑动的偏移量
    fileprivate var contentOffset = CGPoint.zero
    
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
    
    /// 子视图滑动区域
    fileprivate var scrollContentViewItem : CGBrowseScrollContentViewItem
    
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
            if self.scrollDirection == .horizontal {
                
                visibleCellsContentSizeLessContentViewSize  = visibleBrowseContentSize.width < self.contentView.width
            } else if self.scrollDirection == .vertical {
                
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
        
        self.isScrollLoop   = false
        
        pan = UIPanGestureRecognizer.init()
        scrollContentViewItem   = CGBrowseScrollContentViewItem.init(scrollDirection: self.scrollDirection)
        scrollContentViewItem.isScrollLoop  = self.isScrollLoop
        
        super.init(frame: frame)
        
        self.clipsToBounds              = true
        scrollContentViewItem.delegate  = self
        
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
            
            var contentOffset = CGPoint.zero
            switch scrollDirection {
            case .horizontal:
                contentOffset.x = point.x - self.offsetPoint!.x
            case .vertical:
                contentOffset.y = point.y - self.offsetPoint!.y
            }
            self.moveContentViewLayout(contentOffset: contentOffset)
            self.offsetPoint   = point
        } else if state == .failed || state == .cancelled {
            
            self.resetContentViewLayout()
        } else if state == .ended {
//            self.endMoveContentViewLayout(contentOffset: , velocity: <#T##CGFloat#>)
        }
    }
    
    /// 手势移动时，调用
    func moveContentViewLayout(contentOffset: CGPoint) {
        
        
        self.contentOffset.x += contentOffset.x
        self.contentOffset.y += contentOffset.y
        
        scrollContentViewItem.contentOffset(contentOffset)
        self.setupBrowseViewCells()
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
        
        self.setupBrowseViewCells()
        
        self.deviceOrientationFlag      = UIApplication.cg_currentDeviceDirection()
    }
    
    fileprivate func setReloadData() {
        
        if self.isAutoReloadDataCondition {
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reloadData), object: nil)
            self.perform(#selector(reloadData), with: nil, afterDelay: 0)
        }
    }
    
    /// 计算当前可见区域可以显示的cell范围
    ///
    func setupBrowseViewCells() {
        
        let contentViewRect     = self.contentView.bounds
        
        if contentViewRect.contains(scrollContentViewItem.visibleRect) == false {
            
            // 清除容器空间不包含的cell
            while true {
                
                var isBreakRunLoop  = true
                if let shouldPopFirstCellItem = scrollContentViewItem.shouldPopFirstCell(visibleRect: contentViewRect) {
                    if shouldPopFirstCellItem {
                        _ = scrollContentViewItem.popFirstCell()
                        isBreakRunLoop  = false
                    }
                }
                
                if let shouldPopLastCellItem = scrollContentViewItem.shouldPopLastCell(visibleRect: contentViewRect) {
                    if shouldPopLastCellItem {
                        _ = scrollContentViewItem.popLastCell()
                        isBreakRunLoop  = false
                    }
                }
                
                if isBreakRunLoop {
                    break
                }
            }
        }
        
        if scrollContentViewItem.visibleRect.contains(contentViewRect) == false {
            
            // 当容器空间包含当前cell的可见空间时，加载需要填充的部分
            while true {
                
                var isBreakRunLoop  = true
                if  scrollContentViewItem.shouldPushFirstCell(visibleRect: contentViewRect, space: interitemSpacing) {
                    
                    if let cellItem = scrollContentViewItem.createFirstCellItem(isRunLoop: self.isScrollLoop, totalCount: self.totalForCellsNumber, space: interitemSpacing) {
                        
                        scrollContentViewItem.pushFirstCell(cellItem: cellItem)
                        isBreakRunLoop  = false
                    }
                    // 创建不了 item 说明设置的 索引不可用
                }
                
                if scrollContentViewItem.shouldPushLastCell(visibleRect: contentViewRect, space: interitemSpacing) {
                    
                    if let cellItem = scrollContentViewItem.createLastCellItem(isRunLoop: self.isScrollLoop, totalCount: self.totalForCellsNumber, space: interitemSpacing) {
                        
                        scrollContentViewItem.pushLastCell(cellItem: cellItem)
                        isBreakRunLoop  = false
                    }
                    
                    // 创建不了 item 说明设置的 索引不可用
                }
                
                if isBreakRunLoop {
                    break
                }
            }
        }
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        if self.disableSetupPrivateCellWidthFlag == false {
            autoSetupCellWidthFlag  = true
            self.cellWidth  = self.contentView.width
        }
        if self.disableSetupPrivateCellHeightFlag == false {
            autoSetupCellHeightFlag = true
            self.cellHeight = self.contentView.height
        }
        
        self.setReloadData()
    }
    
    //MARK:- CGBrowseScrollContentViewItemProtocol
    
    func didPush(browseCellItem: CGBrowseCellItem, pushType: CGBrowseItemPushOperateType, firstEndPoint: CGPoint?, lastStartPoint: CGPoint?) {
        
        var cellItemRect = CGRect.zero
        switch self.scrollDirection {
        case .horizontal:
            if let cellWidth = self.delegate?.browseContent?(self, widthForAt: browseCellItem.identifierID.index) {
                cellItemRect.size.width = cellWidth
            }else {
                cellItemRect.size.width = self.cellWidth
            }
            cellItemRect.size.height    = self.contentView.height
        case .vertical:
            
            if let cellHeight = self.delegate?.browseContent?(self, heightForAt: browseCellItem.identifierID.index) {
                cellItemRect.size.height    = cellHeight
            }else {
                cellItemRect.size.height    = self.cellHeight
            }
            cellItemRect.size.width         = self.contentView.width
        }
        
        switch pushType {
        case .first:
            
            if firstEndPoint != nil {
                switch scrollDirection {
                case .horizontal:
                    cellItemRect.origin.x   = firstEndPoint!.x - cellItemRect.width - (browseCellItem.spaceWithNextCellItem ?? 0)
                    
                case .vertical:
                    cellItemRect.origin.y   = firstEndPoint!.y - cellItemRect.height - (browseCellItem.spaceWithNextCellItem ?? 0)
                }
            }
            
        case .last:
            
            if lastStartPoint != nil {
                switch scrollDirection {
                case .horizontal:
                    cellItemRect.origin.x   = lastStartPoint!.x + (browseCellItem.spaceWithPreviousCellItem ?? 0)
                case .vertical:
                    cellItemRect.origin.y   = lastStartPoint!.y + (browseCellItem.spaceWithPreviousCellItem ?? 0)
                }
            }
        }
        
        browseCellItem.cellRect = cellItemRect
        
        if let cell = self.dataSource?.browseContent(self, index: browseCellItem.identifierID.index) {
            
            browseCellItem.cell = cell
            cell.frame          = browseCellItem.cellRect!
            self.contentView.addSubview(cell)
        }
    }
    
    func didPop(browseCellItem: CGBrowseCellItem, popType: CGBrowseItemPopOperateType) {
        
        browseCellItem.cell?.removeFromSuperview()
    }
}
