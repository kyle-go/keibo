//
//  KTextSliderButtonsView.h
//  TextSilderButtonDemo
//
//  Created by kyle on 2/22/14.
//  Copyright (c) 2014 github.com/kylescript. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, KTextSliderType) {
    KTextSliderTypeAdjusted = 0,                //根据字符串自动调整按钮宽度大小
    KTextSliderTypeEvenly,                    //根据view宽度平均分割按钮宽度
};

@class KTextSliderButtons;

@protocol KTextSilderButtonsDelegate <NSObject>

- (void)textSliderButtons:(KTextSliderButtons *)buttons clickedButtonAtIndex:(NSUInteger)index;

@end

@interface KTextSliderButtons : UIView

- (void)setDefaultIndex:(NSUInteger)defaultIndex type:(KTextSliderType)type withTexts:(NSString *)text, ...NS_REQUIRES_NIL_TERMINATION;

@property (nonatomic,assign) id<KTextSilderButtonsDelegate> delegate;

@end
