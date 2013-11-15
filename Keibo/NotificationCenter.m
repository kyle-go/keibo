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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_Login:) name:@"WeiboNetWork_Login" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_User:) name:@"WeiboNetWork_User" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_OneWeibo:) name:@"WeiboNetWork_OneWeibo" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_Weibos:) name:@"WeiboNetWork_Weibos" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_WbMedia:) name:@"WeiboNetWork_WbMedia" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_Media:) name:@"WeiboNetWork_Media" object:nil];
    }
    return self;
}

#pragma mark -------------- observer ----------------
-(void)WeiboNetWork_Login:(NSNotification *)notify
{
    //失败
    if (!notify.userInfo) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationCenter_Login" object:nil];
        return;
    }
    
    NSDictionary *param = notify.userInfo;
    NSString *accessToken = [param objectForKey:@"access_token"];
    NSString *uid = [param objectForKey:@"uid"];
    
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kAccessToken];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:kUid];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //初始化数据库
    [[Storage storageInstance] initStorageWithUId:uid];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationCenter_Login" object:nil userInfo:notify.userInfo];
}

-(void)WeiboNetWork_User:(NSNotification *)notify
{
    NSDictionary *param = [notify userInfo];
    DTUser *user = [param objectForKey:@"User"];
    //写入数据库
    [storageInstance addUser:user];
    
    UIUser *uiUser = [DataAdapter UserAdapter:user.uid];
    if ([user.uid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUid]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationCenter_LoginUser" object:nil userInfo:@{@"User":uiUser}];
    }
}

-(void)WeiboNetWork_OneWeibo:(NSNotification *)notify
{
    NSLog(@"WeiboNetWrok_Weibo.");
}

-(void)WeiboNetWork_Weibos:(NSNotification *)notify
{
    NSDictionary *param = notify.userInfo;
    NSString *type = [param objectForKey:@"type"];
    NSArray *array = [param objectForKey:@"array"];
    
    if ([type isEqualToString:@"latest"]) {
        //
    } else if ([type isEqualToString:@"since"]) {
        //
    } else if ([type isEqualToString:@"max"]) {
        //
    } else {
        abort();
    }
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
