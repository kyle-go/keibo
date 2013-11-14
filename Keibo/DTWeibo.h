//
//  DTWeibo.h
//  Keibo
//
//  Created by kyle on 13-11-14.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

//DataBase Table Weibo
@interface DTWeibo : NSObject

@property (assign, nonatomic)long long weiboId;
@property (strong, nonatomic)NSDate *date;
@property (strong, nonatomic)NSString *owner; //此微博发送者id
@property (strong, nonatomic)NSString *source;
@property (assign, nonatomic)NSInteger visible;
@property (strong, nonatomic)NSString *content;
@property (assign, nonatomic)NSInteger isReport;
@property (assign, nonatomic)long long originalWeiboId;
@property (assign, nonatomic)NSInteger repostCount;
@property (assign, nonatomic)NSInteger commentCount;
@property (assign, nonatomic)NSInteger likeCount;
@property (assign, nonatomic)NSInteger favorite;
@property (assign, nonatomic)NSInteger picture;
@property (assign, nonatomic)NSInteger music;
@property (assign, nonatomic)NSInteger movie;

@end
