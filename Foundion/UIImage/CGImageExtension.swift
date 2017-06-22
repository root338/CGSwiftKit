//
//  CGImageExtension.swift
//  TestCG_CGKit
//
//  Created by DY on 2017/5/25.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
    func imageColorValue() {
        
        let bitmapInfo = CGBitmapInfo.byteOrderMask.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        
        
        // 压缩图片大小
        let thumbImageSize  = self.size
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext.init(data: nil, width: Int(thumbImageSize.width), height: Int(thumbImageSize.height), bitsPerComponent: 8, bytesPerRow: Int(thumbImageSize.width) * 4, space: colorSpace, bitmapInfo: bitmapInfo)
        
        let drawRect = CGRect.init(origin: .zero, size: thumbImageSize)
        context?.draw(self.cgImage!, in: drawRect)
        
        // 取像素值
        guard let data = context?.data else {
            return;
        }
        
        let countedSet = NSCountedSet.init(capacity: Int(thumbImageSize.width * thumbImageSize.height))
        
        let maxWidth = Int(thumbImageSize.width)
        let maxHeight = Int(thumbImageSize.height)
        for x in 0 ..< maxWidth {
            for y in 0 ..< maxHeight {
                
                let offset  = 4 * (x * y)
                let red     = Int(data[offset])
                let green   = Int(data[offset + 1])
                let blue    = data[offset + 2]
                let alpha   = data[offset + 3]
                
                if alpha > 0 { // 去透明度
                    
                    if red {
                        <#code#>
                    }
                }
            }
        }
    }
 
     */
}
