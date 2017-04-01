//
//  CGURLSessionManagerConfiguration.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/31.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class CGURLSessionManagerConfiguration: NSObject {

    let sessionConfiguration    : URLSessionConfiguration
    let baseURL                 : URL?
    var baseURLString : String? {
        return self.baseURL?.absoluteString
    }
    
    init(sessionConfiguration: URLSessionConfiguration, baseURL: URL?) {
        
        self.sessionConfiguration   = sessionConfiguration
        self.baseURL                = baseURL
        
        super.init()
    }
    
    override convenience init() {
        self.init(sessionConfiguration: URLSessionConfiguration.default, baseURL: nil)
    }
}
