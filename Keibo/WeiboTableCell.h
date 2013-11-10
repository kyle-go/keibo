//
//  WeiboTableCell.h
//  Keibo
//
//  Created by kyle on 11/8/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WeiboCellData;

@interface WeiboTableCell : UITableViewCell

- (void)updateWithWeiboData:(WeiboCellData *)data;

@end
