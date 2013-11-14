//
//  WeiboNetWork.h
//  Keibo
//
//  Created by kyle on 13-11-13.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboNetWork : NSObject

//获取登录request
+ (NSURLRequest *)loginRequest;

//失败 发送一个 “AuthorizeView_loginFailed”广播
//成功 发送一个 “AuthorizeView_loginSucceed”广播
+ (void)checkAccessToken:(NSString *)accessToken;

//由authorization_code获取accessToken
//成功发送一个“AuthorizeView_loginSucceed”广播
//失败发送一个“AuthorizeView_loginFailed”广播
+ (void)getAccessTokenByCode:(NSString *)code;

//获取某个用户的信息, 操作完成会发送各种通知
+ (void)getUser:(NSString *)accessToken userId:(NSString *)uid;

//获取一条微博，
+ (void)getWeibo:(NSString *)accessToken weiboId:(long long)weiboId;

@end