//
//  UIWeibo.h
//  Keibo
//
//  Created by kyle on 13-11-14.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIWeibo : NSObject

@property (assign, nonatomic)long long weiboId;         //微博唯一标识
@property (strong, nonatomic)NSString *avatarUrl;       //头像http url
@property (strong, nonatomic)NSString *name;            //微博发送者
@property (assign, nonatomic)NSInteger sex;             //微博博主性别
@property (assign, nonatomic)NSInteger star;            //是否达人
@property (assign, nonatomic)NSInteger verified;             //是否是认证 1黄v 2蓝v
@property (strong, nonatomic)NSString *remarkName;      //备注名，暂时不会用到
@property (strong, nonatomic)NSString *feedComeFrom;    //来自哪
@property (strong, nonatomic)NSString *content;         //微博内容
@property (strong, nonatomic)NSDate *date;              //微博发生日期
@property (assign, nonatomic)NSInteger reposts;         //转发数
@property (assign, nonatomic)NSInteger comments;        //评论数
@property (assign, nonatomic)NSInteger likes;           //赞数

@property (assign, nonatomic)NSInteger originWeiboId;   //原微博唯一标识
@property (strong, nonatomic)NSString *originName;      //原微博发送者
@property (strong, nonatomic)NSString *originContent;   //原微博内容

@end
