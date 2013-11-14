//
//  WeiboNetWork.h
//  Keibo
//
//  Created by kyle on 13-11-13.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboNetWork : NSObject

//过期 发送一个 “accessTokenExpired”广播
//未过期 发送一个 “accessTokenNoExpired”广播
//网络故障 发送一个 “accessTokenNetWorkFailure”广播
+ (void)checkAccessToken:(NSString *)accessToken;

//由authorization_code获取accessToken
//成功发送一个“loginSucceed”广播
//失败发送一个“loginUnSucceed”广播
+ (void)getAccessTokenByCode:(NSString *)code;

//获取某个用户的信息
//发送一个"WeiboNetWork_User"通知
+ (void)getUser:(NSString *)accessToken userId:(NSString *)uid;

@end