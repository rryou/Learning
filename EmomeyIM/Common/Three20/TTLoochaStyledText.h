//
//  TTLoochaStyledText.h
//  LoochaCampus
//
//  Created by ding xiuwei on 13-1-11.
//
//

#import "TTStyledText.h"

@interface TTLoochaStyledText : TTStyledText
/**
 *
 *loocha Text
 *
 */
+ (TTLoochaStyledText*)textFromLoochaText:(NSString*)source;
+ (TTLoochaStyledText*)textFromLoochaText:(NSString*)source lineBreaks:(BOOL)lineBreaks URLs:(BOOL)URLs;
+ (TTLoochaStyledText*)textFromLoochaText:(NSString*)source lineBreaks:(BOOL)lineBreaks URLs:(BOOL)URLs isMeIPusblish:(BOOL)isMe;
+ (TTLoochaStyledText*)textFromLoochaText:(NSString*)source lineBreaks:(BOOL)lineBreaks URLs:(BOOL)URLs isMeIPusblish:(BOOL)isMe withGiftArr:(NSArray *)giftArr;
@end
