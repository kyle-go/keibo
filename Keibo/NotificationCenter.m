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
#import "WeiboNetWork.h"

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_LoginUserWeibos:) name:@"WeiboNetWork_LoginUserWeibos" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_WbMedia:) name:@"WeiboNetWork_WbMedia" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_Media:) name:@"WeiboNetWork_Media" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiboNetWork_FollowingUsers:) name:@"WeiboNetWork_FollowingUsers" object:nil];
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
    
    //检查小头像(大头像暂且不下载)是否已下载到本地
    if ([[storageInstance getMediaByUrl:user.avatar] length] == 0) {
        [WeiboNetWork getOneMedia:user.avatar];
    }

    UIUser *uiUser = [DataAdapter UserAdapter:user.uid];
    if ([user.uid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kUid]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationCenter_LoginUser" object:nil userInfo:@{@"User":uiUser}];
    }
}

-(void)WeiboNetWork_OneWeibo:(NSNotification *)notify
{
    NSLog(@"WeiboNetWrok_Weibo.");
}

-(void)WeiboNetWork_LoginUserWeibos:(NSNotification *)notify
{
    NSDictionary *param = notify.userInfo;
    if ([param count] == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationCenter_LoginUserWeibos" object:nil];
        return;
    }
    
    NSString *type = [param objectForKey:@"type"];
    NSArray *array = [param objectForKey:@"array"];
    
    if ([type isEqualToString:@"latest"]) {
        //清空weibo表
        [storageInstance deleteIndexWeibos];
        //将数据写入数据库
        [storageInstance addWeibos:array];
    } else if ([type isEqualToString:@"since"]) {
        //不清空表，直接添加数据库
        //
        [storageInstance addWeibos:array];
    } else if ([type isEqualToString:@"max"]) {
        //不添加数据库，只在内存中给UI使用
        //这里需要去掉第一个，因为这个请求是闭区间
        NSMutableArray *paramArray = [[NSMutableArray alloc] initWithArray:array];
        if ([paramArray count] > 0) {
            [paramArray removeObjectAtIndex:0];
        }
        array = paramArray;
    } else {
        //
    }
    
    //转化格式给UI使用
    NSMutableArray *uiArray = [[NSMutableArray alloc] init];
    for (DTWeibo *weibo in array) {
        [uiArray addObject:[DataAdapter WeiboAdapter:weibo]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationCenter_LoginUserWeibos" object:nil userInfo:@{@"array": uiArray, @"type":type}];
}

-(void)WeiboNetWork_WbMedia:(NSNotification *)notify
{
    NSLog(@"WeiboNetWrok_WbMedia.");
}

-(void)WeiboNetWork_Media:(NSNotification *)notify
{
    NSDictionary *param = notify.userInfo;
    if ([param count] == 0) {
        return;
    }
    NSString *url = [param objectForKey:@"url"];
    NSString *file = [param objectForKey:@"file"];
    
    [storageInstance addMedia: url File:file];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationCenter_Media" object:nil userInfo:@{@"url": url, @"file":file}];
}

- (void)WeiboNetWork_FollowingUsers:(NSNotification *)notify
{
    NSDictionary *param = notify.userInfo;
    if ([param count] == 0) {
        return;
    }
    NSString *uid = [param objectForKey:@"uid"];
    NSArray *users = [param objectForKey:@"array"];
    
    for (DTUser *u in users) {
        [storageInstance addUser:u];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationCenter_FollowingUsers" object:nil userInfo:@{@"uid": uid, @"array":users}];
}

@end
