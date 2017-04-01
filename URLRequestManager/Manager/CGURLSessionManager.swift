//
//  CGURLSessionManager.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/29.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

@available(iOS 7.0, *)
class CGURLSessionManager: NSObject {
    
    static let sessionManager = CGURLSessionManager.init()
    
    let configuration : CGURLSessionManagerConfiguration
    
    private let session : URLSession
    
    override convenience init() {
        self.init(configuration:CGURLSessionManagerConfiguration.init())
    }
    
    init(configuration: CGURLSessionManagerConfiguration) {
        
        let delegate      = CGURLSessionDelegateManager.init()
        let operationQueue = OperationQueue.main
        
        self.configuration  = configuration
        
        // URLSession 的 delegate 是强引用
        
        session = URLSession.init(configuration: configuration.sessionConfiguration, delegate: delegate, delegateQueue: operationQueue)
        
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
    
//    func request(model: CGTaskRequestDataModel, completion: @escaping (_ taskDataModel: CGTaskDataModel) -> Void) -> URLSessionTask {
//        
//        
//    }
}


