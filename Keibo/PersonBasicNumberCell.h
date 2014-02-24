//
//  PersonBasicNumberCell.h
//  Keibo
//
//  Created by kyle on 2/22/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonBasicNumberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *moreInfo;

- (void)setWeibosNumber:(NSUInteger)weiboCount followings:(NSUInteger)followings fans:(NSUInteger)fans;

@end
