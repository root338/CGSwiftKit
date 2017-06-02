//
//  CGURLSessionTaskDelegate.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/5/25.
//  Copyright © 2017年 apple. All rights reserved.
//

import Foundation

@objc protocol CGURLSessionTaskDelegate : NSObjectProtocol {
    
    /// 设置请求的唯一标识符
    /// 对于重复请求进行处理的标识
    ///
    /// - Parameter task: 创建的请求task
    /// - Returns: 返回请求标识符
    @objc optional func requestIdentifier(task: URLSessionTask) -> String?
    
    /// 获取相同标识符的请求task列表
    ///
    /// - Parameter requestIdentifier: 请求的标识符
    /// - Returns: 返回请求task列表
    @objc optional func taskList(requestIdentifier: String) -> [URLSessionTask]?
    
}
