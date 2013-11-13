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
//网络故障 发送一个 “accessTokenNetWorkFailure”广
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

@end
