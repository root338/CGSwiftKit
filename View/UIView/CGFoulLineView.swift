//
//  CGFoulLineView.swift
//  TestCG_CGKit
//
//  Created by apple on 16/4/27.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import Foundation

//enum CGFoulLineType : Int {
//    
//    case None, Top, Left, Right, Bottom
//};

struct CGFoulLineType : OptionSetType {
    
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    
    static let None     = CGFoulLineType(rawValue: 0)
    static let Top      = CGFoulLineType(rawValue: 1)
    static let Left     = CGFoulLineType(rawValue: 2)
    static let Bottom   = CGFoulLineType(rawValue: 3)
    static let Right    = CGFoulLineType(rawValue: 4)
    
    static let EdgeInsetsExcludeTop     :   CGFoulLineType  = [Left, Bottom, Right]
    static let EdgeInsetsExcludeLeft    :   CGFoulLineType  = [Top, Bottom, Right]
    static let EdgeInsetsExcludeBottom  :   CGFoulLineType  = [Top, Left, Right]
    static let EdgeInsetsExcludeRight   :   CGFoulLineType  = [Top, Left, Bottom]
    
    static let All  : CGFoulLineType    = [Top, Left, Bottom, Right]
}

class CGFoulLineView : UIView {
    
    var foulLineType : CGFoulLineType {
        didSet {
            
            self.updateFoulLineType = self.foulLineType.exclusiveOr(oldValue)
            if self.foulLineType != oldValue {
                self.setUpdateView()
            }
        }
    }
    ///更新的边值属性
    private var updateFoulLineType  = CGFoulLineType.None
    
    var foulLineColor   : UIColor? {
        
        didSet {
            if self.foulLineColor != oldValue {
                self.setUpdateView()
            }
        }
    }
    var foulLineEdgeInsets   : UIEdgeInsets {
        
        didSet {
            if self.foulLineEdgeInsets != oldValue {
                self.setUpdateView()
            }
        }
    }
    let contentView             : UIView
    private var topLineView     : UIView?
    private var LeftLineView    : UIView?
    private var bottomLineView  : UIView?
    private var rightLineView   : UIView?
    
    override init(frame: CGRect) {
        
        foulLineType        = .None
        foulLineEdgeInsets  = UIEdgeInsetsZero
        contentView         = UIView.init(frame: frame)
        super.init(frame: frame)
        
        self.addSubview(contentView)
        
    }
    
    convenience init(frame: CGRect, foulLineType: CGFoulLineType) {
        
        self.init(frame: frame)
        self.foulLineType   = foulLineType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpdateView() {
        
        if self.updateFoulLineType.contains(.Top) {
            //当顶部更新时
            if self.foulLineType.contains(.Top) {
                //添加了顶部边线
                
            }
        }
    }
}