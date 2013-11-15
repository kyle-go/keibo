//
//  DataAdapter.h
//  Keibo
//
//  Created by kyle on 11/15/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIUser;
@class UIWeibo;
@class DTUser;
@class DTWeibo;

@interface DataAdapter : NSObject

//+ (instancetype)DAInstance;
//根据uid获取UIUser
+ (UIUser *)UserAdapter:(NSString *)uid;

//从数据库中获取UIWeibo数组，若为空返回nil
+ (NSArray *)WeibosFromStorage:(NSString *)uid;

@end