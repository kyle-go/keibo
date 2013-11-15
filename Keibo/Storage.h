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
- (void)initStorageWithUId:(NSString *)uid;

//添加/更新一条用户数据
- (void)addUser:(DTUser *)user;

//添加/更新一条weibo
- (void)addWeibo:(DTWeibo *)weibo;

//批量添加weibo
- (void)addWeibos:(NSArray *)weibos;

//根据uid批量删除weibo
- (void)deleteWeibosByUid:(NSString *)uid;

//添加/更新多媒体资源
- (void)addMedia:(NSString *)url File:(NSString *)file;

//添加weibo多媒体资源
- (void)addWeiboMedia:(DTWeiboMedia *)media;

//根据Media url获取Media本地路径
- (NSString *)getMediaByUrl:(NSString *)url;

//根据uid获取DTUser
- (DTUser *)getUserByUid:(NSString *)uid;

//根据uid获取其weibos, 若date为空则获取最新的，否则获取比此时间早的微博（更旧的）
- (NSArray *)getWeibosByUid:(NSString *)uid  count:(NSInteger)count date:(NSDate*)date;

@end
