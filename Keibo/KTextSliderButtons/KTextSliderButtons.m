//
//  KTextSliderButtonsView.m
//  TextSilderButtonDemo
//
//  Created by kyle on 2/22/14.
//  Copyright (c) 2014 github.com/kylescript. All rights reserved.
//

#import "KTextSliderButtons.h"
#import "UIButton+Block.h"

#define btnNormalColor [UIColor lightGrayColor]
#define btnSelectedColor [UIColor darkGrayColor]
#define indicatorColor [UIColor colorWithRed:0.0 green:128.0/255.0 blue:1.0 alpha:1.0]

@implementation KTextSliderButtons
{
    CGFloat _btnWidth;
    UILabel *_indicator;
    NSMutableArray *_buttons;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setTextButtons:(NSString *)text, ...
{
    va_list args;
    va_start(args, text);
    NSMutableArray *paramList = [[NSMutableArray alloc] init];
    for (NSString *param=text; param != nil; param = va_arg(args, NSString*)) {
        [paramList addObject:param];
    }
    va_end(args);
    
    NSInteger count = [paramList count];
    _btnWidth = self.frame.size.width / count;
    CGFloat btnHeight = self.frame.size.height - 2;

    for (id button in _buttons) {
        [button removeFromSuperview];
    }
    _buttons = [[NSMutableArray alloc] init];
    
    for (NSInteger i=0; i<count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(i*_btnWidth, 0, _btnWidth, btnHeight);
        [btn setTitle:[paramList objectAtIndex:i] forState:UIControlStateNormal];
        btn.titleLabel.textColor = btnNormalColor;
        btn.tintColor = btnNormalColor;
        if (i == 0) {
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
                _indicator.frame = CGRectMake(i*_btnWidth, btnHeight, _btnWidth, 2);
            }];
            
            [self.delegate clickedButtonAtIndex:i];
        }];
        [self addSubview:btn];
    }
    
    [_indicator removeFromSuperview];
    _indicator = [[UILabel alloc] initWithFrame:CGRectMake(0, btnHeight, _btnWidth, 2)];
    _indicator.backgroundColor = indicatorColor;
    [self addSubview:_indicator];
}

@end
