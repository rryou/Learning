//
//  CMassGroup.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/1.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "CMassGroup.h"

@implementation CMassGroup


- (id)init{
    self =[super init];
    if (self) {
        self.m_aGroupID = [NSMutableArray array];
    }
    return self;
}

- (void)createMD5{

}

+(NSInteger) compareCMassGroup:(CMassGroup *)firstGroup secondGroup:(CMassGroup *)secondGroup{
    if (firstGroup.m_n64BatGroupID == secondGroup.m_n64BatGroupID) {
        return 0;
    }else{
        return firstGroup.m_n64BatGroupID - secondGroup.m_n64BatGroupID;
    }
}

- (bool) findGroupID:(int64_t)n64GroupID{
    return [_m_aGroupID containsObject:[NSNumber numberWithLong:n64GroupID ]];
}

@end
