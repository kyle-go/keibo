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

@implementation MessageViewController {
    UIView *currentView;
    UITableView *viewMe;
    UITableView *viewComments;
    UITableView *viewMails;
}

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
	segmentedControl.frame = CGRectMake(0, 0, 160, 30);
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
	self.navigationItem.titleView = segmentedControl;
    
    //init table views
    viewMe = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, 456)];
    viewMe.backgroundColor = [UIColor blackColor];
    viewComments = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, 456)];
    viewComments.backgroundColor = [UIColor redColor];
    viewMails = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, 456)];
    viewMails.backgroundColor = [UIColor grayColor];
    
    currentView = viewMe;
    //[self.view addSubview:currentView];
    
    [self performSelector:@selector(delayAddSubView_Bug:) withObject:currentView afterDelay:0];
}

- (void)delayAddSubView_Bug:(UIView*)view {
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLeftView {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)segmentAction:(UISegmentedControl *)seg
{
    [currentView removeFromSuperview];
    switch (seg.selectedSegmentIndex) {
        case 0:
            currentView = viewMe;
            break;
        case 1:
            currentView = viewComments;
            break;
        case 2:
            currentView = viewMails;
            break;
        default:
            break;
    }
    //[self.view addSubview:currentView];
    [self performSelector:@selector(delayAddSubView_Bug:) withObject:currentView afterDelay:0];
}

#pragma mark -- table view delegate
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

@end
