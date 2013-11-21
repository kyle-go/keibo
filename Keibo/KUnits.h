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

//"<a href=\"http://weibo.com/\" rel=\"nofollow\">新浪微博</a>"
//新浪微博
+ (NSString *)getWeiboSourceText:(NSString *)text;

//Thu Nov 14 20:19:09 +0800 2013
+ (NSDate *)getNSDateByDateString:(NSString *)dateString;

//由具体时间获取一个“微博时间”，比如“1分钟前“
+ (NSString *)getProperDateStringByDate:(NSDate *)date type:(NSInteger *)type;

@end
