//
//  KTextSliderButtonsView.m
//  TextSilderButtonDemo
//
//  Created by kyle on 2/22/14.
//  Copyright (c) 2014 github.com/kylescript. All rights reserved.
//

#import "KTextSliderButtons.h"
#import "UIButton+Block.h"

#define btnWidthSpace 8.0
#define btnNormalColor [UIColor lightGrayColor]
#define btnSelectedColor [UIColor darkGrayColor]
#define indicatorColor [UIColor colorWithRed:0.0 green:128.0/255.0 blue:1.0 alpha:1.0]

@implementation KTextSliderButtons
{
    UILabel *_indicator;
    NSMutableArray *_buttons;
    NSMutableArray *_btnWidths;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGFloat)countArray:(NSArray *)array count:(NSUInteger)count
{
    CGFloat result = 0.0;
    for (NSUInteger i=0; i<count; i++) {
        result += [[array objectAtIndex:i] floatValue];
    }
    return result;
}

- (void)setDefaultIndex:(NSUInteger)defaultIndex type:(KTextSliderType)type withTexts:(NSString *)text, ...
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    va_list args;
    va_start(args, text);
    NSMutableArray *paramList = [[NSMutableArray alloc] init];
    for (NSString *param=text; param != nil; param = va_arg(args, NSString*)) {
        [paramList addObject:param];
    }
    va_end(args);
    
    NSInteger btnCount = [paramList count];
    CGFloat btnWidth = self.frame.size.width / btnCount;
    CGFloat btnHeight = self.frame.size.height - 2;
    _buttons = [[NSMutableArray alloc] init];
    _btnWidths = [[NSMutableArray alloc] init];
    
    //自动调整按钮大小
    if (type == KTextSliderTypeAdjusted) {
        CGFloat widthCount = btnWidthSpace;
        for (NSInteger i=0; i<btnCount; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.frame = CGRectMake(widthCount, 0, btnWidth, btnHeight);
            [btn setTitle:[paramList objectAtIndex:i] forState:UIControlStateNormal];
            btn.titleLabel.textColor = btnNormalColor;
            btn.tintColor = btnNormalColor;
            if (i == defaultIndex) {
                btn.tintColor = btnSelectedColor;
            }
            [_buttons addObject:btn];
            
            [btn sizeToFit];
            [_btnWidths addObject:[[NSNumber alloc] initWithFloat:btn.frame.size.width]];
            widthCount += btn.frame.size.width + btnWidthSpace;
            
            [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(void){
                for (UIButton *button in _buttons) {
                    button.titleLabel.textColor = btnNormalColor;
                }
                btn.highlighted = NO;
                btn.titleLabel.textColor = btnSelectedColor;
                btn.tintColor = btnSelectedColor;
                [UIView animateWithDuration:0.3 animations:^(void){
                    
                    CGFloat left = [self countArray:_btnWidths count:i];
                    _indicator.frame = CGRectMake(left + btnWidthSpace*(i + 1), btnHeight, [[_btnWidths objectAtIndex:i] floatValue], 2);
                }];
                
                [self.delegate textSliderButtons:self clickedButtonAtIndex:i];
            }];
            [self addSubview:btn];
        }
        
        CGFloat left = [self countArray:_btnWidths count:defaultIndex];
        _indicator = [[UILabel alloc] initWithFrame:CGRectMake(left + btnWidthSpace*(defaultIndex + 1), btnHeight, [[_btnWidths objectAtIndex:defaultIndex] floatValue], 2)];
        _indicator.backgroundColor = indicatorColor;
        [self addSubview:_indicator];
    } else {
        for (NSInteger i=0; i<btnCount; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.frame = CGRectMake(i*btnWidth, 0, btnWidth, btnHeight);
            [btn setTitle:[paramList objectAtIndex:i] forState:UIControlStateNormal];
            btn.titleLabel.textColor = btnNormalColor;
            btn.tintColor = btnNormalColor;
            if (i == defaultIndex) {
                btn.tintColor = btnSelectedColor;
            }
            [_buttons addObject:btn];
            
            [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(void){
                for (UIButton *button in _buttons) {
                    button.titleLabel.textColor = btnNormalColor;
                }
                btn.highlighted = NO;
                btn.titleLabel.textColor = btnSelectedColor;
                btn.tintColor = btnSelectedColor;
                [UIView animateWithDuration:0.3 animations:^(void){
                    _indicator.frame = CGRectMake(i*btnWidth, btnHeight, btnWidth, 2);
                }];
                
                [self.delegate textSliderButtons:self clickedButtonAtIndex:i];
            }];
            [self addSubview:btn];
        }
        
        _indicator = [[UILabel alloc] initWithFrame:CGRectMake(btnWidth*defaultIndex, btnHeight, btnWidth, 2)];
        _indicator.backgroundColor = indicatorColor;
        [self addSubview:_indicator];
    }
}

@end
