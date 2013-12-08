//
//  NewWeiboViewController.h
//  Keibo
//
//  Created by kyle on 11/25/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTextViewPlaceholder.h"
#import "EmojiViewController.h"
#import "SelectAtViewController.h"

@interface NewWeiboViewController : UIViewController <UITextViewDelegate, EmojiDidClickDelegate, SelectedUsersDelegate>

@property (weak, nonatomic) IBOutlet KTextViewPlaceholder *weiboTextView;
@property (weak, nonatomic) IBOutlet UIView *keyboardHelper;
@property (weak, nonatomic) IBOutlet UIButton *btnFace;
@property (weak, nonatomic) IBOutlet UIScrollView *changeEmojiScrollView;

- (IBAction)actionBtnFace:(id)sender;
- (IBAction)actionBtnAt:(id)sender;

@end
