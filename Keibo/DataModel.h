//
//  DataModel.h
//  Keibo
//
//  Created by kyle on 10/28/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

+ (instancetype)DMInstance;
+ (NSString *)getAccessToken;
+ (void)saveAccessToken:(NSString *)accessToken;

@end
