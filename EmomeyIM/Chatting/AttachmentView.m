//
//  AttachmentView.m
//  LoochaCampus
//
//  Created by jinquan zhang on 12-10-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AttachmentView.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "ContentInfo.h"
#import "SDImageCache.h"
#import <EMSpeed/MSUIKitCore.h>
//#import "LoochaVoiceControl.h"

#define kAttachmentTagBase 100

@interface AttachmentView (){
    UIImageView *background;
}
@end

@implementation AttachmentView

@synthesize empty;
@synthesize needDesc;
@synthesize kThumbHeight;
@synthesize kThumbWidth;
@synthesize uniq_resource_tag;
@synthesize isNewStyle;

#define     defaultHeight 80.0f
#define     LimitCount    1

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 300, 200)];
    if (self) {
        needDesc = YES;
        isNewStyle = NO;
        
        background = [[UIImageView alloc] init];
//                      WithImage:[UIImage imageNamed:@"image_background"]];
        kThumbHeight = defaultHeight;
        kThumbWidth = defaultHeight;
    }
    return self;
}

- (void)dealloc
{
    [self clearAttachments];
    self.uniq_resource_tag = nil;
}

- (void)clearAttachments
{
    for (UIView *v in [self subviews]) {
        if ([v isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)v sd_setImageWithURL:nil placeholderImage:nil];
        }
        else if ([v isKindOfClass:[UIButton class]]) {
            [(UIButton *)v setBackgroundImage:nil forState:UIControlStateNormal];
        }
        [v removeFromSuperview];
    }
    
    for (int i = 0; i < sizeof(attachmentSet)/sizeof(attachmentSet[0]); i++) {
    }
    
    voiceControl = nil;
    empty = YES;
    CGRect r = self.frame;
    r.size.height = 0.0f;
    self.frame = r;
}

- (void)actionAttachment:(UIButton *)btn
{
    NSLog(@"AttachmentView Btn Click");
//    StorageDataType type = btn.tag - kAttachmentTagBase;
//    
//    [Global sendMessageToControllers:kTaskMsgOpenResourceBrowser withResult:0 withArg:attachmentSet[type]];
}

#define kDescHeight  20

- (UIButton *)addAttachmentViewDescription:(NSString *)desc type:(StorageDataType)type origin:(CGPoint)pt
{
    empty = NO;
    
    UIButton *imageBtn;
    float height ;
    imageBtn = [[UIButton alloc] initWithFrame:CGRectMake(pt.x, pt.y, kThumbWidth, kThumbHeight)];
    height = kThumbHeight;
    
    [self addSubview:imageBtn];
    imageBtn.tag = kAttachmentTagBase + type;
    
    [imageBtn addTarget:self action:@selector(actionAttachment:) forControlEvents:UIControlEventTouchUpInside];
    if(needDesc)
    {
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(pt.x, pt.y + height, kThumbWidth, kDescHeight)];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.text = desc;
        descLabel.font = [UIFont systemFontOfSize:10];
        descLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:descLabel];
        descLabel.backgroundColor = [UIColor clearColor];
    }
    [imageBtn.imageView setContentMode:UIViewContentModeScaleAspectFill];
    return imageBtn;
}


// NewStyle Photo
- (UIButton *)addNewAttachmentViewDesc:(NSString *)desc type:(StorageDataType)type origin:(CGPoint)pt
{
    empty = NO;
    
    UIButton *imageBtn;
    float height = 0.0;
    imageBtn = [[UIButton alloc] initWithFrame:CGRectMake(pt.x, pt.y, kThumbWidth, kThumbHeight)];
    imageBtn.clipsToBounds = NO;
    [imageBtn.imageView setContentMode:UIViewContentModeScaleAspectFill];
    imageBtn.tag = kAttachmentTagBase + type;
    [imageBtn addTarget:self action:@selector(actionAttachment:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:imageBtn];

    height = kThumbHeight;
    
    if(needDesc && [desc intValue] > LimitCount)
    {
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageBtn.frame) - 14 / 2, imageBtn.frame.origin.y - 14 / 2, 14, 14)];
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.text = desc;
        countLabel.clipsToBounds = YES;
        countLabel.layer.cornerRadius = 14 / 2;
        countLabel.font = [UIFont systemFontOfSize:10];
        countLabel.textColor = [UIColor whiteColor];
        countLabel.backgroundColor = RGB(239, 89, 48);
        [self addSubview:countLabel];
    }
    
    return imageBtn;
}

#define kVideoMarkWidth 30

- (void)updateWithAttachments:(NSArray *)attachments messageID:(NSString *)messageID withMaxWidth:(int)maxWidth{
    [self clearAttachments];
    needDesc = YES;
    if (attachments == nil || [attachments count] == 0)
    {
        return;
    }
    for (ContentInfo *ci in attachments)
    {
        int fileType = ci.fileType;
        switch (fileType) {
            case storagePhoto:
            case storageVoice:
            {
                if (attachmentSet[fileType] == nil) {
                    attachmentSet[fileType] = [[NSMutableArray alloc] init];
                }
                [attachmentSet[fileType] addObject:ci];
            }
                break;
                
            default:
                break;
        }
    }
    
    UIButton *btn = nil;
    CGPoint pt = CGPointZero;
    
    if (attachmentSet[storagePhoto]){
        if(isNewStyle)
        {
            btn = [self addNewAttachmentViewDesc:[NSString stringWithFormat:@"%lu", (unsigned long)[attachmentSet[storagePhoto] count]]
                                                type:storagePhoto
                                              origin:pt];
        }else{
            btn = [self addAttachmentViewDescription:[NSString stringWithFormat:@"共%lu张图片", (unsigned long)[attachmentSet[storagePhoto] count]]
                                                type:storagePhoto
                                              origin:pt];
        }
    }
    
    BOOL gapAdded = NO;
    if (btn) {
        pt.x = 0;
        
        if(isNewStyle)
            pt.y += kThumbHeight;
        else
            pt.y += kThumbHeight + kDescHeight;
        pt.y += 5;
        gapAdded = YES;
    }
        if (attachmentSet[storageVoice]) {
            empty = NO;
        }
    
    if (gapAdded) {
        pt.y -= 5;
    }
    
    CGRect r = self.frame;
    r.size.height = pt.y;
    self.frame = r;
}


+ (CGFloat)viewHeightForAttachments:(NSArray *)attachments{
    return [self viewHeightForAttachments:attachments isNewStyle:NO];
}

+ (CGFloat)viewHeightForAttachments:(NSArray *)attachments isNewStyle:(BOOL)isNew{
    CGFloat descH = 0.0;
    if(!isNew)
        descH = kDescHeight;
    
    return [AttachmentView viewHeightForAttachments:attachments withDescHeight:descH withThumbHeight:defaultHeight withMaxWidth:100];
}

+ (CGFloat)viewHeightForAttachments:(NSArray *)attachments withDescHeight:(float)desheight withThumbHeight:(float)thumbHeight withMaxWidth:(int)maxWidth{
    if (attachments == nil || [attachments count] == 0) {
        return 0;
    }
    int counter[7] = {0};
    CGFloat y = 0;
    ContentInfo *paperContent = nil;
    for (ContentInfo *ci in attachments) {
        int fileType =  ci.fileType;
        if (fileType >=0 && fileType < 7) {
            counter[fileType]++;
        }
    }
    
    BOOL gapAdded = NO;
    BOOL hasMusic = NO;
    
    if (gapAdded) {
        y -= 5;
    }
    return y;
}

#pragma mark - LoochaMusicDataSource

@end
