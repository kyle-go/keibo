//
//  NewWeiboViewController.h
//  Keibo
//
//  Created by kyle on 11/25/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCPlaceholderTextView.h"

@interface NewWeiboViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *weiboTextView;
@property (weak, nonatomic) IBOutlet UIView *keyboardHelper;
@property (weak, nonatomic) IBOutlet UIButton *btnFace;

- (IBAction)actionBtnFace:(id)sender;

@end
