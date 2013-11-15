//
//  DataModel.m
//  Keibo
//
//  Created by kyle on 10/28/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "Storage.h"
#import "KUnits.h"
#import "AFNetworking.h"
#import "FMDatabase.h"
#import "DTUser.h"
#import "DTWeibo.h"
#import "DTWeiboMedia.h"

@implementation Storage {
    FMDatabase *db;
    NSString *ownerId;
}

+ (instancetype)storageInstance
{
    static id instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        //创建media文件夹
        NSString *imagesPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:kMedia];
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:&error];
    }

    return self;
}

//根据当前帐号id，初始化数据库
- (void)initStorageWithUId:(NSString *)uid
{
    //检查参数
    if ([uid length] == 0) {
        NSLog(@"initStorage uid = nil.");
        abort();
        return;
    }
    
    //用uid初始化数据库
    NSString *dbFile = [PATH_OF_DOCUMENT stringByAppendingPathComponent:uid];
    dbFile = [dbFile stringByAppendingString:@"_v1"]; //for v1 database
    
    db = [FMDatabase databaseWithPath:dbFile];
    if (!db) {
        NSLog(@"FMDatabase databaseWithPath failed.");
        abort();
    }
    if (![db open]) {
        NSLog(@"FMDatabase open failed.");
        abort();
    }
    
    //保存用户名
    ownerId = uid;
    
    //--------------------------------------------- 创建各种表 ---------------------------------------------------------
    //创建用户信息表(User) --- 记录用户一些信息，包括自己
    //uid, 名称，昵称，头像url，大头像url，性别，归属地，微博数，粉丝数，关注人数，签名，是否加V，加v原因，是否达人，是否会员，最新一条微博id，是否正在关注,
    //uid, name, nickName，avatar，avatarLarge,sex,address,weiboCount,fanCount，followingCount，sign，verified，verifiedReason，star,weiboMember，lastMyWeiboId, following，blog
    //是否此用户正在关注我, 是否所有人可以发私信，是否所有人可以评论, 互粉数
    //followMe，allowAllMsg，allowAllComment, biFollowerCount
    NSString *sql = @"CREATE TABLE IF NOT EXISTS 'User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'uid' VARCHAR(16), 'name' VARCHAR(30), 'nickName' VARCHAR(30), 'avatar' VARCHAR(512), 'avatarLarge' VARCHAR(512), 'sex' INTEGER, 'address' VARCHAR(128), 'weiboCount' INTEGER, 'fanCount' INTEGER, 'followingCount' INTEGER, 'sign' VARCHAR(70), 'verified' INTEGER, 'verifiedReason' VARCHAR(128), 'star' INTEGER, 'weiboMember' INTEGER, 'lastMyWeiboId' BIGINTEGER, 'following' INTEGER, 'followMe' INTEGER, 'allowAllMsg' INTEGER, 'allowAllComment' INTEGER, 'biFollowerCount' INTEGER, 'blog' VARCHAR(128))";
    if (![db executeUpdate:sql]) {
        NSLog(@"Create User table failed. error=%@", [db lastError]);
        abort();
    }
    
    //微博表(Weibo) --- 微博表
    //微博唯一Id，创建时间，所属人，来源，可见性，内容, 转发数，评论数，赞数，收藏，有图片
    //weiboId，date, owner，source，visible，content, repostCount, commentCount, likeCount, favorite，picture
    //是否转发，原转发微博id，原微博创建者,原微博内容，是否有图片
    //isRepost，originalWeiboId,originalOwner,originalWeiboContent，originalWeiboPicture
    
    //0：普通微博，1：私密微博，3：指定分组微博，4：密友微博；list_id为分组的组号
    sql = @"CREATE TABLE IF NOT EXISTS 'Weibo' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'weiboId' BITINTEGER, 'date' DATE, 'owner' VARCHAR(16), 'source' VARCHAR(32), 'visible' INTEGER, 'content' VARCHAR(160), 'repostCount' INTEGER, 'commentCount' INTEGER, 'likeCount' INTEGER, 'favorite' INTEGER, 'picture' INTEGER), 'isRepost' INTEGER, 'originalWeiboId' BIGINTEGER, 'originalOwner' VARCHAR(16),'originalWeiboContent' VARCHAR(160), 'originalWeiboPicture' INTEGER";
    if (![db executeUpdate:sql]) {
        NSLog(@"Create Weibo table failed. error=%@", [db lastError]);
        abort();
    }
    
    //微博资源表（WbMedia）
    //微博唯一Id，类型（图片，音乐，视频,目前只有图片这一种），资源序号，URL地址
    sql = @"CREATE TABLE IF NOT EXISTS 'WbMedia' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'weiboId' BITINTEGER, 'type' INTEGER, 'index' INTEGER, 'url' VARCHAR(512))";
    if (![db executeUpdate:sql]) {
        NSLog(@"Create WbMedia table failed. error=%@", [db lastError]);
        abort();
    }
    
    //多媒体库(Media) --- 多媒体资源url跟本地路径关系
    //多媒体url，本地全路径（文件名是uuid随机生存）
    //url，path
    sql = @"CREATE TABLE IF NOT EXISTS 'Media' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'url' VARCHAR(512), 'path' VARCHAR(260))";
    if (![db executeUpdate:sql]) {
        NSLog(@"Create Media table failed. error=%@", [db lastError]);
        abort();
    }
}

//添加/更新一条用户数据
- (void)addUser:(DTUser *)user
{
    //NSString *sql = @"";
}

//添加/更新一条微博
- (void)addWeibo:(DTWeibo *)weibo
{
    
}

- (void)addMedia:(NSString *)url File:(NSString *)file
{
    
}

- (void)addWeiboMedia:(DTWeiboMedia *)media
{
    
}

- (NSString *)getMediaByUrl:(NSString *)url
{
    NSString *sql = @"SELECT * FROM Media WHERE url='?'";
    FMResultSet *fs = [db executeQuery:sql, url];
    if ([fs next]) {
        return [fs stringForColumn:@"path"];
    }
    return nil;
}

//根据uid获取DTUser
- (DTUser *)getUserByUid:(NSString *)uid
{
    return nil;
}

//根据uid获取其weibos
- (NSArray *)getWeibosByUid:(NSString *)uid
{
    return nil;
}

@end