//
//  PersonViewController.m
//  Keibo
//
//  Created by kyle on 13-10-31.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "PersonViewController.h"
#import "UIUser.h"
#import "UIWeibo.h"

@interface PersonViewController ()

@end

@implementation PersonViewController {
    UITableView *tableView;
    UIUser *user;
    NSMutableArray *weiboData;
    NSMutableArray *weiboHeight;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我";
        [self.tabBarItem setImage:[UIImage imageNamed:@"tabbar_me"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 0, 320, 568-50);
    UIView *tempView = [[UIView alloc] initWithFrame:frame];
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,568-50) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tempView addSubview:tableView];
    [self.view addSubview:tempView];
    
    //
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
        case 2:
            return 1;
        case 3:
            return [weiboData count];
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView2 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *userInfoIdentifier = @"userInfoIdentifier";
    static NSString *userBasicNumberIdentifier = @"userBasicNumberIdentifier";
    static NSString *weiboTypeSelectorIdentifier = @"weiboTypeSelectorIdentifier";
    static NSString *weiboSimpleIdentifier = @"weiboSimpleIndentifier";
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [tableView registerNib:[UINib nibWithNibName:@"UserInfoCell" bundle:nil] forCellReuseIdentifier:userInfoIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"UserBasicNumberCell" bundle:nil] forCellReuseIdentifier:userBasicNumberIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"WeiboTypeSelectorCell" bundle:nil] forCellReuseIdentifier:weiboTypeSelectorIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"WeiboSimpleCell" bundle:nil] forCellReuseIdentifier:weiboSimpleIdentifier];
    });
    
    switch (indexPath.section) {
        case 0: {
            id cell = [tableView dequeueReusableCellWithIdentifier:userInfoIdentifier];
            return cell;
        }
            break;
        case 1: {
            id cell = [tableView dequeueReusableCellWithIdentifier:userBasicNumberIdentifier];
            return cell;
            
        }
            break;
        case 2: {
            id cell = [tableView dequeueReusableCellWithIdentifier:weiboTypeSelectorIdentifier];
            return cell;
        }
            break;
        case 3: {
            id cell = [tableView dequeueReusableCellWithIdentifier:weiboSimpleIdentifier];
            return cell;
        }
            break;
        default:
            break;
    }
    
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

@end
