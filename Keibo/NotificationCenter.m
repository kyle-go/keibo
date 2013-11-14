//
//  NotificationCenter.m
//  Keibo
//
//  Created by kyle on 13-11-14.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "NotificationCenter.h"
#import "DTUser.h"
#import "UIUser.h"
#import "DataAdapter.h"
#import "Storage.h"

@implementation NotificationCenter {
    Storage *storageInstance;
}

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
        storageInstance = [Storage storageInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_User:) name:@"WeiboNetWork_User" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_Weibo:) name:@"WeiboNetWork_Weibo" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_WbMedia:) name:@"WeiboNetWork_WbMedia" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_Media:) name:@"WeiboNetWork_Media" object:nil];
    }
    return self;
}

#pragma mark -------------- observer ----------------
-(void)WeiboNetWork_User:(NSNotification *)notify
{
    NSDictionary *param = [notify userInfo];
    DTUser *user = [param objectForKey:@"User"];
    UIUser *uiUser = [DataAdapter UserAdapter:user];
    
    if ([user.uid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUserId]]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LeftView_LoginUser" object:nil userInfo:@{@"user":uiUser}];
    }
    
    //写入数据库
    [storageInstance addUser:user];
}

-(void)WeiboNetWork_Weibo:(NSNotification *)notify
{
    NSLog(@"WeiboNetWrok_Weibo.");
}

-(void)WeiboNetWork_WbMedia:(NSNotification *)notify
{
    NSLog(@"WeiboNetWrok_WbMedia.");
}

-(void)WeiboNetWork_Media:(NSNotification *)notify
{
//    [storageInstance addMedia: ]
}
@end
