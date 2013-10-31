//
//  AuthorizeViewController.m
//  Keibo
//
//  Created by kyle on 10/30/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "AuthorizeViewController.h"
#import "AFNetworking.h"
#import "AFTextResponseSerializer.h"
#import "DataModel.h"

@interface AuthorizeViewController ()

@end

@implementation AuthorizeViewController

#pragma mark ----- private method ---------------
- (void)login
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"email,direct_messages_write";
    request.userInfo = @{@"keibo微博客户端": @"keibo微博客户端"};
    [WeiboSDK sendRequest:request];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeSelf) name:@"closeAuthorizeView" object:nil];
    
    //取access_token
    NSString *accessToken = [DataModel getAccessToken];
    if (!accessToken) {
        [self performSelector:@selector(login) withObject:nil afterDelay:0];
    } else {
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
                [self performSelector:@selector(login) withObject:nil afterDelay:0];
            }
            [self closeSelf];
        };
        
        //获取token是否过期失败回调
        void (^failure_callback)(AFHTTPRequestOperation *operation, NSError *error) =
        ^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"Error: %@", error);
            [self performSelector:@selector(login) withObject:nil afterDelay:0];
        };
        
        //判断token是否过期POST请求
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setResponseSerializer:[AFTextResponseSerializer serializer]];
        NSDictionary *param = @{@"access_token":accessToken};
        [manager POST:@"https://api.weibo.com/oauth2/get_token_info" parameters:param success:success_callback failure:failure_callback];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeSelf
{
    [self performSegueWithIdentifier:@"authorize" sender:self];
}

@end
