//
//  DataModel.m
//  Keibo
//
//  Created by kyle on 10/28/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "DataModel.h"
#import "KUnits.h"
#import "NotificationObject.h"
#import "AFNetworking.h"

@implementation DataModel {
    NSMutableDictionary *imageDictionary;
}

+ (instancetype)DMInstance
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

+ (NSString *)getAccessToken
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:@"accessToken"];
}

+ (void)saveAccessToken:(NSString *)accessToken
{
    if (!accessToken) {
        return;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:accessToken forKey:@"accessToken"];
    [ud synchronize];
}

//url 转化为本地图片路径
- (NSString *)TranslateUrlToLocalPath:(NSString *)url notificationName:(NSString *)name
{
    //1.检查是否 存在dictionary表中且本地存在此文件
    id value = [imageDictionary objectForKey:url];
    if ([value isKindOfClass: [NSString class]]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:value]) {
            return (NSString *)value;
        }
    }
    
    __block NSString *uuid = [KUnits generateUuidString];
    
    //从网络上下载此文件
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [[NSURL alloc] initWithString:uuid];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error) {
            NotificationObject *obj = [[NotificationObject alloc] init];
            obj.retValue = [filePath absoluteString];
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj];
        } else {
            NSLog(@"downloaded %@ failed. error=%@", filePath, error);
        }
    }];
    [downloadTask resume];
    
    return nil;
}

@end