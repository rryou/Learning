//
//  HandleDataModel.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/30.
//  Copyright © 2016年 frank. All rights reserved.
#import "NSArray+Extends.h"

@implementation NSArray(Extends)
- (NSMutableArray *)divideGroupWithPreCount:(NSUInteger)count
{
#if DEBUG
#else
    if (count == 0)
    {
        return [NSMutableArray arrayWithArray:self];
    }
#endif
    
    NSMutableArray *groupArr = [[NSMutableArray alloc] initWithCapacity:self.count/count + 1];
    
    for (int i = 0; i< self.count; i += count)
    {
        NSUInteger loc = i;
        NSInteger len = count;
        if((i + count) > self.count)
        {
            len = self.count - i;
        }
        NSArray *group =[self subarrayWithRange:NSMakeRange(loc, len)];
        [groupArr addObject:group];
    }
    return groupArr;
}
@end
