//
//  CGTaskDataModel.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/30.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class CGTaskDataModel: NSObject {
    
    let task : URLSessionTask
    var HTTPResponse : HTTPURLResponse? {
        if let _HTTPResponse = task.response as? HTTPURLResponse {
            return _HTTPResponse
        }else {
            return nil
        }
    }
    var data : Data?
    
    init(task : URLSessionTask) {
        
        self.task   = task
        
        super.init()
    }
    
    func append(data : Data) {
        
        if self.data == nil {
            self.data   = Data.init()
        }
        self.data!.append(data);
    }
    
}
