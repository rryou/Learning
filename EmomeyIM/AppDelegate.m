//
//  AppDelegate.m
//  EmomeyIM
//
//  Created by frank on 16/8/12.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "AppDelegate.h"
#import "EMLoginViewController.h"
#import "ServiceContainController.h"
#import "PersonTabMangerController.h"
#import "EMCommData.h"
#import "EMLocalSocketManaget.h"
@interface AppDelegate ()
@property (nonatomic ,strong) EMLoginViewController *loginViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _loginViewController= [[EMLoginViewController alloc] init];
    UINavigationController *tempNacontrol =[[ UINavigationController alloc] initWithRootViewController:_loginViewController];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = tempNacontrol;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UINavigationBar *apprecontroller=  [UINavigationBar appearance];
    apprecontroller.barTintColor = [UIColor whiteColor];
    [apprecontroller setTintColor:[UIColor whiteColor]];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [apprecontroller setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([[EMCommData sharedEMCommData] isLogined]) {
        NSLog(@"start BackGroup Heart Test");
//        BOOL backgroudAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:7 handler:^{
//            [[EMLocalSocketManaget sharedSocketManaget] startbackGroupHear];
//            if (backgroudAccepted) {
//                NSLog(@"backgroud heart Test");
//            }
//        }];
    }
    NSLog(@"enter ground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
        NSLog(@" will enter ground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([[EMCommData sharedEMCommData] isLogined] &&![[EMLocalSocketManaget sharedSocketManaget] sockConnectAvailble]){
        [_loginViewController.navigationController popToRootViewControllerAnimated:YES];
        [_loginViewController reLongInUserName:[EMCommData sharedEMCommData].selfUserInfo.m_strUserName passWord:[EMCommData sharedEMCommData].selfUserInfo.m_strPassword];
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
