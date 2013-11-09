//
//  WeiboCellData.h
//  Keibo
//
//  Created by kyle on 11/9/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboCellData : NSObject

@property (assign, nonatomic)NSInteger weiboId;
@property (strong, nonatomic)NSString *avatarUrl;
@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSString *nickName;
@property (strong, nonatomic)NSString *feedComeFrom;
@property (strong, nonatomic)NSDate *date;

@property (assign, nonatomic)NSInteger reposts; //转发数
@property (assign, nonatomic)NSInteger comments; //评论数
@property (assign, nonatomic)NSInteger likes; // 赞数

@end
