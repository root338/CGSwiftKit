//
//  CGBrowseFullScreenView.swift
//  TestCG_CGKit
//
//  Created by DY on 2016/12/22.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

typealias CGBrowseFullScreenViewTuple = (index: Int, cell: CGBrowseFullScreenViewCell)
private typealias CGBrowseFullScreenViewAideTuple   = (index: Int, cell: CGBrowseFullScreenViewCell, type: CGNumberOfIntType)

@objc protocol CGBrowseFullScreenViewDelegate : NSObjectProtocol {
    
    func browseFullScreenView(_ browseFullScreenView: CGBrowseFullScreenView, index: Int) -> CGBrowseFullScreenViewCell
    func numberForFullScreenCells(in browseFullScreenView: CGBrowseFullScreenView) -> Int
    
}

class CGBrowseFullScreenView: UIView, UIGestureRecognizerDelegate {

    weak var delegate : CGBrowseFullScreenViewDelegate?
    
    var currentIndex        = 0
    
    /// cell 之间的间距
    var interitemSpacing    = CGFloat(0.0)
    
    /// 是否支持滑动循环
    var isScrollLoop        = false
    
    //MARK:- 私有实例属性
    /// 缓存的 cell 数组
    fileprivate var cacheBrowseImageViewCellArray   = [Int : CGBrowseFullScreenViewCell]()
    /// 可见的 cell
    fileprivate var visiableBrowseImageViewCellTuple : CGBrowseFullScreenViewTuple? {
        willSet {
            if visiableBrowseImageViewCellTuple?.cell != newValue?.cell || visiableBrowseImageViewCellTuple?.index != newValue?.index {
                
                visiableBrowseImageViewCellTuple?.cell.removeFromSuperview()
            }
        }
        
        didSet {
            if visiableBrowseImageViewCellTuple != nil && visiableBrowseImageViewCellTuple!.cell.superview == nil {
                self.addSubview(visiableBrowseImageViewCellTuple!.cell);
            }
        }
    }
    /// 复制滑动的 cell
    fileprivate var aideBrowseImageViewCellTuple : CGBrowseFullScreenViewAideTuple? {
        
        willSet {
            if aideBrowseImageViewCellTuple?.cell != newValue?.cell || aideBrowseImageViewCellTuple?.index != newValue?.index {
                
                aideBrowseImageViewCellTuple?.cell.removeFromSuperview()
            }
        }
        
        didSet {
            
            if aideBrowseImageViewCellTuple != nil && aideBrowseImageViewCellTuple!.cell.superview == nil {
                
                self.addSubview(aideBrowseImageViewCellTuple!.cell)
            }
        }
    }
    /// cell 总数
    fileprivate var totalCellsNumber    = 0
    
    fileprivate var updateCellForBoundsSize : CGSize?
    
    private let panGestureRecognizer : UIPanGestureRecognizer
    
    override init(frame: CGRect) {
        
        panGestureRecognizer    = UIPanGestureRecognizer.init()
        super.init(frame: frame)
        
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGestureRecognizer(_ :)))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handlePanGestureRecognizer(_ pan : UIPanGestureRecognizer) {
        
        let state   = pan.state
        let contentOffset   = pan.translation(in: self)
        
        if state == .began {
            
        }else if state == .changed {
            
            self.setupVisiableFullScreenCell(contentOffset: contentOffset)
        }else if state == .ended {
            
            self.scrollFullScreenCells(velocity: pan.velocity(in: self).x)
        }else if state == .cancelled || state == .failed {
            
            self.reloadData()
        }
        
        pan.setTranslation(.zero, in: self)
    }
    
    /// 设置可见 cell 的偏移量
    func setupVisiableFullScreenCell(contentOffset: CGPoint) {
        
        if visiableBrowseImageViewCellTuple == nil {
            return
        }
        
        let visiableCell    = visiableBrowseImageViewCellTuple!.cell
        
        visiableCell.origin.setupOffset(x: contentOffset.x, y: 0)
        
        var intType : CGNumberOfIntType?
        
        let x       = visiableCell.xOrigin
        let maxX    = visiableCell.maxX
        
        if x > interitemSpacing {
            intType = .previous
        }else if maxX < self.width - interitemSpacing {
            intType = .next
        }
        
        if intType != nil {
            
            aideBrowseImageViewCellTuple    = self.setupAideCell(currentCellTuple: visiableBrowseImageViewCellTuple!, type: intType!, contentOffset: contentOffset)
            
            if aideBrowseImageViewCellTuple != nil {
                
                let cell    = aideBrowseImageViewCellTuple!.cell
                let index   = aideBrowseImageViewCellTuple!.index
                let type    = aideBrowseImageViewCellTuple!.type
                if  (type == .previous && cell.xOrigin >= CGZeroFloatValue) || (type == .next && cell.xOrigin <= CGZeroFloatValue) {
                    //判断辅助 cell 是否应该刷新
                    self.currentIndex   = index;
                    self.reloadData()
                }
            }
        }else {
            
            aideBrowseImageViewCellTuple    = nil
        }
    }
    
    /// 设置辅助cell
    fileprivate func setupAideCell(currentCellTuple: CGBrowseFullScreenViewTuple, type: CGNumberOfIntType, contentOffset: CGPoint) -> CGBrowseFullScreenViewAideTuple? {
        
        let targetIndex = currentCellTuple.index.number(in: type, isCycle: isScrollLoop, minNumber: 0, maxNumber: totalCellsNumber)
        if targetIndex == nil {
            return nil
        }
        
        var cellTuple : CGBrowseFullScreenViewAideTuple?
        if aideBrowseImageViewCellTuple != nil {
            if aideBrowseImageViewCellTuple!.index == targetIndex! {
                cellTuple   = aideBrowseImageViewCellTuple
                cellTuple?.cell.origin.setupOffset(x: contentOffset.x, y: 0)
            }
        }
        
        if cellTuple == nil {
            let cell = self.browseImageViewCellGet(in: targetIndex!)
            
            if cell != nil {
                
                let currentCell = currentCellTuple.cell
                
                var origin : CGPoint?
                switch type {
                case .previous:
                    origin  = CGPoint.init(x: currentCell.xOrigin - interitemSpacing - currentCell.width, y: 0)
                default:
                    origin  = CGPoint.init(x: currentCell.xOrigin + interitemSpacing + currentCell.width, y: 0)
                }
                cell!.frame = CGRect.init(origin: origin!, size: self.size)
                
                cellTuple = (targetIndex!, cell!, type)
            }
        }
        
        return cellTuple
    }
    
    /// 验证辅助cell 是否可以替换当前cell
//    func verifyAideCellReplaceCurrentCell() -> Bool {
//        
//        if visiableBrowseImageViewCellTuple == nil || aideBrowseImageViewCellTuple == nil {
//            return false
//        }
//        
//        
//    }
    
    /// 手势结束时的 cells 处理
    func scrollFullScreenCells(velocity: CGFloat) {
        
        var visiableCellScrollOffset : CGFloat  = 0.0
        var didReloadIndex                      = self.currentIndex
        
        if aideBrowseImageViewCellTuple != nil {
            
            let cellWidth : CGFloat = aideBrowseImageViewCellTuple!.cell.width
            switch self.aideBrowseImageViewCellTuple!.type {
            case .next:
                visiableCellScrollOffset    = -(interitemSpacing + cellWidth)
            case .previous:
                visiableCellScrollOffset    = (interitemSpacing + cellWidth)
            default:
                visiableCellScrollOffset    = 0.0
            }
            didReloadIndex                  = self.aideBrowseImageViewCellTuple!.index
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.visiableBrowseImageViewCellTuple?.cell.xOrigin = visiableCellScrollOffset
            self.aideBrowseImageViewCellTuple?.cell.xOrigin     = 0
        }, completion: { finished in
            
            self.currentIndex   = didReloadIndex
            self.reloadData()
        })
    }
    
    func reloadData() {
        
        if let total = delegate?.numberForFullScreenCells(in: self) {
            totalCellsNumber    = total
        }
        
        let cell = self.browseImageViewCellGet(in: currentIndex)
        
        if cell != nil {
            cell!.frame = self.bounds
            visiableBrowseImageViewCellTuple = (currentIndex, cell!)
        }else {
            visiableBrowseImageViewCellTuple = nil
        }
        aideBrowseImageViewCellTuple    = nil
    }
    
    /// 获取指定索引的 cell
    func browseImageViewCellGet(in Index: Int) -> CGBrowseFullScreenViewCell? {
        
        var cell    = cacheBrowseImageViewCellArray[Index]
        if cell == nil || cell!.superview != nil {
            cell    = delegate?.browseFullScreenView(self, index: Index)
        }
        return cell
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if visiableBrowseImageViewCellTuple != nil {
            let cell = visiableBrowseImageViewCellTuple!.cell
            if cell.size != self.size {
                visiableBrowseImageViewCellTuple?.cell.frame  = self.bounds
            }
        }
    }
    
    //MARK:- UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if visiableBrowseImageViewCellTuple == nil {
            return false
        }
        
        
        return true
    }
}

extension CGBrowseFullScreenView {
    
    convenience init(frame: CGRect, delegate: CGBrowseFullScreenViewDelegate) {
        
        self.init(frame: frame)
        
        self.delegate   = delegate
    }
}
