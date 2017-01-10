 
//  BaseViewController.m
//  LoochaUtilities
//
//  Created by xiuwei ding on 12-9-25.
//  Copyright (c) 2012年 realcloud. All rights reserved.
//

#import "BaseViewController.h"
#import <objc/message.h>

@implementation NavigationBarStyle

@synthesize hidden;
@synthesize barStyle;
@synthesize translucent;
@synthesize tintColor;

- (id)initWithNavigationController:(UINavigationController *)navigationController
{
    self = [super init];
    if (self) {
        if (navigationController) {
            self.hidden = navigationController.navigationBarHidden;
            UINavigationBar *bar = navigationController.navigationBar;
            if (bar) {
                self.translucent = bar.translucent;
                
#ifdef __IPHONE_7_0
                self.tintColor = bar.barTintColor;
#else
                self.tintColor = bar.tintColor;
#endif
                
                self.barStyle = bar.barStyle;
            }
        }
    }
    return self;
}

- (void)configNavigationController:(UINavigationController *)navigationController animated:(BOOL)animated
{
    if (navigationController) {
        if (self.hidden != navigationController.navigationBarHidden) {
            [navigationController setNavigationBarHidden:self.hidden animated:animated];
        }
        UINavigationBar *bar = navigationController.navigationBar;
        if (bar) {
            bar.translucent = self.translucent?self.translucent:NO;
            bar.tintColor = self.tintColor?self.tintColor:[UIColor blackColor];
            bar.barStyle = self.barStyle?self.barStyle:UIBarStyleBlack;
        }
    }
}

- (void)dealloc
{
}

@end

@interface BaseViewController ()
{
    NSMutableDictionary *getRequestDic;
    
    NSMutableArray *_controllerObserverList;
}

@property (nonatomic, retain) NSMutableArray *controllerObserverList;

@end

@implementation BaseViewController
@synthesize navigationBarStyle;
@synthesize topOffset;
@synthesize isAppearing;
@synthesize controllerObserverList = _controllerObserverList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (id)initWithJS:(NSDictionary *)dic
{
    return [self init];
}
-(void)removeControllerForkickOff
{
    if (!self.parentViewController)
    {
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
}
-(void)dealloc
{

}

- (NSMutableArray *)controllerObserverList
{
    if (_controllerObserverList == nil) {
        _controllerObserverList = [[NSMutableArray alloc] init];
    }
    return _controllerObserverList;
}

- (void)pushViewControllerWithClass:(Class)controllerClass animated:(BOOL)animated
{
    [self pushViewControllerWithClass:controllerClass animated:animated smartMode:NO];
}

- (void)pushViewControllerWithClass:(Class)controllerClass animated:(BOOL)animated smartMode:(BOOL)smartMode
{
    UINavigationController *navigationController = self.navigationController;
    if (smartMode) {
        NSArray *controllers = navigationController.viewControllers;
        UIViewController *topViewController = [controllers lastObject];
        Class thisClass = [topViewController class];
        UIViewController *fromController = topViewController;
        NSInteger count = [controllers count];
        for (int i = 2, j = 3; j <= count; i += 2, j += 2) {
            UIViewController *pre = [controllers objectAtIndex:count - j];
            UIViewController *next = [controllers objectAtIndex:count - i];
            if (![pre compatibleWithClass:thisClass] || ![next compatibleWithClass:controllerClass]) {
                break;
            }
            fromController = pre;
        }
        if (fromController != topViewController) {
            [navigationController popToViewController:fromController animated:NO];
        }
    }
    UIViewController *controller = [[controllerClass alloc] init];
    [navigationController pushViewController:controller animated:animated];
}


- (NavigationBarStyle *)navigationBarStyle
{
    if (navigationBarStyle == nil) {
        navigationBarStyle = [[NavigationBarStyle alloc] initWithNavigationController:self.navigationController];
    }
    return navigationBarStyle;
}

- (UIRectEdge)preferredEdgesForExtendedLayout
{
    return UIRectEdgeNone;
}

- (BOOL)prefersStatusBarBackground
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isAppearing = YES;
    [self notifyAppearState:@selector(controller:viewWillAppear:) animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self notifyAppearState:@selector(controller:viewDidAppear:) animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self notifyAppearState:@selector(controller:viewWillDisappear:) animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isAppearing = NO;
    [self notifyAppearState:@selector(controller:viewDidDisappear:) animated:animated];

    [self stateWhenDidDisAppear];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#endif


#pragma UIWebViewDelegate
#pragma mark - WebRequestProxyDelegate


#pragma mark - UIScrollViewDelegate

- (void)addControllerObserver:(id<ControllerObserveProtocol>)observer
{
    if (![self.controllerObserverList containsObject:observer]) {
        [_controllerObserverList addObject:observer];
    }
}

- (void)removeControllerObserver:(id<ControllerObserveProtocol>)observer
{
    [_controllerObserverList removeObject:observer];
}

- (void)notifyAppearState:(SEL)selector animated:(BOOL)animated
{
    for (id<ControllerObserveProtocol> observer in _controllerObserverList) {
        if ([observer respondsToSelector:selector]) {
            ((id (*)(id, SEL, id, BOOL))objc_msgSend)(observer, selector, self, animated);
        }
    }
}

- (void)stateWhenDidAppear{
    
}

- (void)stateWhenDidDisAppear{
    
}

#pragma mark - statusBarControlling
@end
@implementation UIViewController (Loocha)

+ (NSString *)compatibleClassCategory
{
    return nil;//NSStringFromClass(self);
}

- (BOOL)compatibleWithClass:(Class)controllerClass
{
    NSString *thisCategory = [[self class] compatibleClassCategory];
    NSString *thatCategory = [controllerClass compatibleClassCategory];
    return thisCategory && thatCategory && [thisCategory isEqualToString:thatCategory];
}

- (BOOL)shouldFilterStatusBarAlertWhenAppearing
{
    return NO;
}

+ (BOOL)shouldBlurScreen {
    return NO;
}

@end
