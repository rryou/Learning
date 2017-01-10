//
//  UIButton+SocketImageCache.m
//  EmomeyIM
//
//  Created by yourongrong on 2016/10/26.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "UIButton+SocketImageCache.h"
#import "EMCommData.h"
#import "CommDataModel.h"

@implementation UIButton (SocketImageCache)

- (void)sk_setimageWith:(NSString *)fileId forState:(UIControlState)state placeholderImage:(UIImage *)placeholder{
    [self sk_setimageWith:fileId forState:state completed:^(UIImage *image, NSString *filedid) {
        if(image){
            [self setImage:image forState:state];
        }else{
            if(placeholder){
                [self setImage:placeholder forState:state];
            }
        }}];
}
- (void)sk_setimageWith:(NSString *)fileId forState:(UIControlState)state completed:(SocketDownImageBlock)completedBlock{
    if([[EMCommData sharedEMCommData] imagehasload:fileId]){
        completedBlock([[EMCommData sharedEMCommData]getlocalImage:fileId],fileId);
    }else{
        CIM_DownloadData *temploadData = [[CIM_DownloadData alloc] init];
        temploadData.m_cFileType = 2;
        temploadData.m_n64UserID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        temploadData.m_n64GroupID = [EMCommData sharedEMCommData].selfUserInfo.m_nGroupId;
        temploadData.m_n64FileID = fileId.longLongValue;
        [temploadData setDownImageBlocl:^(UIImage *newimage, BOOL success){
            completedBlock(newimage,fileId);
        }];
        [temploadData sendSockPost];
    }
}
@end
