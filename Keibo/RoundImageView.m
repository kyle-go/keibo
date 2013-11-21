//
//  RoundImageView.m
//  Keibo
//
//  Created by kyle on 11/16/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "RoundImageView.h"

@implementation RoundImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2.0f;
    self.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = CGRectGetWidth(self.bounds)/2.0f;
}

+ (RoundImageView *)RoundImageView:(UIImage *)image
{
    RoundImageView *imageView = [[RoundImageView alloc] initWithImage:image];
    imageView.layer.masksToBounds = YES;
    return imageView;
}

@end
