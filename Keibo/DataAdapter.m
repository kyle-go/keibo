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

+ (UIUser *)privateUserAdapter:(DTUser *)dtUser
{
    UIUser * uiUser = [[UIUser alloc] init];
    uiUser.avatar = dtUser.avatar;
    uiUser.avatarLarge = dtUser.avatarLarge;
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

+ (UIUser *)UserAdapter:(NSString *)uid
{
    DTUser *dtUser = [[Storage storageInstance] getUserByUid:uid];
    return [self privateUserAdapter:dtUser];
}

+ (UIWeibo *)WeiboAdapter:(DTWeibo *)weibo
{
    UIWeibo *uiWeibo = [[UIWeibo alloc] init];
    uiWeibo.weiboId = weibo.weiboId;
    DTUser *dtUser = [[Storage storageInstance] getUserByUid:weibo.owner];
    uiWeibo.avatarUrl = dtUser.avatar;
    uiWeibo.star = dtUser.star;
    uiWeibo.verified = dtUser.verified;
    uiWeibo.sex = dtUser.sex;
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
    return uiWeibo;
}

+ (NSArray *)privateGetUIWeiboFromDTWeiboArray:(NSArray *)dtWeibos
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (DTWeibo *weibo in dtWeibos) {
        [array addObject:[self WeiboAdapter:weibo]];
    }
    return array;
}

//根据uid获取UIWeibo数组，若date为空则获取最新的，否则获取比此时间早的微博（更旧的）
+ (NSArray *)getWeibosByUid:(NSString *)uid count:(NSInteger)count date:(NSDate *)date
{
    NSArray *dtWeibos = [[Storage storageInstance] getWeibosByUid:uid count:count date:date];
    if ([dtWeibos count] == 0) {
        return nil;
    }
    return [self privateGetUIWeiboFromDTWeiboArray:dtWeibos];
}

//获取当前登录用户UIWeibo数组，若date为空则获取最新的，否则获取比此时间早的微博（更旧的）
+ (NSArray *)getLoginUserWeibos:(NSInteger)count date:(NSDate *)date
{
    NSArray *dtWeibos = [[Storage storageInstance] getLoginUserWeibos:count date:date];
    if ([dtWeibos count] == 0) {
        return nil;
    }
    
    return [self privateGetUIWeiboFromDTWeiboArray:dtWeibos];
}

//根据Media url获取Media本地路径
+ (NSString *)getMediaByUrl:(NSString *)url
{
    return [[Storage storageInstance]getMediaByUrl:url];
}

//获取登录用户关注人列表
+ (NSArray *)getLoginUserFollowings
{
    NSArray *dtUsers = [[Storage storageInstance]getLoginUserFollowings];
    if (dtUsers.count == 0) {
        return nil;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (DTUser *u in dtUsers) {
        [array addObject:[self privateUserAdapter:u]];
    }
    return array;
}

@end
