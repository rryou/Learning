//
//  ymMutableDataSource+goupWebView.m
//  ymStock
//
//  Created by flora on 14-8-1.
//
//

#import "MSMutableDataSource+groupWebView.h"

@implementation MSMutableDataSource (goupWebView)

- (NSArray *)toGroupWebViewArray:(NSIndexPath *)indexPath
{
    NSArray *array = [self.items objectAtIndex:indexPath.section];
    NSUInteger size = [array count];
    return [array subarrayWithRange:NSMakeRange(0, size)];
}

@end
