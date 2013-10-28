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
    NSString * accessToken = [DataModel getAccessToken];
    if (accessToken) {
    }
}

@end
