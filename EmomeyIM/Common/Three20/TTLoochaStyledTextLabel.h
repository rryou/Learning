//
//  TTLoochaStyledTextLabel.h
//  LoochaCampus
//
//  Created by ding xiuwei on 13-1-11.
//
//

#import "TTStyledTextLabel.h"
#import "ChattingCellContext.h"


#define TTStyledTextFont 16
@interface TTLoochaStyledTextLabel : TTStyledTextLabel <ReusableViewProtocol>

@property (nonatomic, retain) NSArray *emoArray;
@property (nonatomic, retain) NSString *reuseIdentifier;

-(CGFloat)calculateFirstLineWith;
+(CGFloat)getContentViewHeightWithContent:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font withMaxLines:(int)l isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr;
+(CGFloat)getContentViewHeightWithContent:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font URLs:(BOOL)URLs withMaxLines:(int)l isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr;
+(CGFloat)getContentViewHeightWithXHTML:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font withMaxLines:(int)l;

+(CGFloat)getContentViewHeightWithContent:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font withMaxLines:(int)l isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr  lineBreaks:(BOOL)isbreak;

+ (CGSize)viewSizeWithContent:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font withMaxLines:(int)l isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr;
+ (CGSize)viewSizeWithContent:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font URLs:(BOOL)URLs withMaxLines:(int)l isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr;

+(CGFloat)getContentViewHeightWithContent:(NSString*)content constraintMaxSize:(CGSize)maxSz withFont:(UIFont*)font isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr  lineBreaks:(BOOL)isbreak;

@end
