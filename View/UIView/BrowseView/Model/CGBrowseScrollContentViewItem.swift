//
//  CGBrowseScrollContentViewItem.swift
//  TestCG_CGKit
//
//  Created by apple on 2017/12/27.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

enum CGBrowseItemPushOperateType {
    
    case first
    case last
}

enum CGBrowseItemPopOperateType {
    
    case first
    case last
}

protocol CGBrowseScrollContentViewItemProtocol : NSObjectProtocol {
    
    func didPush(browseCellItem: CGBrowseCellItem, pushType: CGBrowseItemPushOperateType, firstEndPoint: CGPoint?, lastStartPoint: CGPoint?)
    func didPop(browseCellItem: CGBrowseCellItem, popType: CGBrowseItemPopOperateType)
}

class CGBrowseScrollContentViewItem: NSObject {

    /// 是否循环
    var isScrollLoop    = false
    
    /// 开始索引
    var startIndex : CGBrowseCellIdentifierID? {
        return visibleBrowseCellItems.first?.identifierID
    }
    
    /// 结束索引
    var endIndex : CGBrowseCellIdentifierID? {
        return visibleBrowseCellItems.last?.identifierID
    }
    /// 滑动方向
    var scrollDirection : CGBrowseScrollDirection
    
    /// 当前可见的 cells
    fileprivate var visibleBrowseCellItems = [CGBrowseCellItem]()
    
    /// cells 显示的区域
    var visibleRect = CGRect.zero
    
    weak var delegate : CGBrowseScrollContentViewItemProtocol?
    
    init(scrollDirection: CGBrowseScrollDirection) {
        self.scrollDirection    = scrollDirection
        super.init()
    }
}

// MARK: - 值获取
extension CGBrowseScrollContentViewItem {
    /// 获取相邻的上一个cell
    func previousCellItem(cellItem: CGBrowseCellItem) -> CGBrowseCellItem? {
        
        return self.targetCellItem(cellItem: cellItem, offset: -1)
    }
    /// 获取相邻的下一个cell
    func nextCellItem(cellItem: CGBrowseCellItem) -> CGBrowseCellItem? {
        
        return self.targetCellItem(cellItem: cellItem, offset: 1)
    }
    
    func targetCellItem(cellItem: CGBrowseCellItem, offset: Int) -> CGBrowseCellItem? {
        
        if let index = visibleBrowseCellItems.index(of: cellItem), index + offset >= 0, index + offset < visibleBrowseCellItems.count {
            return visibleBrowseCellItems[index + offset]
        }
        return nil
    }
}

// MARK: - 条件判断
extension CGBrowseScrollContentViewItem {
    
    /// 是否应该弹出第一个 cell
    func shouldPopFirstCell(visibleRect: CGRect) -> Bool? {
        
        return self.shouldPop(type: .first, cellItem: visibleBrowseCellItems.first, visibleRect: visibleRect)
    }
    /// 是否应该弹出最后一个 cell
    func shouldPopLastCell(visibleRect: CGRect) -> Bool? {
        
        return self.shouldPop(type: .last, cellItem: visibleBrowseCellItems.last, visibleRect: visibleRect)
    }
    /// 是否应该加载一个新 cell 到第一的位置
    func shouldPushFirstCell(visibleRect: CGRect, space: CGFloat) -> Bool {
        
        return self.shouldPush(type: .first, cellItem: visibleBrowseCellItems.first, visibleRect: visibleRect, space: space)
    }
    /// 是否应该加载一个新 cell 到最后的位置
    func shouldPushLastCell(visibleRect: CGRect, space: CGFloat) -> Bool {
        return self.shouldPush(type: .last, cellItem: visibleBrowseCellItems.last, visibleRect: visibleRect, space: space)
    }
    
    private func shouldPop(type: CGBrowseItemPopOperateType, cellItem: CGBrowseCellItem?, visibleRect: CGRect) -> Bool? {
        
        var isShouldPop : Bool?
        if cellItem != nil, let cellRect = cellItem!.cellRect {
            switch self.scrollDirection {
            case .horizontal:
                
                if (cellRect.maxX < visibleRect.minX && type == .first) || (cellRect.minX > visibleRect.maxX && type == .last) {
                    isShouldPop = true
                }
            case .vertical:
                if (cellRect.maxY < visibleRect.minY && type == .first) || (cellRect.minY > visibleRect.maxY && type == .last) {
                    isShouldPop = true
                }
            }
        }
        return isShouldPop
    }
    
    private func shouldPush(type: CGBrowseItemPushOperateType, cellItem: CGBrowseCellItem?, visibleRect: CGRect, space: CGFloat) -> Bool {
        
        var isShouldPush    = false
        
        if cellItem != nil, let cellRect = cellItem!.cellRect {
            
            switch self.scrollDirection {
            case .horizontal:
                if (cellRect.minX - space > visibleRect.minX && type == .first) || (cellRect.maxX + space < visibleRect.maxX && type == .last) {
                    isShouldPush    = true
                }
            case .vertical:
                if (cellRect.minY - space > visibleRect.minY && type == .first) || (cellRect.maxY + space < visibleRect.maxY && type == .last) {
                    isShouldPush    = true
                }
            }
        }else {
            if cellItem == nil {
                isShouldPush    = true
            }
        }
        
        
        
        return isShouldPush
    }
}

// MARK: - 视图操作
extension CGBrowseScrollContentViewItem {
    
    /// 弹出第一个 cell
    func popFirstCell() -> CGBrowseCellItem? {
        
        let firstCellItem   = visibleBrowseCellItems.removeFirst()
        
        self.delegate?.didPop(browseCellItem: firstCellItem, popType: .first)
        self.setupVisibleRect()
        
        return firstCellItem
    }
    
    /// 弹出最后一个 cell
    func popLastCell() -> CGBrowseCellItem? {
        
        let lastCellItem    = visibleBrowseCellItems.removeLast()
        self.delegate?.didPop(browseCellItem: lastCellItem, popType: .last)
        self.setupVisibleRect()
        return lastCellItem
    }
    
    /// 加载的cell放在最后一个位置
    func pushFirstCell(cellItem: CGBrowseCellItem) {
        
        self.visibleBrowseCellItems.insert(cellItem, at: 0)
        
        var endPoint : CGPoint?
        if visibleBrowseCellItems.count > 1, let oldFirstCellRect = visibleBrowseCellItems[1].cellRect {
            
            var point   = CGPoint.zero
            switch scrollDirection {
            case .horizontal:
                point.x = oldFirstCellRect.minX
            case .vertical:
                point.y = oldFirstCellRect.minY
            }
            endPoint    = point
        }
        self.delegate?.didPush(browseCellItem: cellItem, pushType: .first, firstEndPoint: endPoint, lastStartPoint: nil)
        
        self.setupVisibleRect()
    }
    
    /// 加载的cell放在第一个位置
    func pushLastCell(cellItem: CGBrowseCellItem) {
        
        self.visibleBrowseCellItems.append(cellItem)
        
        let count   = visibleBrowseCellItems.count
        var startPoint : CGPoint?
        if count > 1, let oldLastCellRect = visibleBrowseCellItems[count - 2].cellRect  {
            
            var point   = CGPoint.zero
            switch scrollDirection {
            case .horizontal:
                point.x = oldLastCellRect.maxX
            case .vertical:
                point.y = oldLastCellRect.maxY
            }
            startPoint  = point
        }
        
        self.delegate?.didPush(browseCellItem: cellItem, pushType: .last, firstEndPoint: nil, lastStartPoint: startPoint)
        
        self.setupVisibleRect()
    }
    
    func createFirstCellItem(isRunLoop: Bool, totalCount: Int, space: CGFloat) -> CGBrowseCellItem? {
        
        return self.createCellItem(visibleBrowseCellItems.first, type: .previous, isRunLoop: isRunLoop, totalCount: totalCount, space: space)
    }
    
    func createLastCellItem(isRunLoop: Bool, totalCount: Int, space: CGFloat) -> CGBrowseCellItem? {
        
        return self.createCellItem(visibleBrowseCellItems.last, type: .next, isRunLoop: isRunLoop, totalCount: totalCount, space: space)
    }
    
    private func createCellItem(_ oldItem: CGBrowseCellItem?, type: CGIntAdjacentNumberType, isRunLoop: Bool, totalCount: Int, space: CGFloat) -> CGBrowseCellItem? {
        
        var index   = oldItem?.identifierID.index.number(in: type, isCycle: isRunLoop, minNumber: 0, maxNumber: totalCount - 1)
        var level : Int?
        var cellItem : CGBrowseCellItem?
        
        if index != nil {
            
            if index! == oldItem!.identifierID.index {
                /// 判断有问题，有待更改
                assert(false, "判断有问题，有待更改")
//                level = oldItem!.identifierID.level + 1
            }else {
                level   = 0
            }
            
        }else {
            
            if totalCount > 0 && visibleBrowseCellItems.count == 0 {
                index   = 0
                level   = 0
            }
        }
        
        if index != nil && level != nil {
            let cellIdentifierId = CGBrowseCellIdentifierID.init(index: index!, level: level!)
            cellItem    = CGBrowseCellItem.init(identifierID: cellIdentifierId)
            
            if type == .previous {
                cellItem?.spaceWithNextCellItem     = space
                oldItem?.spaceWithPreviousCellItem  = space
            }else if type == .next {
                cellItem?.spaceWithPreviousCellItem = space
                oldItem?.spaceWithNextCellItem      = space
            }
        }else {
            return nil
        }
        
        return cellItem
    }
    
}

extension CGBrowseScrollContentViewItem {
    
    fileprivate func setupVisibleRect() {
        
        var isResetVisibleRect  = true
        if let firstItem = visibleBrowseCellItems.first {
            
            if let firstCellOrigin = firstItem.cellRect?.origin {
                self.visibleRect.origin = firstCellOrigin
                isResetVisibleRect      = false
            }
        }
        if let lastItem = visibleBrowseCellItems.last {
            if let lastCellRect = lastItem.cellRect {
                self.visibleRect.size   = CGSize.init(width: lastCellRect.maxX, height: lastCellRect.maxY)
                isResetVisibleRect      = false
            }
        }
        
        if isResetVisibleRect {
            self.visibleRect    = CGRect.zero
        }
    }
    
    func contentOffset(_ contentOffset: CGPoint) {
        
        for cellItem in visibleBrowseCellItems {
            
            if let cellRect = cellItem.cellRect {
                cellItem.cellRect!.origin   = cellRect.origin.offset(x: contentOffset.x, y: contentOffset.y)
                cellItem.cell?.origin       = (cellItem.cellRect?.origin)!
            }
        }
        self.setupVisibleRect()
    }
}
