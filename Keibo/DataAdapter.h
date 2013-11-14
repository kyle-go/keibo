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
+ (UIUser *)UserAdapter:(DTUser *)dtUser;

@end
