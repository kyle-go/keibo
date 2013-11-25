//
//  NewWeiboViewController.m
//  Keibo
//
//  Created by kyle on 11/25/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "NewWeiboViewController.h"

@interface NewWeiboViewController ()

@end

@implementation NewWeiboViewController

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
    
    self.title = @"发微博";
    self.weiboTextView.placeholder = @"分享新鲜事...";
    [self.weiboTextView becomeFirstResponder];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(Cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(SendWeibo)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)Cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)SendWeibo
{
    [self Cancel];
}

@end
