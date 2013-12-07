//
//  NewWeiboViewController.m
//  Keibo
//
//  Created by kyle on 11/25/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "NewWeiboViewController.h"
#import "SelectAtViewController.h"
#define EMOJI_VIEW_HEIGHT 190

@interface NewWeiboViewController ()

@end

@implementation NewWeiboViewController {
    
    BOOL bIsFaceIcon;
    UIView *emojiView;
    EmojiViewController *emojiViewController;
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
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //keyboardHelper 添加背景图片
    CGRect frame = self.keyboardHelper.frame;
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    bgImgView.image = [UIImage imageNamed:@"kb_background"];
    [self.keyboardHelper addSubview:bgImgView];
    [self.keyboardHelper sendSubviewToBack:bgImgView];
    self.keyboardHelper.frame = CGRectMake(0, 568-45, 320, 50);
    [self.view addSubview:self.keyboardHelper];
    
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
    emojiViewController = [[EmojiViewController alloc] init];
    emojiViewController.delegate = self;
    emojiViewController.contentList = paramArray;
    
    [emojiView addSubview:emojiViewController.view];
    self.changeEmojiScrollView.frame = CGRectMake(0, 152, 320, 38);
    self.changeEmojiScrollView.contentSize = CGSizeMake(321, 38);
    [emojiView addSubview:self.changeEmojiScrollView];
    
    
    NSArray * btns = [NSArray arrayWithObjects:@"常用", @"默认", @"+", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:btns];
	segmentedControl.frame = CGRectMake(0, 0, 270, 38);
    segmentedControl.tintColor = [UIColor grayColor];
    [self.changeEmojiScrollView addSubview:segmentedControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.weiboTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark emoji did click delegate
- (void)emojiDidClicked:(NSString *)emoji
{
    //删除表情
    if ([emoji isEqualToString:@"delete-emoji"]) {
        NSString *regexString = @"\\[\\w+\\]$";
        NSString *text = self.weiboTextView.text;
        NSRange range = [text rangeOfString:regexString options:NSRegularExpressionSearch];
        if (range.location != NSNotFound && (range.location + range.length) == text.length) {
            self.weiboTextView.text = [text substringWithRange:NSMakeRange(0, range.location)];
        }
        
        return;
    }
    
    //匹配 "xxxx[BOBO爱你].gif"
    NSString *regexString = @"\\[\\w+\\].gif$";
    NSRange range = [emoji rangeOfString:regexString options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        NSString *matched = [emoji substringWithRange:NSMakeRange(range.location, range.length - 4)];
        self.weiboTextView.text = [self.weiboTextView.text stringByAppendingString:matched];
        
        return;
    }
    
    //sth unexpected.
    abort();
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
                         completion:nil];
    }
}

- (IBAction)actionBtnAt:(id)sender {
    SelectAtViewController *selectAtViewController = [[SelectAtViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:selectAtViewController];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.weiboTextView resignFirstResponder];
                         [self presentViewController:nav animated:YES completion:nil];
                     }
                     completion:nil];
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
