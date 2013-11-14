//
//  DataModel.h
//  Keibo
//
//  Created by kyle on 10/28/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTUser.h"
#import "DTWeibo.h"
#import "DTWeiboMedia.h"

@interface Storage : NSObject

+ (instancetype)storageInstance;

//根据当前帐号id，初始化数据库
- (void)initStorageWithUserId:(NSString *)userId;

//添加/更新一条用户数据
- (void)addUser:(DTUser *)user;

//添加/更新一条微博
- (void)addWeibo:(DTWeibo *)weibo;

//添加/更新多媒体资源
- (void)addBasicMedia:(NSString *)url File:(NSString *)file;

//添加weibo多媒体资源
- (void)addWeiboMedia:(DTWeiboMedia *)media;

- (NSString *)translateUrlToLocalPath:(NSString *)url notificationName:(NSString *)name customObj:(id)obj;

@end
