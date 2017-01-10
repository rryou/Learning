//
//  TTLoochaStyledTextParser.h
//  LoochaCampus
//
//  Created by ding xiuwei on 13-1-11.
//
//

#import "TTStyledTextParser.h"



@interface TTLoochaStyledTextParser : TTStyledTextParser
{
    BOOL isMePublish;

}

@property(nonatomic,assign)BOOL isMePublish;
-(void)parseLoochaText:(NSString*)originStr;
-(void)parseLoochaText:(NSString*)originStr withGiftArr:(NSArray *)giftArr;
@end
