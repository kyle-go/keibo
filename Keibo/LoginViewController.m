//
//  KSLoginViewController.m
//  Keibo
//
//  Created by kyle on 13-10-3.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "LoginViewController.h"
#import "WeiboSDK.h"
#import "DataModel.h"
#import "AFNetworking.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)login
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectURI;
    request.scope = @"email,direct_messages_write";
    request.userInfo = @{@"SSO_From": @"LoginViewController"};
    [WeiboSDK sendRequest:request];
}

- (void)viewWillAppear:(BOOL)animated
{
    //获取好友列表成功回调
    void (^success_callback) (AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    };
    
    //获取好友列表失败回调
    void (^failure_callback)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
    };
    
    NSString * accessToken = [DataModel getAccessToken];
    if (accessToken) {
        //判断token是否过期
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *url = [[NSString alloc] initWithFormat:@"https://api.weibo.com/oauth2/get_token_info?access_token=%@", accessToken];
        [manager GET:url parameters:nil success:success_callback failure:failure_callback];
    } else {
        [self performSegueWithIdentifier:@"login_jump" sender:self];
    }
}

@end
