//
//  NewWeiboViewController.m
//  Keibo
//
//  Created by kyle on 11/25/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "NewWeiboViewController.h"

@interface NewWeiboViewController ()

@end

@implementation NewWeiboViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    //keyboardHelperBar添加按钮
    UIButton *btnTest = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [btnTest setTitle:@"Test" forState:UIControlStateNormal];
    [btnTest setBackgroundColor:[UIColor redColor]];
    [btnTest addTarget:self action:@selector(targetTest:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.keyboardHelperBar addSubview:btnTest];
    
    
    [self.weiboTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)targetTest:(id)sender
{
    [self.weiboTextView resignFirstResponder];
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

- (void) moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         CGRect frame = self.keyboardHelperBar.frame;
                         frame.origin.y = height - 65 + 18;
                         self.keyboardHelperBar.frame= frame;
                     }];
}

- (void)Cancel
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)SendWeibo
{
    [self Cancel];
}

@end
