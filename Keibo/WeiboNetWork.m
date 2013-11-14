//
//  WeiboNetWork.m
//  Keibo
//
//  Created by kyle on 13-11-13.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "WeiboNetWork.h"
#import "AFNetworking.h"
#import "AFTextResponseSerializer.h"

@implementation WeiboNetWork

//过期 发送一个 “accessTokenExpired”广播
//未过期 发送一个 “accessTokenNoExpired”广播
//网络故障 发送一个 “accessTokenNetWorkFailure” 广播
+ (void)checkAccessToken:(NSString *)accessToken
{
    //获取token是否过期成功回调
    void (^success_callback) (AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSError *error;
        NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSNumber *expire = [json objectForKey:@"expire_in"];
        
        //已经过期则重新认证
        if ([expire intValue] <= 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"accessTokenExpired" object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"accessTokenNoExpired" object:nil];
        }
    };
    
    //获取token是否过期失败回调
    void (^failure_callback)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"accessTokenNetWorkFailure" object:nil];
    };
    
    //判断token是否过期POST请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFTextResponseSerializer serializer]];
    [manager POST:@"https://api.weibo.com/oauth2/get_token_info" parameters:@{@"access_token":accessToken} success:success_callback failure:failure_callback];
}

+ (void)getAccessTokenByCode:(NSString *)code
{
    void (^success_callback) (AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSError *error;
        NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSNumber *expire = [json objectForKey:@"expires_in"];
        
        //已经过期则重新认证
        if ([expire intValue] <= 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginUnSucceed" object:nil];
            return;
        }

        NSString *accessToken = [json objectForKey:@"access_token"];
        NSString *uid = [json objectForKey:@"uid"];
        NSDictionary *params = @{@"access_token":accessToken, @"uid":uid};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSucceed" object:nil userInfo:params];
    };
    
    void (^failure_callback)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginUnSucceed" object:nil];
    };
    
    //判断token是否过期POST请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFTextResponseSerializer serializer]];
    NSDictionary *params = @{@"client_id":kAppKey, @"client_secret":kAppSecret, @"grant_type":@"authorization_code", @"code":code, @"redirect_uri":kRedirectUri};
    [manager POST:@"https://api.weibo.com/oauth2/access_token" parameters:params success:success_callback failure:failure_callback];
}

@end
