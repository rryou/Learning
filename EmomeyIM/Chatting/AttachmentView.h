//
//  AttachmentView.h
//  LoochaCampus
//
//  Created by jinquan zhang on 12-10-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    storageFile        = 1, //
    storagePhoto       = 2, //
    storageVoice       = 3, //
    storageTotal,
}StorageDataType;
@class TextView;
@class LoochaVoiceControl;

#define kVoiceHeight 30

@interface AttachmentView : UIView{
    NSMutableArray *attachmentSet[7];
    LoochaVoiceControl *voiceControl;
    TextView *textView;
    BOOL empty;
    BOOL isNewStyle;
}
@property (nonatomic, readonly) BOOL empty;
@property (nonatomic, assign) BOOL needDesc;
@property (nonatomic, assign) BOOL isNewStyle;
@property (nonatomic, assign) float kThumbWidth;
@property (nonatomic, assign) float kThumbHeight;
@property (nonatomic, retain) NSString *uniq_resource_tag;

- (void)willDeleteMessage;

- (void)clearAttachments;

- (void)updateWithAttachments:(NSArray *)attachments messageID:(NSString *)messageID withMaxWidth:(int)maxWidth;

+ (CGFloat)viewHeightForAttachments:(NSArray *)attachments withDescHeight:(float)desheight withThumbHeight:(float)thumbHeight withMaxWidth:(int)maxWidth;

+ (CGFloat)viewHeightForAttachments:(NSArray *)attachments;

+ (CGFloat)viewHeightForAttachments:(NSArray *)attachments isNewStyle:(BOOL)isNew;

- (UIButton *)addAttachmentViewDescription:(NSString *)desc type:(StorageDataType)type origin:(CGPoint)pt;

@end
