//
//  DataModel.m
//  Keibo
//
//  Created by kyle on 10/28/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "Storage.h"
#import "KUnits.h"
#import "NotificationObject.h"
#import "AFNetworking.h"
#import "FMDatabase.h"

@implementation Storage {
    NSMutableDictionary *imageDictionary;
    FMDatabase *db;
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
        imageDictionary = [[NSMutableDictionary alloc] init];
    }
    
    //创建images文件夹
    NSString *imagesPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"images"];
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:&error];

    return self;
}

//根据当前帐号id，初始化数据库
- (void)initStorageWithUserId:(NSString *)userId
{
    //检查参数
    if ([userId length] == 0) {
        NSLog(@"initStorage userId = nil.");
        abort();
        return;
    }
    
    //用userId初始化数据库
    NSString *dbFile = [PATH_OF_DOCUMENT stringByAppendingPathComponent:userId];
    db = [FMDatabase databaseWithPath:dbFile];
    if (!db) {
        NSLog(@"FMDatabase databaseWithPath failed.");
        abort();
    }
    if (![db open]) {
        NSLog(@"FMDatabase open failed.");
        abort();
    }
    
    //创建登录者信息表(loginUser) --- 记录登录人的详细信息
    //uid,名称，头像url，性别，归属地，微博数，粉丝数，关注人数，签名，是否加V，最新一条微博id，最新赞过微博id
    //uid,name,avatar,sex,address,weiboCount,fanCount，followingCount，sign，isVip，lastMyWeiboId，lastLikeWeiboId
    
    //创建用户表(user) --- 各种出现的人的基本信息
    //uid,名称，头像url，微博数，粉丝数，关注人数
    //uid，name，avatar，weiboCount，fanCount，followingCount
    
    //微博表(weibo) --- 各种微博
    //微博唯一Id，所属人，类型，内容， 是否转发，原转发微博id,
    //weiboId，owner，type，content，isRepost，originalWeiboId,
    
    //图片库(images) --- 各种图片url跟本地路径关系
    //图片url，本地文件名（路径是固定的，所以只存一个文件名就ok，文件名是uuid随机生存）
    //url，filename
}

//url 转化为本地图片路径
- (NSString *)translateUrlToLocalPath:(NSString *)url notificationName:(NSString *)name customObj:(id)obj
{
    //1.检查是否 存在dictionary表中且本地存在此文件
    id value = [imageDictionary objectForKey:url];
    if ([value isKindOfClass: [NSString class]]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:value]) {
            return (NSString *)value;
        }
    }
    
    //从网络上下载此文件
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *filePath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"images"];
        NSString *file = [[NSString alloc] initWithFormat:@"%@/%@", filePath, [KUnits generateUuidString]];
        return [NSURL fileURLWithPath:file isDirectory:NO];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NotificationObject *notify = [[NotificationObject alloc] init];
        notify.customObj = obj;
        
        if (!error) {
            notify.resultValue = [filePath path];
            [imageDictionary setObject:notify.resultValue forKey:url];
        } else {
            notify.resultValue = nil;
            NSLog(@"downloaded %@ failed. error=%@", filePath, error);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:notify];
    }];
    [downloadTask resume];
    
    return nil;
}

@end