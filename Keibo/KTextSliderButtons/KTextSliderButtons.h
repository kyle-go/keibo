//
//  KTextSliderButtonsView.h
//  TextSilderButtonDemo
//
//  Created by kyle on 2/22/14.
//  Copyright (c) 2014 github.com/kylescript. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KTextSilderButtonsDelegate <NSObject>

- (void)clickedButtonAtIndex:(NSUInteger)index;

@end

@interface KTextSliderButtons : UIView

- (void)setTextButtons:(NSString *)text, ... NS_REQUIRES_NIL_TERMINATION;

@property (nonatomic,assign) id<KTextSilderButtonsDelegate> delegate;

@end
