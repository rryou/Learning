//
//  ChattingImageView.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/9/22.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChattingCellContext.h"
#import "ChattingContent.h"

#define NOTIFIMESSAGCellLOADIMAGESUCCESS @"CellloadImageSuccess"
@class ChattingImageView;
@protocol ChattingImageViewDelegate <NSObject>
- (void)uploadImageViews:(ChattingImageView *)view;
- (void)scanImageEvent:(ChattingImageView *)view imagdata:(UIImage *)image;
@end
@interface ChattingImageView : UIView<ReusableViewProtocol>
@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, assign) id<ChattingImageViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int64_t m_n64GroupID;
@property (nonatomic, strong)  ChattingContent *content;
// maxWidth : 视图的最大宽
- (void)reloadImageData;

+ (CGSize)viewSizeWithContent:(id)content maxWidth:(CGFloat)maxWidth;
@end
