//
//  CGNumberExtension.swift
//  TestCG_CGKit
//
//  Created by DY on 2016/12/22.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation

enum CGNumberOfIntType : Int {
    case previous = -1
    case defalut  = 0
    case next     = 1
}

extension Int {
    
    /// 获取当前数字相邻的数字
    ///
    /// - Parameters:
    ///   - type: 相邻数字的类型
    ///   - isCycle: 是否可以循环，当为YES时最小值的数字上一个数字为最大值
    ///   - minNumber: 数字最大值
    ///   - maxNumber: 数字最小值
    /// - Returns: 返回结果数字，可为空
    func number(in type: CGNumberOfIntType, isCycle: Bool, minNumber: Int, maxNumber: Int) -> Int? {
        assert(minNumber <= maxNumber && self >= minNumber && self <= maxNumber, "minNumber 必须小于或等于 maxNumber 且 self 必须大于或等于minNumber 且 self 必须小于或等于 maxNumber")
        
        var resultInt: Int?
        
        switch type {
        case .previous:
            if self > minNumber {
                resultInt   = self - 1
            }else if isCycle {
                resultInt   = maxNumber
            }
        case .defalut:
            resultInt   = self
        case .next:
            if self < maxNumber {
                resultInt   = self + 1
            }else if isCycle {
                resultInt   = minNumber
            }
        }
        
        return resultInt
    }
    
    /// 获取当前数字相邻的数字(不支持循环)
    func number(type: CGNumberOfIntType, minNumber: Int, maxNumber: Int) -> Int? {
        return self.number(in: type, isCycle: false, minNumber: minNumber, maxNumber: maxNumber)
    }
    
    /// 获取当前数字相邻的数字(不支持循环，最小值默认为 0)
    func number(type: CGNumberOfIntType, maxNumber: Int) -> Int? {
        return self.number(type: type, minNumber: 0, maxNumber: maxNumber)
    }
    
    /// 获取当前数字相邻的数字(支持循环)
    func numberSupportCycle(type: CGNumberOfIntType, minNumber: Int, maxNumber: Int) -> Int? {
        return self.number(in: type, isCycle: true, minNumber: minNumber, maxNumber: maxNumber)
    }
    
    /// 获取当前数字相邻的数字(支持循环，最小值默认为 0)
    func numberSupportCycle(type: CGNumberOfIntType, maxNumber: Int) -> Int? {
        return self.numberSupportCycle(type: type, minNumber: 0, maxNumber: maxNumber)
    }
}
