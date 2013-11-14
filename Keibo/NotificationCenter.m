//
//  NotificationCenter.m
//  Keibo
//
//  Created by kyle on 13-11-14.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "NotificationCenter.h"

@implementation NotificationCenter

+(instancetype) NCInstance
{
    static id instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_User:) name:@"WeiboNetWork_User" object:nil];
    }
    return self;
}

#pragma mark -------------- observer ----------------
-(void)WeiboNetWork_User:(NSNotification *)notify
{
    NSLog(@"WeiboNetWrok_User.");
}

@end
