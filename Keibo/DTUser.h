//
//  DTUser.h
//  Keibo
//
//  Created by kyle on 13-11-14.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

//DataBase Table User
@interface DTUser : NSObject

@property (strong, nonatomic)NSString *uid;
@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSString *nickName;
@property (strong, nonatomic)NSString *avatar;
@property (strong, nonatomic)NSString *avatarLarge;
@property (strong, nonatomic)NSString *address;
@property (strong, nonatomic)NSString *sign;
@property (assign, nonatomic)NSInteger sex; //0-man  1-woman 2-unknown
@property (assign, nonatomic)NSInteger weiboCount;
@property (assign, nonatomic)NSInteger fanCount;
@property (assign, nonatomic)NSInteger followingCount;
@property (assign, nonatomic)NSInteger verified; //0-没有v  1-普通黄v  2-蓝v
@property (strong, nonatomic)NSString *verifiedReason;
@property (assign, nonatomic)NSInteger star;//是否达人
@property (assign, nonatomic)NSInteger weiboMember;//是否会员
@property (assign, nonatomic)long long lastMyWeiboId;
@property (assign, nonatomic)NSInteger following;
@property (assign, nonatomic)NSInteger followMe;
@property (assign, nonatomic)NSInteger allowAllMsg;
@property (assign, nonatomic)NSInteger allowAllComment;
@property (assign, nonatomic)NSInteger biFollowCount;

@end
