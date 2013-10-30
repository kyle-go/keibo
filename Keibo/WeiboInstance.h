//
//  WeiboInstance.h
//  Keibo
//
//  Created by kyle on 10/30/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"

@interface WeiboInstance : NSObject<WeiboSDKDelegate>

+ (id) weiboInstance;

@end
