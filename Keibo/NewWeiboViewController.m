//
//  NewWeiboViewController.m
//  Keibo
//
//  Created by kyle on 11/25/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "NewWeiboViewController.h"
#import "EmojiViewController.h"
#import "SVSegmentedControl.h"

#define EMOJI_VIEW_HEIGHT 190

@interface NewWeiboViewController ()

@end

@implementation NewWeiboViewController {
    
    BOOL bIsFaceIcon;
    UIView *emojiView;
    EmojiViewController *controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        bIsFaceIcon = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"发微博";
    self.weiboTextView.placeholder = @"分享新鲜事...";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(Cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(SendWeibo)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];

    //keyboardHelper 添加背景图片
    CGRect frame = self.keyboardHelper.frame;
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    bgImgView.image = [UIImage imageNamed:@"kb_background"];
    [self.keyboardHelper addSubview:bgImgView];
    [self.keyboardHelper sendSubviewToBack:bgImgView];
    
    self.keyboardHelper.frame = CGRectMake(0, 568-45, 320, 50);
    [self.view addSubview:self.keyboardHelper];
    [self performSelector:@selector(setWeiboTextViewFirstResponse) withObject:nil afterDelay:0.0];
    
    //emoji files.
    NSError *error = nil;
    NSArray *filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Emoji-Default.bundle"] error:&error];
    
    NSMutableArray *paramArray = [[NSMutableArray alloc] init];
    for (NSString *name in filesArray) {
        NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/Emoji-Default.bundle/%@", name];
        [paramArray addObject:filePath];
    }
    
    //emoji view
    emojiView = [[UIView alloc] initWithFrame:CGRectMake(0, 568, 320, EMOJI_VIEW_HEIGHT)];
    emojiView.backgroundColor = [UIColor lightGrayColor];
    controller = [[EmojiViewController alloc] init];
    controller.contentList = paramArray;
    
    [emojiView addSubview:controller.view];
    self.changeEmojiScrollView.frame = CGRectMake(0, 152, 320, 38);
    self.changeEmojiScrollView.contentSize = CGSizeMake(321, 38);
    [emojiView addSubview:self.changeEmojiScrollView];
    
    NSArray * btns = [NSArray arrayWithObjects:@"常用", @"默认", @"+", nil];
    SVSegmentedControl *navSC = [[SVSegmentedControl alloc] initWithSectionTitles:btns];
    navSC.height = 40;
    navSC.thumbEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0);
    navSC.cornerRadius = 0.0;
    
    navSC.frame = CGRectMake(0, 0, 150, 38);
    [self.changeEmojiScrollView addSubview:navSC];
}

- (void)setWeiboTextViewFirstResponse
{
    [self.weiboTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveInputBarWithKeyboardHeight:keyboardRect.origin.y withDuration:animationDuration];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self moveInputBarWithKeyboardHeight:568 withDuration:animationDuration];
}

#pragma mark -
#pragma mark moveInputBarWithKeyboardHeight
- (void) moveInputBarWithKeyboardHeight:(CGFloat)posY withDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration
                     animations:^{
                         CGRect frame = self.keyboardHelper.frame;
                         frame.origin.y = posY - 44;
                         self.keyboardHelper.frame = frame;
                     }];
}

#pragma mark -
#pragma mark action inputbar buttons
- (IBAction)actionBtnFace:(id)sender {
    if (bIsFaceIcon) {
        bIsFaceIcon = NO;
        [self.btnFace setImage:[UIImage imageNamed:@"kb_keyboard"] forState:UIControlStateNormal];
        
        //dismiss keyboard
        self.weiboTextView.inputView = emojiView;
        [UIView animateWithDuration:0.2
                         animations:^{[ self.weiboTextView reloadInputViews]; }
                         completion:^(BOOL finished){ /*Do something here if you want.*/ }];
    } else {
        bIsFaceIcon = YES;
        [self.btnFace setImage:[UIImage imageNamed:@"kb_face"] forState:UIControlStateNormal];
        
        //show keyboard
        self.weiboTextView.inputView = nil;
        [UIView animateWithDuration:0.2
                         animations:^{[ self.weiboTextView reloadInputViews]; }
                         completion:^(BOOL finished){ /*Do something here if you want.*/ }];
    }
}

#pragma mark -
#pragma mark action others
- (void)Cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)SendWeibo
{
    [self Cancel];
}


@end
