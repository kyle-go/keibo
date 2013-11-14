//
//  DataModel.h
//  Keibo
//
//  Created by kyle on 10/28/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DTUser;
@class DTWeibo;
@class DTWeiboMedia;

@interface Storage : NSObject

+ (instancetype)storageInstance;

//根据当前帐号id，初始化数据库
- (void)initStorageWithUserId:(NSString *)userId;

//添加/更新一条用户数据
- (void)addUser:(DTUser *)user;

//添加/更新一条微博
- (void)addWeibo:(DTWeibo *)weibo;

//添加/更新多媒体资源
- (void)addMedia:(NSString *)url File:(NSString *)file;

//添加weibo多媒体资源
- (void)addWeiboMedia:(DTWeiboMedia *)media;

- (NSString *)getMediaByUrl:(NSString *)url;

@end
