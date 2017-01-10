//
//  InputBoxOptionView.m
//  LoochaCampusMain
//
//  Created by zhang jinquan on 7/1/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import "InputBoxOptionView.h"
#import <EMSpeed/MSUIKitCore.h>
#define kItemWidth 60
#define KItemHeigth 80
#define kMarginX   15
#define kViewGap    10
#define kCountWidth 10

@implementation InputBoxOptionView
{
    NSMutableArray *_countBtnList;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
}

-(void)dealloc
{
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame options:kInputBoxOption_Default];
}

- (instancetype)initWithFrame:(CGRect)frame options:(InputBoxOption)options
{
    options = (InputBoxOption) (options & kInputBoxOption_Mask_OnOptionBoard);
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        bgView.image = [[UIImage imageNamed:@"inputbox_bar_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(44, 3, 0, 3)];
        [self addSubview:bgView];
        
        CGFloat gapX = (frame.size.width - kMarginX*2 - kItemWidth*4)/3;
        CGFloat gapY = (frame.size.height - KItemHeigth *2)/3;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:_scrollView];
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        
        _countBtnList = [[NSMutableArray alloc] initWithCapacity:4];
        int i = 0;
        for (int offset = 0; options; offset++) {
            InputBoxOption option = InputBoxOption( 1<< offset);
            if (options & option) {
                CGFloat x = frame.size.width * (i/8) + kMarginX + (gapX + kItemWidth)*(i%4);
                CGFloat y = gapY + (gapY + KItemHeigth)*((i%8)/4);
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, kItemWidth, KItemHeigth)];
                [_scrollView addSubview:btn];
                btn.tag = option;
                [self configItem:btn];
                
                UIButton *countBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kCountWidth, kCountWidth)];
                countBtn.center = CGPointMake(CGRectGetMaxX(btn.frame), y);
                countBtn.backgroundColor =RGB(240, 0, 20);
                //RCColorWithValue(0xe60012);
                countBtn.layer.cornerRadius = kCountWidth/2;
                countBtn.clipsToBounds = YES;
                countBtn.userInteractionEnabled = NO;
                countBtn.hidden = YES;
                countBtn.titleLabel.font = [UIFont systemFontOfSize:10];
                countBtn.tag = option;
                [_scrollView addSubview:countBtn];
                [_countBtnList addObject:countBtn];
                options =(InputBoxOption ) (options & ~option);
                i++;
            }
        }
        int pageCount = (i + 7)/8;
        _scrollView.contentSize = CGSizeMake(frame.size.width*pageCount, frame.size.height);
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - gapY, frame.size.width, gapY)];
        [self addSubview:_pageControl];
        _pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.numberOfPages = pageCount;
        _pageControl.hidesForSinglePage = YES;
        [_pageControl addTarget:self action:@selector(actionPageControl) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)actionPageControl
{
    CGRect r = _scrollView.frame;
    r.origin.x = r.size.width*_pageControl.currentPage;
    [_scrollView scrollRectToVisible:r animated:YES];
}

- (void)configItem:(UIButton *)btn
{
    NSString *imageName = nil;
    NSString *touchImageName = nil;
    switch (btn.tag) {
        case kInputBoxOption_Voice:
            imageName = @"inputbox_option_voice";
            touchImageName = @"inputbox_option_voice_touch";
            break;
            
        case kInputBoxOption_PickPhoto:
            imageName = @"inputbox_option_pickphoto";
            touchImageName = @"inputbox_option_pickphoto_touch";
            break;
            
        case kInputBoxOption_TakePhoto:
            imageName = @"inputbox_option_takephoto";
            touchImageName = @"inputbox_option_takephoto_touch";
            break;
            
        case kInputBoxOption_PickVideo:
            imageName = @"inputbox_option_pickvideo";
            touchImageName = @"inputbox_option_pickvideo_touch";
            break;
            
        case kInputBoxOption_TakeVideo:
            imageName = @"inputbox_option_takevideo";
            touchImageName = @"inputbox_option_takevideo_touch";
            break;
            
        case kInputBoxOption_Music:
            imageName = @"inputbox_option_music";
            touchImageName = @"inputbox_option_music_touch";
            break;
            
        default:
            break;
    }
    [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:touchImageName] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionItem:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)actionItem:(UIButton *)btn
{
    [self.delegate didSelectInputBoxOption:(InputBoxOption)btn.tag];
}

- (void)updateCount:(NSInteger)count option:(InputBoxOption)option
{
    for (UIButton *btn in _countBtnList) {
        if (btn.tag == option) {
            if (count == 0) {
                btn.hidden = YES;
            }
            else {
                btn.hidden = NO;
                [btn setTitle:[NSString stringWithFormat:@"%d", count] forState:UIControlStateNormal];
            }
        }
    }
}

- (void)showNewTip:(BOOL)show option:(InputBoxOption)option
{
    for (UIButton *btn in _countBtnList) {
        if (btn.tag == option) {
            btn.hidden = !show;
        }
    }
}

- (void)reset
{
    for (UIButton *btn in _countBtnList) {
        btn.hidden = YES;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _pageControl.currentPage = (scrollView.contentOffset.x + scrollView.frame.size.width/2)/scrollView.frame.size.width;
}

+ (CGFloat)viewHeight
{
    return 216;
}

@end
