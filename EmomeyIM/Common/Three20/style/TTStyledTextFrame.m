//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "TTStyledTextFrame.h"

// Core
#import "TTCorePreprocessorMacros.h"
#import "TTLoochaDrawContext.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyledTextFrame

@synthesize node = _node;
@synthesize text = _text;
@synthesize font = _font;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithText:(NSString*)text element:(TTStyledElement*)element node:(TTStyledTextNode*)node {
	self = [super initWithElement:element];
  if (self) {
    _text = [text copy];
    _node = node;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_text);
  TT_RELEASE_SAFELY(_font);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawInRect:(CGRect)rect {
    [self drawInRect:rect withTextColor:nil];
}

- (void)drawInRect:(CGRect)rect withTextColor:(UIColor*)textColor
{
    if (textColor)
    {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.alignment = NSTextAlignmentLeft;
        paragraph.lineBreakMode = NSLineBreakByCharWrapping;
        NSDictionary *dict = @{NSFontAttributeName:_font,
                               NSForegroundColorAttributeName:textColor,
                               NSParagraphStyleAttributeName:paragraph};
        
        [_text drawInRect:rect withAttributes:dict];
        [paragraph release];
    }
    else
    {
        [_text drawInRect:rect withFont:_font lineBreakMode:NSLineBreakByCharWrapping];
    }
}

@end
