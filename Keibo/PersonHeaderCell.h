//
//  PersonHeaderCell.h
//  Keibo
//
//  Created by kyle on 2/22/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIUser.h"

@interface PersonHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *detailInfo;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

- (void)setValuesWithUserInfo:(UIUser *)user;
+ (CGFloat)rightHeight:(UIUser *)user;

@end
