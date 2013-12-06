//
//  EmojiViewController.h
//  test
//
//  Created by kyle on 11/30/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmojiDidClickDelegate <NSObject>

- (void)emojiDidClicked:(NSString *)emoji;

@end

@interface EmojiViewController : UIViewController

@property (nonatomic, weak) id<EmojiDidClickDelegate> delegate;
@property (nonatomic, strong) NSArray *contentList;

@end
