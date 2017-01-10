//
//  TTLoochaStyledText.m
//  LoochaCampus
//
//  Created by ding xiuwei on 13-1-11.
//
//

#import "TTLoochaStyledText.h"
#import "TTLoochaStyledTextParser.h"



@implementation TTLoochaStyledText

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTLoochaStyledText*)textFromLoochaText:(NSString*)source {
    return [self textFromLoochaText:source lineBreaks:NO URLs:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTLoochaStyledText*)textFromLoochaText:(NSString*)source lineBreaks:(BOOL)lineBreaks URLs:(BOOL)URLs {
    return [self textFromLoochaText:source lineBreaks:lineBreaks URLs:URLs isMeIPusblish:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTLoochaStyledText*)textFromLoochaText:(NSString*)source lineBreaks:(BOOL)lineBreaks URLs:(BOOL)URLs isMeIPusblish:(BOOL)isMe
{
   return  [self textFromLoochaText:source lineBreaks:lineBreaks URLs:URLs isMeIPusblish:isMe withGiftArr:[NSArray array]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TTLoochaStyledText*)textFromLoochaText:(NSString*)source lineBreaks:(BOOL)lineBreaks URLs:(BOOL)URLs isMeIPusblish:(BOOL)isMe withGiftArr:(NSArray *)giftArr
{
    TTLoochaStyledTextParser* parser = [[[TTLoochaStyledTextParser alloc] init] autorelease];
    parser.parseLineBreaks = lineBreaks;
    parser.isMePublish = isMe;
    parser.parseURLs = URLs;
    [parser parseLoochaText:source withGiftArr:giftArr];
    if (parser.rootNode) {
        return [[[TTLoochaStyledText alloc] initWithNode:parser.rootNode] autorelease];
        
    } else {
        return nil;
    }
}
//////////////////////////////////////////////////////////////////////////////
@end
