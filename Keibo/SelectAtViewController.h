//
//  SelectAtViewController.h
//  Keibo
//
//  Created by kyle on 12/7/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedUsersDelegate <NSObject>

- (void)selectedUsers:(NSArray *)users;

@end

@interface SelectAtViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<SelectedUsersDelegate> delegate;

@end
