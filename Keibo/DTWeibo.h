//
//  DTWeibo.h
//  Keibo
//
//  Created by kyle on 13-11-14.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

enum DTWeibo_Visible {
    Visible_Normal = 0, //普通微博
    Visible_Secret = 1, //私密微博
    Visible_GoodFriend = 3,//密友微博
    
    //对分组可见 ＝ 20000 + 组号
};

//DataBase Table Weibo
@interface DTWeibo : NSObject

@property (assign, nonatomic)long long weiboId;
@property (strong, nonatomic)NSDate *date;
@property (strong, nonatomic)NSString *owner; //此微博发送者id
@property (strong, nonatomic)NSString *source;
@property (assign, nonatomic)NSInteger visible;
@property (strong, nonatomic)NSString *content;
@property (assign, nonatomic)NSInteger repostCount;
@property (assign, nonatomic)NSInteger commentCount;
@property (assign, nonatomic)NSInteger likeCount;
@property (assign, nonatomic)NSInteger favorite;
@property (assign, nonatomic)NSInteger picture;

@property (assign, nonatomic)NSInteger isRepost;
@property (assign, nonatomic)long long originalWeiboId;
@property (strong, nonatomic)NSString *originalOwner;
@property (strong, nonatomic)NSString *originalWeiboContent;
@property (assign, nonatomic)NSInteger originalWeiboPicture;
@property (assign, nonatomic)NSInteger isIndex;

@end
