//
//  WeiboNetWork.h
//  Keibo
//  *********************************************************
//
//                  微博系统的网络请求中心
//  请求结果全部通过通知方式全部交给NotificationCenter处理，
//  对于关心网络操作结果动作，另外去NotificationCenter注册，然后获取操作请求结果
//
//  Created by kyle on 13-11-13.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboNetWork : NSObject

//获取登录request
+ (NSURLRequest *)loginRequest;

//失败 发送一个 “WeiboNetWork_LoginFailed”广播
//成功 发送一个 “WeiboNetWork_LoginSucceed”广播
+ (void)checkAccessToken:(NSString *)accessToken;

//由authorization_code获取accessToken
//失败发送一个“WeiboNetWork_LoginFailed”广播
//成功发送一个“WeiboNetWork_LoginSucceed”广播
+ (void)getAccessTokenByCode:(NSString *)code;

//获取某个用户的信息, 操作完成会发送各种通知
+ (void)getUser:(NSString *)accessToken uid:(NSString *)uid;

//获取一条微博，
+ (void)getWeibo:(NSString *)accessToken weiboId:(long long)weiboId;

//批量获取最新微博，只有本地列表为空时才调用，【覆盖】当前用户weibo表，默认kWeiboCount条
+ (void)getLoginUserWeibos:(NSString *)accessToken;

//批量获取比since_id更新的微博，默认最多为kWeiboCount条，直接插入数据库
+ (void)getLoginUserWeibos:(NSString *)accessToken since:(NSString *)since_id;

//批量获取比max_id更旧的微博，默认每次为kWeiboCount条，【不添加到】weibo表，只在内存中出现
+ (void)getLoginUserWeibos:(NSString *)accessToken max:(NSString *)max_id;

//下载一个媒体(图片,音乐，视频）
+ (void)getOneMedia:(NSString *)url;

@end