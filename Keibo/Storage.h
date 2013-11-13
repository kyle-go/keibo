//
//  DataModel.h
//  Keibo
//
//  Created by kyle on 10/28/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Storage : NSObject

+ (instancetype)storageInstance;

//根据当前帐号id，初始化数据库
- (void)initStorageWithUserId:(NSString *)userId;


- (NSString *)translateUrlToLocalPath:(NSString *)url notificationName:(NSString *)name customObj:(id)obj;

@end
