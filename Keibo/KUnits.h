//
//  KUnits.h
//  Keibo
//
//  Created by kyle on 11/10/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KUnits : NSObject

//获取一个uuid字符串
+ (NSString *)generateUuidString;

//格式化一条微博，repostContent为nil说明没有被转发原微博
+ (NSString *)weiboFormat:(NSString *)content repost:(NSString *)repostContent reposter:(NSString *)name;

//格式化一个http连接
+ (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params;

//从一个字符串中查找子字符串的值
//  string = "access_token=2.00vVnMpDjoxjvDbc593cb4eft_exCE&remind_in=556237&expires_in=556237&uid=3505041903"
//  sub = "access_token="
//  return = "2.00vVnMpDjoxjvDbc593cb4eft_exCE"
+ (NSString *)getSubSplitString:(NSString *)string sub:(NSString *)key;

@end
