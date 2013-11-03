//
//  MessageViewController.m
//  Keibo
//
//  Created by kyle on 13-10-31.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "MessageViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

@interface MessageViewController ()

@end

@implementation MessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"消息";
        [self.tabBarItem setImage:[UIImage imageNamed:@"demo"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //添加左按钮
    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc]
                                             initWithTarget:self action:@selector(showLeftView)];
    
    NSArray *segmentTextContent = [NSArray arrayWithObjects:
                                   @"@我",
                                   @"评论",
                                   @"私信",
								   nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.selectedSegmentIndex = 0;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.frame = CGRectMake(0, 0, 400, 30);
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
	self.navigationItem.titleView = segmentedControl;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)segmentAction:(UISegmentedControl *)seg
{
    NSLog(@"%d", seg.selectedSegmentIndex);
}

- (void)showLeftView {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

@end
