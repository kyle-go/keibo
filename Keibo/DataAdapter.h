//
//  DataAdapter.h
//  Keibo
//
//  Created by kyle on 11/15/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIUser;
@class UIWeibo;
@class DTUser;
@class DTWeibo;

@interface DataAdapter : NSObject

//+ (instancetype)DAInstance;
//根据uid获取UIUser
+ (UIUser *)UserAdapter:(NSString *)uid;

//根据DTWeibo 获取 UIWeibo
+ (UIWeibo *)WeiboAdapter:(DTWeibo *)weibo;

//根据uid获取UIWeibo数组，若date为空则获取最新的，否则获取比此时间早的微博（更旧的）
+ (NSArray *)getWeibosByUid:(NSString *)uid count:(NSInteger)count date:(NSDate *)date;

//获取当前登录用户UIWeibo数组，若date为空则获取最新的，否则获取比此时间早的微博（更旧的）
+ (NSArray *)getLoginUserWeibos:(NSInteger)count date:(NSDate *)date;

//根据Media url获取Media本地路径
+ (NSString *)getMediaByUrl:(NSString *)url;

//获取登录用户关注人列表
+ (NSArray *)getLoginUserFollowings;

@end