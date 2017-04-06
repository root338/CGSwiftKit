//
//  CGURLSessionDelegateManager.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/29.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class CGURLSessionDelegateManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    let taskManager : CGURLTaskManager
    
    convenience override init() {
        
        let taskManager = CGURLTaskManager.init()
        self.init(taskManager: taskManager)
    }
    
    init(taskManager: CGURLTaskManager) {
        
        self.taskManager    = taskManager
        
        super.init()
    }
    
    //MARK:- URLSessionDelegate
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        
    }
    
    /**
     调用条件:  访问HTTPS时会调用
     方法作用:  处理服务器返回的证书，需要在该方法中告诉系统是否需要安装服务器返回的证书，请求的处理
     */
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        var disposition = URLSession.AuthChallengeDisposition.performDefaultHandling
        var credential : URLCredential?;
        
        // 判断服务器的证书是否受信任
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            
            if let serverTrust = challenge.protectionSpace.serverTrust {
                credential  = URLCredential.init(trust: serverTrust)
            }
            
            /*
             useCredential                  使用指定的证书
             performDefaultHandling         忽略证书(默认的处理方式)
             cancelAuthenticationChallenge  忽略书证, 并取消这次请求
             rejectProtectionSpace          拒绝当前这一次, 下一次再询问
             */
            
            if credential != nil {
                disposition = .useCredential
            }else {
                disposition = .performDefaultHandling
            }
        }else {
            disposition = .cancelAuthenticationChallenge
        }
        
        completionHandler(disposition, credential)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
    }
    
    //MARK:- URLSessionTaskDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let taskDataModel   = self.taskManager.getTaskData(sessionTask: task)
        
        if taskDataModel.data != nil {
            
            let resultValue = String.init(data: taskDataModel.data!, encoding: .utf8)
            print(resultValue!)
        }
    }
    
    //MARK:- URLSessionDataDelegate
    /**
     接收到服务器响应的时候调用
     */
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        self.taskManager.setupTaskData(sessionTask: dataTask, response: response)
        completionHandler(.allow)
    }
    
    /**
     接收服务器返回数据的时候调用 (可能多次调用)
     */
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        self.taskManager.setupTaskData(sessionTask: dataTask, data: data)
    }
    
    /**
     实现自定义缓存策略
     */
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
//        
//        completionHandler(proposedResponse)
//    }
    
    
}
