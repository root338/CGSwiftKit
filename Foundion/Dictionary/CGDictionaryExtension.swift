//
//  CGDictionaryExtension.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/31.
//  Copyright © 2017年 apple. All rights reserved.
//

import Foundation

extension Dictionary /* where Key == String, Value == String */ {

    
    /// 拼接字典中的对象
    ///
    /// - Parameters:
    ///   - separator: 字典对象之间的分隔器
    ///   - keyValueSeparator: key, value 之间的分隔器
    /// - Returns: 返回字符串
    func componentsJoined(by separator: String, keyValueSeparator: String) -> String {
        
        var returnValue = String.init()
        
        for (index, object) in self.enumerated() {
            
            returnValue.append(String(describing: object.key))
            returnValue.append(keyValueSeparator)
            returnValue.append(String.init(describing: object.value))
            
            if index < self.count - 1 {
                returnValue.append(separator)
            }
        }
        
        return returnValue
    }
    
    func componentsJoined(by separator: String) -> String {
        return self.componentsJoined(by: separator, keyValueSeparator: separator)
    }
}
