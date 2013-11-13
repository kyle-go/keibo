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

- (NSString *)translateUrlToLocalPath:(NSString *)url notificationName:(NSString *)name customObj:(id)obj;
@end
