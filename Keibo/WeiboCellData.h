//
//  WeiboCellData.h
//  Keibo
//
//  Created by kyle on 11/9/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboCellData : NSObject

@property (assign, nonatomic)NSInteger weiboId;         //微博唯一标识
@property (strong, nonatomic)NSString *avatarUrl;       //头像http url
@property (strong, nonatomic)NSString *name;            //微博发送者
@property (strong, nonatomic)NSString *remarkName;      //备注名，暂时不会用到
@property (strong, nonatomic)NSString *feedComeFrom;    //来自哪
@property (strong, nonatomic)NSString *content;         //微博内容
@property (strong, nonatomic)NSDate *date;              //微博发生日期
@property (assign, nonatomic)NSInteger reposts;         //转发数
@property (assign, nonatomic)NSInteger comments;        //评论数
@property (assign, nonatomic)NSInteger likes;           // 赞数

@property (assign, nonatomic)BOOL hasOriginWeibo;       //是否转发

@property (assign, nonatomic)NSInteger originWeiboId;   //原微博唯一标识
@property (strong, nonatomic)NSString *originName;      //原微博发送者
@property (strong, nonatomic)NSString *originContent;   //原微博内容
@property (assign, nonatomic)NSInteger originReposts;   //转发数
@property (assign, nonatomic)NSInteger originComments;  //评论数
@property (assign, nonatomic)NSInteger originLikes;     // 赞数

@end