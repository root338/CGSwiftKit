//
//  CGTaskRequestDataModel.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/31.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

/// 上传时的数据类型
class CGUploadTaskRequestDataModel: CGTaskRequestDataModel {
    
    /// 上传时的图片
    var uploadImageList : Array<CGUploadImageModel>?
    
    convenience init(requestString: String, uploadImageList: Array<CGUploadImageModel>) {
        
        self.init(requestString: requestString)
        
        taskReqeustType         = .POST
        taskType                = .upload
        self.uploadImageList    = uploadImageList
    }
}

/// 请求时的数据模型
class CGTaskRequestDataModel: NSObject {
    
    /// 请求的标识
    var taskRequestIdentifier : String?
    
    /// request请求类型 默认GET
    var taskReqeustType = CGURLRequestMethod.GET
    
    /// 创建task的类型，默认 URLSessionDataTask
    var taskType        = CGURLSessionTaskType.data
    
    //---请求链接
    
    let requestString   : String
    
    var getHandleType   = CGGETRequestParamterHandleType.default
    var postHandleType  = CGPOSTRequestParamterHandleType.default
    
    var cachePolicy     = URLRequest.CachePolicy.returnCacheDataElseLoad
    var timeInterval    = TimeInterval.init(60)
    
    /// 请求参数
    var parameters : Dictionary<String, Any>?
    
    
    init(requestString : String) {
        
        self.requestString  = requestString
        
        super.init()
    }
}

extension CGTaskRequestDataModel {
    
    func getRequest(baseURL: URL?) -> URLRequest? {
        
        var request : URLRequest?
        
        var requestURLString : String
        
        requestURLString    = self.requestString.removeLastAllSlash()
        
        var parametersStr : String?
        if self.parameters != nil && self.taskType == .data {
            
            parametersStr   = self.handleDataTaskRequestParameters(self.parameters!)
        }
        
        if self.taskReqeustType == .GET && parametersStr != nil {
            requestURLString.append(parametersStr!)
        }
        
        var url : URL?
        if requestString.verificationIsHTTPPrefix() {
            
            url = URL.init(string: requestURLString)
        }else {
            
            url = URL.init(string: requestURLString, relativeTo: baseURL)
        }
        
        if url != nil {
            request = URLRequest.init(url: url!, cachePolicy: self.cachePolicy, timeoutInterval: self.timeInterval)
            if self.taskReqeustType == .POST && parametersStr != nil {
                
            }
        }
        
        return request
    }
    
    
    /// 处理 URLSessionDataTask 类型的数据字段
    ///
    /// - Parameter parameters: 需要传入的参数
    /// - Returns: 返回 GET, POST  下的参数数据格式
    private func handleDataTaskRequestParameters(_ parameters: Dictionary<String, Any>) -> String {
        
        /// GET 请求下的参数设置
        func handleGetRequestParameters(handleGETType: CGGETRequestParamterHandleType) -> String {
            
            let keyValueSeparator : String
            let separator : String
            switch handleGETType {
            case .default:
                keyValueSeparator   = "="
                separator           = "&"
            case .linkPath:
                keyValueSeparator   = "/"
                separator           = keyValueSeparator
            }
            
            let parametersString    = parameters.componentsJoined(by: separator, keyValueSeparator: keyValueSeparator)
            
            
            return parametersString
        }
        
        /// POST 请求下的参数设置
        func handlePOSTRequestParameters(handlePOSTType: CGPOSTRequestParamterHandleType) -> String {
            
            var parametersString : String
            switch handlePOSTType {
            case .default:
                parametersString    = handleGetRequestParameters(handleGETType: .default)
            }
            return parametersString
        }
        
        var parametersStr : String
        
        switch self.taskReqeustType {
        case .GET:
            
            parametersStr    = handleGetRequestParameters(handleGETType: self.getHandleType)
            if parametersStr.isEmpty == false {
                
                let parametersPrefixStr : Character
                switch self.getHandleType {
                case .default:
                    parametersPrefixStr = "?"
                case .linkPath:
                    parametersPrefixStr = "/"
                }
                parametersStr.insert(parametersPrefixStr, at: parametersStr.startIndex)
            }
        case .POST:
            parametersStr    = handlePOSTRequestParameters(handlePOSTType: self.postHandleType)
        }
        
        return parametersStr
    }
}
