//
//  CGFoulLineView.swift
//  TestCG_CGKit
//
//  Created by apple on 16/4/27.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import Foundation

enum CGFoulLineSType : Int {
    
    case Top, Left, Right, Bottom
};

struct CGFoulLineType : OptionSet {
    
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    
    static let None     = CGFoulLineType(rawValue: 1 << 0)
    static let Top      = CGFoulLineType(rawValue: 1 << 1)
    static let Left     = CGFoulLineType(rawValue: 1 << 2)
    static let Bottom   = CGFoulLineType(rawValue: 1 << 3)
    static let Right    = CGFoulLineType(rawValue: 1 << 4)
    
    static let EdgeInsetsExcludeTop     :   CGFoulLineType  = [Left, Bottom, Right]
    static let EdgeInsetsExcludeLeft    :   CGFoulLineType  = [Top, Bottom, Right]
    static let EdgeInsetsExcludeBottom  :   CGFoulLineType  = [Top, Left, Right]
    static let EdgeInsetsExcludeRight   :   CGFoulLineType  = [Top, Left, Bottom]
    
    static let All  : CGFoulLineType    = [Top, Left, Bottom, Right]
}

class CGFoulLineView : UIView {
    
    var foulLineType : CGFoulLineType {
        didSet {
            
//            self.updateFoulLineType = self.foulLineType.exclusiveOr(oldValue)
            if self.foulLineType != oldValue {
                self.setUpdateView()
            }
        }
    }
    ///更新的边值属性
//    private var updateFoulLineType  = CGFoulLineType.None
    
    var foulLineColor   : UIColor? {
        
        didSet {
            if self.foulLineColor != oldValue {
                self.setUpdateView()
            }
        }
    }
//    var foulLineEdgeInsets   : UIEdgeInsets {
//        
//        didSet {
//            if self.foulLineEdgeInsets != oldValue {
//                self.setUpdateView()
//            }
//        }
//    }
    
    var lineHeight              : CGFloat
    let contentView             : UIView
    private var lineViews       : Dictionary<CGFoulLineSType, UIView>?
    
    override init(frame: CGRect) {
        
        foulLineType        = .None
        lineHeight          = 1 / max(UIScreen.main.scale, 1)
//        foulLineEdgeInsets  = UIEdgeInsetsZero
        contentView         = UIView.init(frame: frame)
        super.init(frame: frame)
        
        self.addSubview(contentView)
        
    }
    
    convenience init(frame: CGRect, foulLineType: CGFoulLineType, lineHeight: CGFloat, lineColor: UIColor) {
        
        self.init(frame: frame)
        
        self.foulLineType   = foulLineType
        self.lineHeight     = lineHeight
        self.foulLineColor  = lineColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpdateView() {
        
        
        
        let foulLineTypeArray : [CGFoulLineSType] = [.Top, .Left, .Right, .Bottom]
        for lineType in foulLineTypeArray {
            
            var isAddLineView : Bool
            
            if self.foulLineType.contains(.None) {
                isAddLineView   = false
            }else {
                
                var foulLineType : CGFoulLineType
                switch lineType {
                case .Top:
                    foulLineType    = .Top
                case .Left:
                    foulLineType    = .Left
                case .Bottom:
                    foulLineType    = .Bottom
                case .Right:
                    foulLineType    = .Right
                }
                
                isAddLineView   = self.foulLineType.contains(foulLineType)
            }
            self.setupFoulLineView(foulLineType: lineType, isAddLineView: isAddLineView)
        }
        self.setupFoulLineViewLayout()
    }
    
    func setupFoulLineViewLayout() {
        
        var contentEdgeInsets   = UIEdgeInsets.zero
        let width               = self.bounds.size.width
        let height              = self.bounds.size.height
        let lineHeight          = self.lineHeight
        if self.foulLineType.contains(.None) == false && self.lineViews != nil {
            
            for (key, lineView) in self.lineViews! {
                
                if lineView.superview != nil {
                    
                    var frame : CGRect
                    switch key {
                    case .Top:
                        
                        contentEdgeInsets.top       = lineHeight
                        frame   = CGRect(x: 0, y: 0, width: width, height: lineHeight)
                    case .Left:
                        
                        contentEdgeInsets.left      = lineHeight
                        frame   = CGRect(x: 0, y: 0, width: lineHeight, height: height)
                    case .Bottom:
                        
                        contentEdgeInsets.bottom    = lineHeight
                        frame   = CGRect(x: 0, y: height - lineHeight, width: width, height: lineHeight)
                    case .Right:
                        
                        contentEdgeInsets.right     = lineHeight
                        frame   = CGRect(x: width - lineHeight, y: 0, width: lineHeight, height: height)
                    }
                    lineView.frame  = frame
                }
            }
        }
        
        let originX     = contentEdgeInsets.left
        let originY     = contentEdgeInsets.top
        let sizeWidth   = width - (contentEdgeInsets.left + contentEdgeInsets.right)
        let sizeHeight  = height - (contentEdgeInsets.top + contentEdgeInsets.bottom)
        self.contentView.frame  = CGRect(x: originX, y: originY, width: sizeWidth, height: sizeHeight);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupFoulLineViewLayout()
    }
    
    /**
     设置线视图
     
     - parameter foulLineType:  线视图的类型
     - parameter isAddLineView: 是否添加该线视图
     */
    final func setupFoulLineView(foulLineType: CGFoulLineSType, isAddLineView: Bool) {
        
        var targetView : UIView?
        if self.lineViews != nil {
            targetView  = self.lineViews![foulLineType]
        }
        
        if isAddLineView {
            
            if targetView == nil {
                
                if self.lineViews == nil {
                    self.lineViews  = Dictionary()
                }
                targetView  = self.createLineView()
                self.lineViews![foulLineType]    = targetView
            }
            if targetView?.superview == nil {
                self.addSubview(targetView!);
            }
            
        }else {
            
            if targetView?.superview != nil {
                targetView?.removeFromSuperview()
            }
        }
        
    }
    
    //创建线视图
    func createLineView() -> UIView {
        
        let frame   = CGRect(x: 0, y: 0, width: 0, height: self.lineHeight)
        let view    = UIView(frame: frame)
        view.backgroundColor    = self.foulLineColor
        return view
    }
}
