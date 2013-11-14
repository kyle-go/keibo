//
//  LeftViewController.m
//  Keibo
//
//  Created by kyle on 13-10-31.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "LeftViewController.h"
#import "UIUser.h"

@interface LeftViewController ()

@end

@implementation LeftViewController {
    NSArray *defaultSectionNames;
    NSArray *sectionNames;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        defaultSectionNames = [[NSArray alloc] initWithObjects: @"全部微博", @"提到我", @"评论", @"私信", @"收藏", @"搜索", nil];
        sectionNames = [[NSArray alloc] initWithObjects:@"", @"分组", @"话题", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freshLoginUser:) name:@"freshLoginUser" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)freshLoginUser:(NSNotification *)notify
{
    NSDictionary *params = notify.userInfo;
    UIUser *user = [params objectForKey:@"user"];
    //fresh with user....
}

#pragma mark -- table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [defaultSectionNames count];
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 1;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionNames objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [defaultSectionNames objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"互粉微博";
    } else if (indexPath.section == 2) {
       cell.textLabel.text = @"热门话题";
    }
    
    return cell;
}


//设置section头部
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

@end
