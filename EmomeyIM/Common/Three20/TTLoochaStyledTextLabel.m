//
//  TTLoochaStyledTextLabel.m
//  LoochaCampus
//
//  Created by ding xiuwei on 13-1-11.
//
//

#import "TTLoochaStyledTextLabel.h"
#import "TTLoochaStyledText.h"
#import "UIImageAdditions.h"
#import "TTDefaultStyleSheet.h"
#import "TTTextStyle.h"
#import "TTBoxStyle.h"
#import "TTShapeStyle.h"
#import "TTRoundedRectangleShape.h"
#import "TTInsetStyle.h"
#import "TTShadowStyle.h"
#import "TTSolidFillStyle.h"
#import "TTSolidBorderStyle.h"
#import "TTStyledLayout.h"

#import "DMEmo.h"
#import "TTLoochaStyleImageNode.h"
#import "TTStyledImageFrame.h"
#import "SDWebImageManager.h"

//#import "SCGIFImageView.h"
#import "TTStyledImageFrame.h"
#import "UIImageView+WebCache.h"
//#import "SDWebImageManagerDelegate.h"
#import "TTLoochaDrawContext.h"
#import "NSString+LoochaAdapt.h"
#import "UIColor+Oxygen.h"

@interface TextTestStyleSheet : TTDefaultStyleSheet
@end

@implementation TextTestStyleSheet

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)atTextColor {
    // return RGBCOLOR(87, 107, 149);
    return [UIColor colorWithHexString:@"4484cc"];
}
- (TTStyle*)blueText {
    return [TTTextStyle styleWithColor:[UIColor blueColor] next:nil];
}

- (TTStyle*)relationText {
    return [TTTextStyle styleWithColor:[UIColor colorWithHexString:@"f36c4d"] next:nil];
}

-(TTStyle*)MainTitle
{
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:23.5] color:[UIColor colorWithHexString:@"#393939"] textAlignment:NSTextAlignmentCenter next:nil];
}

-(TTStyle*)DefaultTitle
{
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:16] color:[UIColor colorWithHexString:@"#393939"] textAlignment:NSTextAlignmentCenter next:nil];
}

-(TTStyle*)SubTitle
{
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:13.5] color:[UIColor colorWithHexString:@"#CECECE"] textAlignment:NSTextAlignmentCenter next:nil];
}

-(TTStyle*)topicPublisher:(UIControlState)state
{
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12] color:[UIColor colorWithHexString:@"#f7b652"] textAlignment:NSTextAlignmentCenter next:nil];
}

-(TTStyle*)SpecialSubTitle
{
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:13.5] color:[UIColor colorWithHexString:@"#CECECE"] textAlignment:NSTextAlignmentCenter next:nil];
}

- (TTStyle*)largeText {
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:32] next:nil];
}

- (TTStyle*)smallText {
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12] next:nil];
}

- (TTStyle*)floated {
    return [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0, 0, 5, 5)
                               padding:UIEdgeInsetsMake(0, 0, 0, 0)
                               minSize:CGSizeZero position:TTPositionFloatLeft next:nil];
}

- (TTStyle*)blueBox {
    return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6] next:
     [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -5, -4, -6) next:
      [TTShadowStyle styleWithColor:[UIColor grayColor] blur:2 offset:CGSizeMake(1,1) next:
       [TTSolidFillStyle styleWithColor:[UIColor cyanColor] next:
        [TTSolidBorderStyle styleWithColor:[UIColor grayColor] width:1 next:nil]]]]];
}

- (TTStyle*)redBox {
    return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6] next:
     [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0,5,0,5)
                         padding:UIEdgeInsetsMake(0,3,0,3) next:
      [TTSolidFillStyle styleWithColor:[UIColor redColor] next:
       [TTTextStyle styleWithColor:[UIColor whiteColor] next:
         [TTTextStyle styleWithFont:[UIFont systemFontOfSize:6] next:
        [TTSolidBorderStyle styleWithColor:[UIColor blackColor] width:1 next:
         nil]]]]]];
}

- (TTStyle*)inlineBox {
    return
    [TTSolidFillStyle styleWithColor:[UIColor blueColor] next:
     [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(5,13,5,13) next:
      [TTSolidBorderStyle styleWithColor:[UIColor blackColor] width:1 next:nil]]];
}

- (TTStyle*)inlineBox2 {
    return
    [TTSolidFillStyle styleWithColor:[UIColor cyanColor] next:
     [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(5,50,0,50)
                         padding:UIEdgeInsetsMake(0,13,0,13) next:nil]];
}

- (TTStyle*)atBox:(UIControlState)state {
    if (state == UIControlStateHighlighted) {
        return
        [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6] next:
         [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -5, -4, -6) next:
          [TTShadowStyle styleWithColor:[UIColor grayColor] blur:2 offset:CGSizeMake(1,1) next:
           [TTSolidFillStyle styleWithColor:[UIColor cyanColor] next:
            [TTTextStyle styleWithColor:self.atTextColor next:nil]]]]];
        
    } else {
        return
        [TTTextStyle styleWithColor:self.atTextColor next:nil];
    }
}

-(TTStyle*)inviteRecordCellNameBox:(UIControlState)state
{
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:14] color:[UIColor colorWithHexString:@"#777777"] textAlignment:NSTextAlignmentLeft next:nil];
}
-(TTStyle*)inviteRecordCellshareBox:(UIControlState)state
{
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:9] color:[UIColor colorWithHexString:@"#deab60"] textAlignment:NSTextAlignmentLeft next:nil];
}
-(TTStyle*)inviteRecordCellmobileBox:(UIControlState)state
{
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:11] color:[UIColor colorWithHexString:@"#b7b7b7"] textAlignment:NSTextAlignmentLeft next:nil];
}

-(TTStyle *)grabCountText {
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:14] color:[UIColor colorWithHexString:@"#dc8248"] textAlignment:NSTextAlignmentLeft next:nil];
}

-(TTStyle *)grabTaskFinishName {
    return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:20] color:[UIColor colorWithHexString:@"#5c2510"] textAlignment:NSTextAlignmentLeft next:nil];
}

-(TTStyle *)grabTaskFinishCredit {
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:18] color:[UIColor colorWithHexString:@"#3dbf23"] textAlignment:NSTextAlignmentLeft next:nil];
}


-(TTStyle *)pieceNameAndQuantity{
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:18] color:[UIColor colorWithHexString:@"#c88c8c"] textAlignment:NSTextAlignmentLeft next:nil];
}

@end

@interface TTLoochaStyledTextLabel() 
{
    BOOL isDrawRect;
    TTStyledImageFrame *imageFrame;
    CGContextRef context;;
}
@property(nonatomic,retain)TTStyledImageFrame *imageFrame;
@end

@implementation TTLoochaStyledTextLabel
@synthesize imageFrame;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self)
    {
        [TTStyleSheet setGlobalStyleSheet:[[[TextTestStyleSheet alloc] init] autorelease]];


    }
    
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
}


-(void)dealloc
{
    if (context)
    {
        CFRelease(context);
    }
    [super dealloc];
}

- (void)setText:(TTStyledText*)text
{
    [super setText:text];
}


+(CGFloat)getContentViewHeightWithContent:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font withMaxLines:(int)l isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr  lineBreaks:(BOOL)isbreak
{
    
    CGFloat h = 0;
    //    if (content.length<=256) {
    static TTLoochaStyledTextLabel* label;
    if (label) {
        label.frame = CGRectMake(0, 0, w, 0);
    }
    else {
        label = [[TTLoochaStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, w, 0)];
    }
    
    if(l)
        label.maxnumOfLines = l;
    else
        label.maxnumOfLines = 0;
    label.font = [UIFont systemFontOfSize:font];
    label.text = [TTLoochaStyledText textFromLoochaText:content lineBreaks:isbreak URLs:NO isMeIPusblish:isMe withGiftArr:giftArr];
    [label sizeToFit];
    
    h = label.text.height;
    //    }
    //    else
    //    {
    //
    //    NSString *result = [content stringByReplacingString:@" k " pattern:@"\\[([^\\]]{1,5})\\]"];
    //    result = [result stringByReplacingString:@"" pattern:@"@.+(\\([\\d]+\\))"];
    //    NSLog(@"result : %@", result);
    //
    //    h = [result sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(w, INTMAX_MAX)].height;
    //    }
    // RCTrace(@"height:%f",label.text.firstLineWith);
    
    label.text = nil;
    return h;
    
}

+(CGFloat)getContentViewHeightWithContent:(NSString*)content constraintMaxSize:(CGSize)maxSz withFont:(UIFont*)font isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr  lineBreaks:(BOOL)isbreak
{
        CGFloat lineH = [@"我" loocha_sizeWithFont:font].height;
    int line = maxSz.height/lineH;
    CGFloat h = 0;
    static TTLoochaStyledTextLabel* label;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (label) {
        label.frame = CGRectMake(0, 0, maxSz.width, 0);
    }
    else {
        label = [[TTLoochaStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0,maxSz.width, 0)];
    }
    
    label.maxnumOfLines = line;
 
    label.font = font;
    label.text = [TTLoochaStyledText textFromLoochaText:content lineBreaks:isbreak URLs:NO isMeIPusblish:isMe withGiftArr:giftArr];
    [label sizeToFit];
    
    h = label.text.height;

    label.text = nil;
    
    [CATransaction commit];

    return h;
}

+(CGFloat)getContentViewHeightWithContent:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font withMaxLines:(int)l isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr
{
    return [self getContentViewHeightWithContent:content constraintWidth:w withFontSize:font URLs:NO withMaxLines:l isMePublish:isMe withGiftArr:giftArr];
}

+(CGFloat)getContentViewHeightWithContent:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font URLs:(BOOL)URLs withMaxLines:(int)l isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr
{
    
    CGFloat h = 0;
//    if (content.length<=256) {
        static TTLoochaStyledTextLabel* label;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

        if (label) {
            label.frame = CGRectMake(0, 0, w, 0);
        }
        else {
            label = [[TTLoochaStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, w, 0)];
        }
        if(l)
            label.maxnumOfLines = l;
        else
            label.maxnumOfLines = 0;
        label.font = [UIFont systemFontOfSize:font];
        label.text = [TTLoochaStyledText textFromLoochaText:content lineBreaks:YES URLs:URLs isMeIPusblish:isMe withGiftArr:giftArr];
        [label sizeToFit];
        
        h = label.text.height;
//    }
//    else
//    {
//
//    NSString *result = [content stringByReplacingString:@" k " pattern:@"\\[([^\\]]{1,5})\\]"];
//    result = [result stringByReplacingString:@"" pattern:@"@.+(\\([\\d]+\\))"];
//    NSLog(@"result : %@", result);
//
//    h = [result sizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(w, INTMAX_MAX)].height;
//    }
    // RCTrace(@"height:%f",label.text.firstLineWith);
    
    label.text = nil;
    
    [CATransaction commit];

    return h;
    
}

+(CGFloat)getContentViewHeightWithXHTML:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font withMaxLines:(int)l
{
    CGFloat h = 0;
    static TTLoochaStyledTextLabel* label;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    if (label) {
        label.frame = CGRectMake(0, 0, w, 0);
    }
    else {
        label = [[TTLoochaStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, w, 0)];
    }
    if(l)
        label.maxnumOfLines = l;
    else
        label.maxnumOfLines = 0;
    label.font = [UIFont systemFontOfSize:font];
    label.text = [TTStyledText textFromXHTML:content lineBreaks:YES URLs:YES];
    [label sizeToFit];
    
    h = label.text.height;
    
    label.text = nil;
    
    [CATransaction commit];

    return h;
    
}

-(void)parseContentStr:(NSString*)str withMaxnum:(int)n
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 20);
    self.text =[TTLoochaStyledText textFromLoochaText:str lineBreaks:YES URLs:NO];
    self.text.maxnumOfLines =1;
}



-(CGFloat)calculateFirstLineWith
{
    CGFloat w = 0;
    _text.maxWith = self.frame.size.width;
    _text.width = self.frame.size.width;
    w= [_text calculateFirstLineWith];
    self.firstLineWith = w;
    return w + 1;
}



- (void)drawRect:(CGRect)rect {    
 
    _text.maxWith = self.frame.size.width;
    _text.maxnumOfLines = self.maxnumOfLines ;
    [TTStyledLayout setLines:0];
    
    self.paragraphStyle.maximumLineHeight = rect.size.height;
    self.paragraphStyle.alignment = self.textAlignment;
    
    [ttLoochaDrawContext reset];
    if (_highlighted) {
        [self.highlightedTextColor setFill];
        ttLoochaDrawContext.foregroundColor = self.highlightedTextColor;
    } else {
        [self.textColor setFill];
        ttLoochaDrawContext.foregroundColor = self.textColor;
    }
    ttLoochaDrawContext.backgroundColor = self.backgroundColor;
    ttLoochaDrawContext.paragraphStyle = self.paragraphStyle;
    
    CGPoint origin = CGPointMake(rect.origin.x + _contentInset.left,
                                 rect.origin.y + _contentInset.top);
    [_text drawAtPoint:origin highlighted:_highlighted textColor:self.textColor];
    // NSLog(@"cccc %f",_text.firstLineWith);
    self.firstLineWith = _text.firstLineWith;
    
    
}

- (void)prepareForReuse {
    
}

+ (CGSize)viewSizeWithContent:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font withMaxLines:(int)l isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr {
    return [self viewSizeWithContent:content constraintWidth:w withFontSize:font URLs:NO withMaxLines:l isMePublish:isMe withGiftArr:giftArr];
}

+ (CGSize)viewSizeWithContent:(NSString*)content constraintWidth:(CGFloat)w withFontSize:(CGFloat)font URLs:(BOOL)URLs withMaxLines:(int)l isMePublish:(BOOL)isMe withGiftArr:(NSArray *)giftArr {
    static TTLoochaStyledTextLabel* label;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (label) {
        label.frame = CGRectMake(0, 0, w, 0);
    }
    else {
        label = [[TTLoochaStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, w, 0)];
    }
    if(l)
        label.maxnumOfLines = l;
    else
        label.maxnumOfLines = 0;
    label.font = [UIFont systemFontOfSize:font];
    label.text = [TTLoochaStyledText textFromLoochaText:content lineBreaks:YES URLs:URLs isMeIPusblish:isMe withGiftArr:giftArr];
    [label sizeToFit];
    
    CGSize sz = CGSizeZero;
    sz.height = label.text.height;
    CGFloat firstLineWidth = [label calculateFirstLineWith];
    if (firstLineWidth < w) {
        sz.width = firstLineWidth;
    }
    else {
        sz.width = w;
    }
    
    label.text = nil;
    
    [CATransaction commit];
    
    return sz;
}

@end
