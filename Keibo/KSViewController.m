//
//  KSViewController.m
//  Keibo
//
//  Created by kyle on 13-9-29.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KSViewController.h"

@interface KSViewController ()

@end

@implementation KSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITabBarItem *barItem = [self tabBarItem];
    [barItem setTitle:@"首页"];
    UIImage *image = [UIImage imageNamed:@"HomePageIcon"];
    [barItem setImage:image];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
