//
//  KSAppDelegate.h
//  Keibo
//
//  Created by kyle on 13-9-29.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WeiboSDKDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong) NSString* wbtoken;

@end
