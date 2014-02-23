//
//  PersonViewController.m
//  Keibo
//
//  Created by kyle on 13-10-31.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "PersonViewController.h"
#import "PersonHeaderCell.h"
#import "PersonBasicNumberCell.h"
#import "PersonWeiboTypeCell.h"
#import "UIUser.h"
#import "UIWeibo.h"

@interface PersonViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tView;

@end

@implementation PersonViewController {
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3 + [weiboData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *personHeaderIdentifier = @"personHeaderIdentifier";
    static NSString *personBasicNumberIdentifier = @"personBasicNumberIdentifier";
    static NSString *personWeiboTypeIdentifier = @"PersonWeiboTypeIdentifier";
    static NSString *weiboSimpleIdentifier = @"weiboSimpleIndentifier";
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [tableView registerNib:[UINib nibWithNibName:@"PersonHeaderCell" bundle:nil] forCellReuseIdentifier:personHeaderIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"PersonBasicNumberCell" bundle:nil] forCellReuseIdentifier:personBasicNumberIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"PersonWeiboTypeCell" bundle:nil] forCellReuseIdentifier:personWeiboTypeIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"WeiboSimpleCell" bundle:nil] forCellReuseIdentifier:weiboSimpleIdentifier];
    });
    
    switch (indexPath.row) {
        case 0: {
            PersonHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:personHeaderIdentifier];
            return cell;
        }
            break;
        case 1: {
            PersonBasicNumberCell *cell = [tableView dequeueReusableCellWithIdentifier:personBasicNumberIdentifier];
            return cell;
            
        }
            break;
        case 2: {
            PersonWeiboTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:personWeiboTypeIdentifier];
            [cell.textSlider setDefaultIndex:0 type:KTextSliderTypeAdjusted withTexts:@"全部", @"原创微博", nil];
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
    switch (indexPath.row) {
        case 0:
            return 80.0;
            break;
        case 1:
            return 40.0;
            break;
        case 2:
            return 36.0;
            break;
        default:
            break;
    }
    return 80.0;
}

@end
