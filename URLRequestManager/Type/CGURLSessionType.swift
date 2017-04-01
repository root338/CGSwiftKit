//
//  CGURLSessionType.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/31.
//  Copyright © 2017年 apple. All rights reserved.
//

import Foundation

typealias CGURLSessionSuccessBlock      = (_ taskDataModel: CGTaskDataModel) -> Void
typealias CGURLSessionFailureBlock      = CGURLSessionSuccessBlock
typealias CGURLSessionCompletionBlock   = CGURLSessionSuccessBlock


/// 创建 URLSessionTask 的类型
///
/// - data: 创建 URLSessionDataTask 类型
/// - upload: 创建 URLSessionUploadTask 类型
/// - download: 创建 URLSessionDownloadTask 类型
/// - stream: 创建 URLSessionStreamTask 类型
enum CGURLSessionTaskType : Int {
    
    case data
    case upload
    case download
    
    case stream
}


/// URLSession 的请求类型
///
/// - GET: get 请求
/// - POST: post 请求
enum CGURLRequestMethod : Int {
    case GET
    case POST
}


/// GET 请求参数的处理方式
///
/// - `default`: 默认的处理方式，参数添加到URL query部分
/// - linkPath : 参数添加到 URL path部分
enum CGGETRequestParamterHandleType {
    case `default`
    case linkPath
}


/// POST 请求参数的处理方式
///
/// - `default`: 默认的处理方式
enum CGPOSTRequestParamterHandleType {
    case `default`
}
