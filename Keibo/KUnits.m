//
//  KUnits.m
//  Keibo
//
//  Created by kyle on 11/10/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "KUnits.h"

@implementation KUnits

+ (NSString *)generateUuidString {
    CFStringRef uuid = CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault));
    return [NSString stringWithString:CFBridgingRelease(uuid)];
}

+ (NSString *)weiboFormat:(NSString *)content repost:(NSString *)repostContent
{
//    NSString *temp_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/weibo.html"];
//    NSData *tmp_data = [[NSFileManager defaultManager] contentsAtPath:temp_path];
//    NSString *webContent = [[NSString alloc] initWithData:tmp_data encoding:NSUTF8StringEncoding];
    //发现@   俩#   http(s)://*.*    表情[]
    return @"";
}

@end
