//
//  CGImageDataModel.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/3/31.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

typealias CGLoadImageCompletion = (_ image: UIImage?, _ error: Error?) -> Void

/// 图片数据模型
class CGImageDataModel: NSObject {
    
    /// 图片数据
    var image : UIImage?
    
    /// 图片网络地址
    var imageURL : URL?
    
    /// 图片网络地址字符串形式
    var imageURLString : String?
    
    /// 图片名 在项目 图片管理 Assets 中
    var imageNameForAssets  : String?
    
    /// 图片名 在本地项目文件中
    var imageNameForLocalResources  : String?
    
    /// 图片文件路径
    var imageFilePath : String?
    
    /// 图片文件路径 URL 类型
    var imageFileURLPath : URL?
    
    /// 图片大小，预估
    var imageEstimatedSize : CGSize?
    
    func loadImage(completion: CGLoadImageCompletion) -> Void {
        
        
    }
}
