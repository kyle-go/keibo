//
//  KSAppDelegate.m
//  Keibo
//
//  Created by kyle on 13-9-29.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "DataModel.h"
#import "AFNetworking.h"

static NSString* form_urlencode_HTTP5_String(NSString* s) {
    CFStringRef charactersToLeaveUnescaped = CFSTR(" ");
    CFStringRef legalURLCharactersToBeEscaped = CFSTR("!$&'()+,/:;=?@~");
    
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)s,
                                                                                 charactersToLeaveUnescaped,
                                                                                 legalURLCharactersToBeEscaped,
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

static NSString* form_urlencode_HTTP5_Parameters(NSDictionary* parameters)
{
    NSMutableString* result = [[NSMutableString alloc] init];
    BOOL isFirst = YES;
    for (NSString* name in parameters) {
        if (!isFirst) {
            [result appendString:@"&"];
        }
        isFirst = NO;
        assert([name isKindOfClass:[NSString class]]);
        NSString* value = parameters[name];
        assert([value isKindOfClass:[NSString class]]);
        
        NSString* encodedName = form_urlencode_HTTP5_String(name);
        NSString* encodedValue = form_urlencode_HTTP5_String(value);
        
        [result appendString:encodedName];
        [result appendString:@"="];
        [result appendString:encodedValue];
    }
    
    return [result copy];
}

@implementation AppDelegate

#pragma mark ----- private method---------------
- (void)login
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"email,direct_messages_write";
    request.userInfo = @{@"keibo微博客户端": @"keibo微博客户端"};
    [WeiboSDK sendRequest:request];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WeiboSDK registerApp:kAppKey];
    [WeiboSDK enableDebugMode:YES];
    
    //取access_token
    NSString *accessToken = [DataModel getAccessToken];
    if (!accessToken) {
        [self login];
    } else {
        //获取token是否过期成功回调
        void (^success_callback) (AFHTTPRequestOperation *operation, id responseObject) =
        ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
        };
        
        //获取token是否过期失败回调
        void (^failure_callback)(AFHTTPRequestOperation *operation, NSError *error) =
        ^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"Error: %@", error);
            [self login];
        };
        
        //判断token是否过期
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //just for https
        manager.requestSerializer.queryStringSerializationWithBlock =
        ^NSString*(NSURLRequest *request,
                   NSDictionary *parameters,
                   NSError *__autoreleasing *error) {
            NSString* encodedParams = form_urlencode_HTTP5_Parameters(parameters);
            return encodedParams;
        };
        NSDictionary *param = @{@"access_token":@"2.00vVnMpD2ecKNB39f2d04fb1wt3v1D"};
        [manager POST:@"https://api.weibo.com/oauth2/get_token_info" parameters:param success:success_callback failure:failure_callback];
    }
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    __asm int 3;
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
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
