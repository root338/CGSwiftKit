//
//  CGURLSessionManager.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/29.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

typealias CGRequestSuccessBlock = (_ taskDataModel: CGTaskDataModel) -> Void
typealias CGRequestFailureBlock = (_ taskDataModel: CGTaskDataModel) -> Void
typealias CGRequestCompletion   = (_ taskDataModel: CGTaskDataModel) -> Void

@available(iOS 7.0, *)
class CGURLSessionManager: NSObject {
    
    static let sessionManager = CGURLSessionManager.init()
    
    let configuration : CGURLSessionManagerConfiguration
    
    
    //MARK:- private 变量
    private let session : URLSession
    private weak var sessionDelegateManager : CGURLSessionDelegateManager! {
        return session.delegate as! CGURLSessionDelegateManager
    }
    
    //MARK:- fileprivate 变量
//    fileprivate var delegateList : [CGURLSessionTaskDelegate]?
    
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
    
    func request(urlString: String, successBlock: CGRequestSuccessBlock, failureBlock: CGRequestFailureBlock) -> URLSessionTask {
        
        let url = URL.init(string: urlString)
        let task = session.dataTask(with: url!)
        
        _ = sessionDelegateManager.taskManager.addTaskData(sessionTask: task)
        
        task.resume()
        
        return task
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


// MARK: - CGURLSessionManager 协议处理
extension CGURLSessionManager {
    
//    func addSessionDelegate(delegate: CGURLSessionTaskDelegate) {
//        
//        if delegateList == nil {
//            delegateList = []
//        }
//        delegateList?.append(delegate)
//    }
//    
//    func removeSessionDelegate(delegate: CGURLSessionTaskDelegate) {
//        
//        
//    }
    
}

