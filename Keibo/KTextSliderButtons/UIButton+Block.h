//
//  UIButton+Block.h
//  TextSilderButtonDemo
//
//  Created by kyle on 2/22/14.
//  Copyright (c) 2014 github.com/kylescript. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void (^ActionBlock)();

@interface UIButton (Block)

@property (readonly) NSMutableDictionary *event;

- (void) handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;

@end
