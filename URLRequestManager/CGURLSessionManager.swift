//
//  CGURLSessionManager.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/29.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

typealias CGURLSessionSuccessBlock      = (_ taskDataModel: CGTaskDataModel) -> Void
typealias CGURLSessionFailureBlock      = CGURLSessionSuccessBlock
typealias CGURLSessionCompletionBlock   = CGURLSessionSuccessBlock

enum CGURLSessionTaskType : Int {
    
    case data
    case upload
    case download
    
    case stream
}

@available(iOS 7.0, *)
class CGURLSessionManager: NSObject {
    
    static let sessionManager = CGURLSessionManager.init()
    
    private let session : URLSession
    
    override init() {
        
        let configuration = URLSessionConfiguration.default
        let delegate      = CGURLSessionDelegateManager.init()
        let operationQueue = OperationQueue.main
        
        // URLSession 的 delegate 是强引用
        
        session = URLSession.init(configuration: configuration, delegate: delegate, delegateQueue: operationQueue)
        
        super.init()
        
    }
    
    func request(urlString: String) {
        
        let url = URL.init(string: urlString)
        let task    = session.dataTask(with: url!)
        
        task.resume()
        
    }
    
//    func request(URLString: String, completion: @escaping (_ taskDataModel: CGTaskDataModel) -> Void) -> URLSessionTask {
//        
//        
//    }
}
