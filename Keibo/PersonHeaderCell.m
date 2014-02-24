//
//  PersonHeaderCell.m
//  Keibo
//
//  Created by kyle on 2/22/14.
//  Copyright (c) 2014 kyle. All rights reserved.
//

#import "PersonHeaderCell.h"

@implementation PersonHeaderCell

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

- (IBAction)detailClick:(id)sender {
}
@end
