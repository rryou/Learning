//
//  TTLoochaStyledTextParser.m
//  LoochaCampus
//
//  Created by ding xiuwei on 13-1-11.
//
//

#import "TTLoochaStyledTextParser.h"
#import "TTLoochaStyleImageNode.h"
#import "TTStyledAtNode.h"
//#import "NSString+Extends.h"
#import "TTStyledTextNode.h"
#import "DMEmo.h"
#import "EMCommData.h"

#define NewEmojMaxLength    200   //13 新需求 没有gift对象了，只是遍历文本 这个值 修改大一点
#define NameMaxLength 20
#define UserIdMaxLength 20
#define kEmojiWidth 33

@implementation TTLoochaStyledTextParser
@synthesize isMePublish;


-(id)init
{
    if (self = [super init])
    {
       
    }
    return self;
}
//--------   Loocha 文本解析

#pragma  mark-  Loocha 文本解析
-(void)parseLoochaText:(NSString*)originStr
{
    
    [self parseLoochaText:originStr withGiftArr:[NSArray array]];
    
}

-(void)parseLoochaText:(NSString*)originStr withGiftArr:(NSArray *)giftArr
{
    self.emojDic = [[EMCommData sharedEMCommData] getemojiDict];
    if (!originStr || [originStr isEqualToString:@""])
    {
        return;
    }

    NSUInteger leftBracket = NSNotFound;
    NSUInteger leftSquare = NSNotFound;
    NSUInteger atChar = NSNotFound;
    
    BOOL isTempFound = NO;
    BOOL isFond = NO;
    
    NSUInteger  pureTextStartPoint = 0;
    NSUInteger  pureTextEndPoint = 0;
    
    for (int i = 0; i < [originStr length]; i++)
    {
        unichar c = [originStr characterAtIndex:i];

        if (c == '[')
        {
            leftSquare = i;
            pureTextEndPoint = i;
        }
        else if (c == ']')
        {
            if (leftSquare != NSNotFound)
            {
                if (i - leftSquare > NewEmojMaxLength){
                    leftSquare = NSNotFound;
                }else{
                    unichar tempC = [originStr characterAtIndex:leftSquare +1];
                    NSString *tempStr = [originStr substringWithRange:NSMakeRange(leftSquare +1,2 )];
                    
                    if ([@"1," isEqualToString :tempStr])
                    {
                        
                       NSString *giftMaybe = [originStr substringWithRange:NSMakeRange(leftSquare + 3, i - leftSquare -3)];
                            NSDictionary *tempemojidic = [[EMCommData sharedEMCommData] getemojiDict];
                              NSString *keyValue = [tempemojidic objectForKey:giftMaybe];
                            pureTextStartPoint = i+1;
                            TTLoochaStyleImageNode* node = [[[TTLoochaStyleImageNode alloc] init] autorelease];
                            DMEmo *gift = [[DMEmo alloc] initWithName:giftMaybe src:keyValue];
                            gift.type = 0;
                            node.gift = gift;
                            node.URL = gift.src;
                            node.width = kEmojiWidth;
                            node.height = kEmojiWidth;
                            node.adjustsSizeToFitFont = YES;
                            [self addNode:node];
                            [gift release];
                            leftSquare = NSNotFound;
                    }else if([@"2," isEqualToString :tempStr]){
//                        NSString *giftMaybe = [originStr substringWithRange:NSMakeRange(leftSquare + 3, i - leftSquare -3)];
//                        NSDictionary *tempemojidic = [[EMCommData sharedEMCommData] getemojiDict];
                        pureTextStartPoint = i+1;
                        TTStyledTextNode * node = [[[TTStyledTextNode alloc] init] autorelease];
                        node.text = @"[图片]";
                        [self addNode:node];
                        leftSquare = NSNotFound;
                    }else if([@"0," isEqualToString :tempStr]){
                        NSString *giftMaybe = [originStr substringWithRange:NSMakeRange(leftSquare + 3, i - leftSquare -3)];
                        NSDictionary *tempemojidic = [[EMCommData sharedEMCommData] getemojiDict];
                        pureTextStartPoint = i+1;
                        TTStyledTextNode * node = [[[TTStyledTextNode alloc] init] autorelease];
                        node.text = giftMaybe;
                        [self addNode:node];
                        leftSquare = NSNotFound;


                    }

                }
            }
        }

        else if(leftBracket != NSNotFound && i > leftBracket )
        {
            if (c<'0' || c>'9')
            {
                 leftBracket = NSNotFound;
            }
           
        }
        //------  other----
        
        
        
        // ---  text -------
        if ([originStr length]-1 == i && !isFond)
        {
            [self parseText:[originStr substringWithRange:NSMakeRange(pureTextStartPoint, i+1-pureTextStartPoint )]];
            
        }
        else
            if ([originStr length]-1 == i  && isTempFound  )
            {
                [self parseText:[originStr substringWithRange:NSMakeRange(pureTextStartPoint, i+1-pureTextStartPoint )]];
            }
    }

}

-(void)parseOneAt:(NSString*)name withId:(NSString*)userId
{
    TTStyledAtNode* node = [[[TTStyledAtNode alloc] init] autorelease];
    node.className = @"atBox:";
    node.userId = userId;
    node.name = name;
    [self pushNode:node];
    [self parseText:[NSString stringWithFormat:@"@%@",node.name]];
    [self popNode];
    
}
@end
