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

@implementation Storage {
    NSMutableDictionary *imageDictionary;
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