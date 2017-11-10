//
//  CGStringExtension.swift
//  TestCG_CGKit
//
//  Created by DY on 2016/12/26.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation

public extension String {
    
    public static func string(from number: Double) -> String {
        return ""
    }
    
    /// 移除字符串最后所有的斜线(/)
    func removeLastAllSlash() -> String {
        
        var returnValue = self
        
        if returnValue.hasSuffix("/") {
            returnValue.remove(at: returnValue.index(returnValue.endIndex, offsetBy: -1))
            return returnValue.removeLastAllSlash()
        }else {
            return returnValue
        }
    }
}
