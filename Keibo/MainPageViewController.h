//
//  MainPageViewController.h
//  Keibo
//
//  Created by kyle on 13-10-31.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

@interface MainPageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableDelegate>

@end
