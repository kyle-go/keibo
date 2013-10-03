//
//  KSLoginViewController.m
//  Keibo
//
//  Created by kyle on 13-10-3.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KSLoginViewController.h"
#import "WeiboSDK.h"

@interface KSLoginViewController ()

@end

@implementation KSLoginViewController

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
    request.userInfo = @{@"SSO_From": @"KSLoginViewController"};
    [WeiboSDK sendRequest:request];
}

@end
