//
//  KTextSliderButtonsView.m
//  TextSilderButtonDemo
//
//  Created by kyle on 2/22/14.
//  Copyright (c) 2014 github.com/kylescript. All rights reserved.
//

#import "KTextSliderButtons.h"

#define btnWidthSpace 8.0
#define btnNormalColor [UIColor lightGrayColor]
#define btnSelectedColor [UIColor darkGrayColor]
#define indicatorColor [UIColor colorWithRed:0.0 green:128.0/255.0 blue:1.0 alpha:1.0]

@implementation KTextSliderButtons
{
    UILabel *_indicator;
    NSMutableArray *_buttons;
    NSMutableArray *_btnWidths;
    CGFloat _btnHeight;
    CGFloat _btnWidth;
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
    _btnWidth = self.frame.size.width / btnCount;
    _btnHeight = self.frame.size.height - 2;
    _buttons = [[NSMutableArray alloc] init];
    _btnWidths = [[NSMutableArray alloc] init];
    
    //自动调整按钮大小
    if (type == KTextSliderTypeAdjusted) {
        CGFloat widthCount = btnWidthSpace;
        for (NSInteger i=0; i<btnCount; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(widthCount, 8, 1, 1)];
            label.text = [paramList objectAtIndex:i];
            label.font = [UIFont systemFontOfSize:13.0];
            label.textColor = btnNormalColor;
            label.textAlignment = NSTextAlignmentCenter;
            //label.backgroundColor = [UIColor greenColor];
            
            if (i == defaultIndex) {
                label.textColor = btnSelectedColor;
            }
            [_buttons addObject:label];
            
            [label sizeToFit];
            
            //细节微调
            CGRect rect = label.frame;
            rect.size.height += 20;
            label.frame = rect;
            [_btnWidths addObject:[[NSNumber alloc] initWithFloat:label.frame.size.width]];
            widthCount += label.frame.size.width + btnWidthSpace;
            
            label.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClick:)];
            [label addGestureRecognizer:tapGestureRecognizer];
            
            [self addSubview:label];
        }
        
        CGFloat left = [self countArray:_btnWidths count:defaultIndex];
        _indicator = [[UILabel alloc] initWithFrame:CGRectMake(left + btnWidthSpace*(defaultIndex + 1), _btnHeight+1, [[_btnWidths objectAtIndex:defaultIndex] floatValue], 2)];
        _indicator.backgroundColor = indicatorColor;
        [self addSubview:_indicator];
    } else {
        for (NSInteger i=0; i<btnCount; i++) {
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*_btnWidth, 0, _btnWidth, _btnHeight)];
            label.text = [paramList objectAtIndex:i];
            label.textColor = btnNormalColor;
            label.userInteractionEnabled = YES;
            label.textAlignment = NSTextAlignmentCenter;
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClick2:)];
            [label addGestureRecognizer:tapGestureRecognizer];
            if (i == defaultIndex) {
                label.textColor = btnSelectedColor;
            }
            [_buttons addObject:label];
            
            [self addSubview:label];
        }
        
        _indicator = [[UILabel alloc] initWithFrame:CGRectMake(_btnWidth*defaultIndex, _btnHeight, _btnWidth, 2)];
        _indicator.backgroundColor = indicatorColor;
        [self addSubview:_indicator];
    }
}

- (void)btnClick:(UITapGestureRecognizer *)gesture
{
    UILabel *label = (UILabel *)gesture.view;
    NSUInteger i = 0;
    NSUInteger index = 0;
    for (UILabel *button in _buttons) {
        button.textColor = btnNormalColor;
        if (button == label) {
            index = i;
        }
        i++;
    }
    label.textColor = btnSelectedColor;
    [UIView animateWithDuration:0.3 animations:^(void){
        
        CGFloat left = [self countArray:_btnWidths count:index];
        _indicator.frame = CGRectMake(left + btnWidthSpace*(index + 1), _btnHeight, [[_btnWidths objectAtIndex:index] floatValue], 2);
    }];
    
    [self.delegate textSliderButtons:self clickedButtonAtIndex:index];
}

- (void)btnClick2:(UITapGestureRecognizer *)gesture
{
    UILabel *label = (UILabel *)gesture.view;
    NSUInteger i = 0;
    NSUInteger index = 0;
    for (UILabel *button in _buttons) {
        button.textColor = btnNormalColor;
        if (button == label) {
            index = i;
        }
        i++;
    }

    label.textColor = btnSelectedColor;
    [UIView animateWithDuration:0.3 animations:^(void){
        _indicator.frame = CGRectMake(index*_btnWidth, _btnHeight, _btnWidth, 2);
    }];
    
    [self.delegate textSliderButtons:self clickedButtonAtIndex:index];
}

@end
