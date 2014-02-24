//
//  PersonBasicNumberCell.m
//  Keibo
//
//  Created by kyle on 2/22/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "PersonBasicNumberCell.h"

@interface PersonBasicNumberCell()

@property (weak, nonatomic) IBOutlet UIButton *weibos;
@property (weak, nonatomic) IBOutlet UIButton *followings;
@property (weak, nonatomic) IBOutlet UIButton *fans;

@end

@implementation PersonBasicNumberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setWeibosNumber:(NSUInteger)weibos followings:(NSUInteger)followings fans:(NSUInteger)fans
{
    NSString *weibosString = [[NSString alloc] initWithFormat:@"%lu\n微博", weibos];
    NSString *followingsString = [[NSString alloc] initWithFormat:@"%lu\n关注", followings];
    NSString *fansString = [[NSString alloc] initWithFormat:@"%lu\n粉丝", fans];
    
    self.weibos.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.weibos.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.followings.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.fans.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    [self.weibos setTitle:weibosString forState:UIControlStateNormal];
    [self.followings setTitle:followingsString forState:UIControlStateNormal];
    [self.fans setTitle:fansString forState:UIControlStateNormal];
}

@end
