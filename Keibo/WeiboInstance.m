//
//  WeiboInstance.m
//  Keibo
//
//  Created by kyle on 10/30/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "WeiboInstance.h"
#import "DataModel.h"

@implementation WeiboInstance

+ (id) weiboInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id) init
{
    if (self = [super init]) {
        [WeiboSDK registerApp:kAppKey];
        [WeiboSDK enableDebugMode:YES];
    }
    return self;
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    //__asm int 3;
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]])
    {
        NSString *title = @"发送结果";
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",
                             response.statusCode, response.userInfo, response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    } else if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",
                             response.statusCode,
                             [(WBAuthorizeResponse *)response userID],
                             [(WBAuthorizeResponse *)response accessToken],
                             response.userInfo,
                             response.requestUserInfo];
        NSLog(@"%@", message);
        
        [DataModel saveAccessToken:[(WBAuthorizeResponse *)response accessToken]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"closeAuthorizeView" object:nil];
    }
}

@end
