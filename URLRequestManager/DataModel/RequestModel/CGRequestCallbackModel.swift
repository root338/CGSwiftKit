//
//  CGRequestCallbackModel.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/5/25.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

/// 数据请求回调对象
struct CGRequestCallbackModel {
    
    let identifier : String?
    let task : URLSessionTask
    
    let successBlock : CGRequestSuccessBlock?
    let failureBlock : CGRequestFailureBlock?
    let completionBlock : CGRequestCompletion?
}
