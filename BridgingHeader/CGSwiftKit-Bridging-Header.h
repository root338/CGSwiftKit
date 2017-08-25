//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
//  修改 Objective-C bridging-Header 的值

#ifndef CGSwiftKit_Bridging_Header_h
#define CGSwiftKit_Bridging_Header_h

#pragma mark - 视图控制器

//基类视图控制器
#import "CGBaseViewController.h"

#pragma mark - UIKit 扩展

//常量
#import "UIView+Constant.h"

//布局设置
#import "UIView+CGSetupFrame.h"
#import "UIView+CGAddConstraints.h"

//添加内容
#import "UIView+CGAddGestureRecognizer.h"

//设备方向判断
#import "UIApplication+CGVerifyDeviceDirection.h"

//字符串处理
#import "NSString+VerificationString.h"

#import "CGKit+SwiftBridgingHeader.h"

#endif
