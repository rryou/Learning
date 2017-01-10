//
//  ChattingImageView.m
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/22.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "ChattingImageView.h"
#import "CommDataModel.h"
#import "EMCommData.h"
@interface ChattingImageView(){
}
@property (nonatomic, strong) UIButton *ImageView;
@property (nonatomic, strong) UIImage *orgimage;
@end
@implementation ChattingImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.ImageView = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.ImageView];
        self.ImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return self;
}

- (void)prepareForReuse {
    [self.ImageView setImage:nil forState:UIControlStateNormal];
}

- (void)reloadImageData{
    CMsgItem *tempItem = [self.dataArray objectAtIndex:0];
    if ([[EMCommData sharedEMCommData] filehasload:tempItem]) {
        UIImage *tempimage = [[EMCommData sharedEMCommData] getlocalFile:tempItem];
        CGSize newSize = [self getScaleSize:tempimage.size];
        self.orgimage = tempimage;
        [self.ImageView setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
        [self.ImageView setImage:tempimage forState:UIControlStateNormal];
        [self.ImageView addTarget:self action:@selector(ImageViewBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        CIM_DownloadData *temploadData = [[CIM_DownloadData alloc] init];
        temploadData.m_cFileType = 2;
        temploadData.m_n64UserID = [EMCommData sharedEMCommData].selfUserInfo.m_n64AccountID;
        temploadData.m_n64GroupID = self.m_n64GroupID;
        temploadData.m_n64FileID =  tempItem.m_n64FileID;
        __weak typeof(self) weakSelf = self;
        [temploadData setDownImageBlocl:^(UIImage *newimage, BOOL success){
            CGSize newSize = [weakSelf getScaleSize:newimage.size];
            [weakSelf.ImageView setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
            [weakSelf.ImageView setImage:newimage forState:UIControlStateNormal];
            weakSelf.orgimage = newimage;
            [weakSelf.ImageView addTarget:weakSelf action:@selector(ImageViewBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFIMESSAGCellLOADIMAGESUCCESS object:self.content];
        }];
        [temploadData sendSockPost];
    }
}

- (void)ImageViewBtnEvent:(id)sender{
    if ([self.delegate respondsToSelector:@selector(scanImageEvent:imagdata:)]){
        [self.delegate scanImageEvent:self imagdata:self.orgimage];
    }
}

- (CGSize )getScaleSize:(CGSize )fileSize{
    if (fileSize.width > 200) {
        CGFloat imageHeight = fileSize.height*200.00/fileSize.width;
        return CGSizeMake(200, imageHeight);
    }else{
        return fileSize;
    }
}

+ (CGSize)viewSizeWithContent:(id)content maxWidth:(CGFloat)maxWidth{
    ChattingContent *chat = (ChattingContent *)content;
    CMsgItem *tempItem = [chat.data objectAtIndex:0];
    CGSize tempNewSize = CGSizeMake(200, 100);
    if ([[EMCommData sharedEMCommData] filehasload:tempItem]) {
        UIImage *tempimage = [[EMCommData sharedEMCommData] getlocalFile:tempItem];
        if (tempimage.size.width > 200) {
            CGFloat imageHeight = tempimage.size.height*200.00/tempimage.size.width;
            tempNewSize =CGSizeMake(200, imageHeight);
        }else{
             tempNewSize = tempimage.size;
        }
    }
    return tempNewSize;
}
@end
