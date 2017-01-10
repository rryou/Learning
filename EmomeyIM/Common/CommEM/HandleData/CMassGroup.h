//
//  CMassGroup.h
//
//
//  Created by 尤荣荣 on 16/9/1.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMassGroup : NSObject{
    Byte _m_pcHash[16];
}
@property (nonatomic, strong) NSString *m_strName;
@property (nonatomic, assign) int64_t m_n64BatGroupID;
@property (nonatomic, strong) NSMutableArray *m_aGroupID;
- (void)createMD5;
- (bool)findGroupID:(int64_t)n64GroupID;
+ (NSInteger) compareCMassGroup:(CMassGroup *)firstGroup secondGroup:(CMassGroup *)secondGroup;
@end
