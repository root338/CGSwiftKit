//
//  CGPointExtension.swift
//  TestCG_CGKit
//
//  Created by DY on 2016/12/22.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation

public extension CGPoint {
    
    public func offset(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint.init(x: self.x + x, y: self.y + y)
    }
    
    public func offset(x: Int, y: Int) -> CGPoint {
        return self.offset(x: CGFloat(x), y: CGFloat(y))
    }
    
    public func offset(x: Double, y: Double) -> CGPoint {
        return self.offset(x: CGFloat(x), y: CGFloat(y))
    }
    
    public func offset(point: CGPoint) -> CGPoint {
        return self.offset(x: point.x, y: point.y)
    }
    
    /// 减去point的坐标值
    public func offsetLess(point: CGPoint) -> CGPoint {
        return self.offset(x: -point.x, y: -point.y)
    }
    
    //MARK:- 设置自身属性值
    public mutating func setupOffset(x: CGFloat, y: CGFloat) {
        self = self.offset(x: x, y: y)
    }
    
    public mutating func setupOffset(point: CGPoint) {
        self = self.offset(point: point)
    }
    
    public mutating func setupOffsetLess(point: CGPoint) {
        self = self.offsetLess(point: point)
    }
}
