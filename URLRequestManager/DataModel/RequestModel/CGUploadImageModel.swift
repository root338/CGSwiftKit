//
//  CGUploadImageModel.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/31.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class CGUploadImageModel: NSObject {
    
    var image : CGImageDataModel
    
    init(image: CGImageDataModel) {
        self.image  = image
        
        super.init()
    }
}
