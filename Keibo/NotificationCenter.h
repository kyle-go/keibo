//
//  NotificationCenter.h
//  Keibo
//
//                  微博系统通知中心
//  主要处理网络请求结果反馈，若关心网络操作结果，需在本模块注册回调
//
//  Created by kyle on 13-11-14.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

//NotificationCenter_Login              登录成功，失败
//NotificationCenter_Media              下载Media成功，失败
//NotificationCenter_LoginUser          获取到当前登录用户信息
//NotificationCenter_LoginUserWeibos    获取当前用户weibos通知
//NotificationCenter_FollowingUsers     获取用户(s)
//NotificationCenter_FanUsers           获取用户(s)

@interface NotificationCenter : NSObject

+(instancetype) NCInstance;

@end
