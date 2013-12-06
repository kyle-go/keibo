//
//  EmojiViewController.m
//  test
//
//  Created by kyle on 11/30/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "EmojiViewController.h"
#import "UICustomTapGestureRecognizer.h"
#import "OLImageView.h"
#import "OLImage.h"

#define EMOJI_BACKGROUND_COLOR [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];

@interface EmojiViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *viewControllers;
@end

@implementation EmojiViewController {
    NSUInteger pageCount;
}

#pragma mark---------------- private function --------------

//every page has 3*7-1 emoji most.
- (UIView *)getOnePage:(NSArray *)content fromIndex:(NSUInteger)index
{
    if (content.count <= index) {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
    view.backgroundColor = EMOJI_BACKGROUND_COLOR;
    NSUInteger allIndex = 0;
    for (NSUInteger i=index; i<content.count && allIndex<20; i++, allIndex++) {
        
        NSUInteger x = allIndex%7; //y = 0...6
        NSUInteger y = allIndex/7; //x = 0 1 2
        
        OLImageView *imageButton = [[OLImageView alloc] initWithFrame:CGRectMake(x*42 + 16, y*42 + 10, 36, 36)];
        imageButton.backgroundColor = EMOJI_BACKGROUND_COLOR;
        imageButton.image = [OLImage imageWithContentsOfFile:[content objectAtIndex:i]];
        
        [self addImageToView:view image:imageButton string:[content objectAtIndex:i]];
    }
    
    NSUInteger x = 6; //y = 0...6
    NSUInteger y = 2; //x = 0 1 2
    
    OLImageView *imageButton = [[OLImageView alloc] initWithFrame:CGRectMake(x*42 + 16, y*42 + 10, 36, 36)];
    imageButton.backgroundColor = EMOJI_BACKGROUND_COLOR;
    imageButton.image = [UIImage imageNamed:@"delete-emoji"];
    
    [self addImageToView:view image:imageButton string:@"delete-emoji"];
    
    return view;
}

- (void)addImageToView:(UIView *)view image:(UIImageView *)image string:(NSString *)string
{
    image.userInteractionEnabled = YES;
    UICustomTapGestureRecognizer *singleTap = [[UICustomTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.customString = string;
    [image addGestureRecognizer:singleTap];
    [view addSubview:image];
}


- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UICustomTapGestureRecognizer class]]) {
        NSLog(@"click = %@", ((UICustomTapGestureRecognizer*)gestureRecognizer).customString);
    } else {
        assert(NO);
        NSLog(@"click = unknown");
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageControl.backgroundColor = EMOJI_BACKGROUND_COLOR;
    
    self.viewControllers = [[NSMutableArray alloc] init];
    pageCount = (self.contentList.count+19)/20;
    for (NSUInteger i=0; i<pageCount; i++) {
        [self.viewControllers addObject:[NSNull null]];
    }
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame) * pageCount, CGRectGetHeight(self.scrollView.frame));;
    self.scrollView.scrollsToTop = NO;
    
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.currentPage = 0;
    
    for (int i=0; i<pageCount; i++) {
        [self loadScrollViewWithPage:i];
    }
    
    //[self loadScrollViewWithPage:0];
    //[self loadScrollViewWithPage:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= pageCount)
        return;
    
    // replace the placeholder if necessary
    UIView *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [self getOnePage:self.contentList fromIndex:page*20];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = CGRectGetWidth(frame) * page;
    frame.origin.y = 0;
    controller.frame = frame;
    [self.scrollView addSubview:controller];
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageControl.currentPage;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)changePage:(id)sender
{
    [self gotoPage:YES];    // YES = animate
}

@end
