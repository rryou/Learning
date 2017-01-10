//
//  UIApplication+NotificationSettings.m
//  EMSpeed
//
//  Created by ryan on 15/12/18.
//
//

#import "UIApplication+NotificationSettings.h"

@implementation UIApplication (NotificationSettings)

- (NSUInteger)EMNotificationSettingTypes
{
    NSUInteger types;
    if ([self respondsToSelector:@selector(currentUserNotificationSettings)]) {
        types = [self currentUserNotificationSettings].types;
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        types = [self enabledRemoteNotificationTypes];
#pragma clang diagnostic pop
    }
    return types;
}

@end
