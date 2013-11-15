//
//  DataAdapter.m
//  Keibo
//
//  Created by kyle on 11/15/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "DataAdapter.h"
#import "Storage.h"
#import "UIUser.h"
#import "UIWeibo.h"
#import "DTUser.h"
#import "DTWeibo.h"

@implementation DataAdapter

//+ (instancetype)DAInstance
//{
//    static id instace;
//    static dispatch_once_t once;
//    dispatch_once(&once, ^{instace = self.new;});
//    return instace;
//}

+ (UIUser *)UserAdapter:(NSString *)uid
{
    DTUser *dtUser = [[Storage storageInstance] getUserByUid:uid];
    UIUser * uiUser = [[UIUser alloc] init];
    uiUser.avatar = dtUser.avatar;
    uiUser.name = dtUser.name;
    uiUser.sign = dtUser.sign;
    uiUser.address = dtUser.address;
    uiUser.sex = dtUser.sex;
    uiUser.isVerified = dtUser.verified;
    uiUser.isStar = dtUser.star;
    uiUser.followingCount = dtUser.followingCount;
    uiUser.fanCount = dtUser.fanCount;
    uiUser.weiboCount = dtUser.weiboCount;
    
    return uiUser;
}

//从数据库中获取UIWeibo数组，若为空返回nil
+ (NSArray *)WeibosFromStorage:(NSString *)uid
{
    NSArray *dtWeibos = [[Storage storageInstance] getWeibosByUid:uid];
    if ([dtWeibos count] == 0) {
        return nil;
    }
    
    NSMutableArray *array;
    for (DTWeibo *weibo in dtWeibos) {
        UIWeibo *uiWeibo = [[UIWeibo alloc] init];
        uiWeibo.weiboId = weibo.weiboId;
        DTUser *dtUser = [[Storage storageInstance] getUserByUid:uid];
        uiWeibo.avatarUrl = dtUser.avatar;
        uiWeibo.name = dtUser.name;
        uiWeibo.remarkName = dtUser.nickName;
        uiWeibo.feedComeFrom = weibo.source;
        uiWeibo.content = weibo.content;
        uiWeibo.date = weibo.date;
        uiWeibo.reposts = weibo.repostCount;
        uiWeibo.comments = weibo.commentCount;
        uiWeibo.likes = weibo.likeCount;
        
        uiWeibo.originWeiboId = weibo.originalWeiboId;
        dtUser = [[Storage storageInstance] getUserByUid:weibo.originalOwner];
        uiWeibo.originName = dtUser.name;
        uiWeibo.originContent = weibo.originalWeiboContent;
        
        [array addObject:uiWeibo];
    }
    return array;
}

@end
