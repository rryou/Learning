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
#import "NSString+LoochaAdapt.h"
#import "TTStyledLayout.h"
// Style
#import "TTGlobalStyle.h"
#import "TTStyledFrame.h"
#import "TTStyleSheet.h"
#import "TTBoxStyle.h"
#import "TTTextStyle.h"
#import "TTStyledElement.h"
#import "TTStyledInlineFrame.h"
#import "TTStyledTextFrame.h"
#import "TTStyledImageFrame.h"
#import "UIFontAdditions.h"
#import "TTDefaultStyleSheet.h"


// Styled nodes
#import "TTStyledImageNode.h"
#import "TTStyledBoldNode.h"
#import "TTStyledItalicNode.h"
#import "TTStyledLinkNode.h"
#import "TTStyledBlock.h"
#import "TTStyledLineBreakNode.h"
#import "TTStyledTextNode.h"


#import "TTStyledAtNode.h"  //add for @
// Core
#import "TTGlobalCore.h"
#import "TTCorePreprocessorMacros.h"

#import "TTLoochaStyleImageNode.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyledLayout

@synthesize width         = _width;
@synthesize height        = _height;
@synthesize rootFrame     = _rootFrame;
@synthesize font          = _font;
@synthesize textAlignment = _textAlignment;
@synthesize invalidImages = _invalidImages;
@synthesize maxLines;
@synthesize maxHeight;
@synthesize whichLable;
static int lines;
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithRootNode:(TTStyledNode*)rootNode {
    self = [super init];
    if (self) {
        _rootNode = rootNode;
        maxLines = INT_MAX;
        maxHeight = CGFLOAT_MAX;
        _ajustImageHeight = 0;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithX:(CGFloat)x width:(CGFloat)width height:(CGFloat)height {
    self = [super init];
    if (self) {
        _x = x;
        _minX = x;
        _width = width;
        _height = height;
        _ajustImageHeight = 0;
        
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    TT_RELEASE_SAFELY(_rootFrame);
    TT_RELEASE_SAFELY(_font);
    TT_RELEASE_SAFELY(_boldFont);
    TT_RELEASE_SAFELY(_italicFont);
    TT_RELEASE_SAFELY(_linkStyle);
    TT_RELEASE_SAFELY(_invalidImages);
    self.whichLable = nil;
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)boldVersionOfFont:(UIFont*)font {
    // XXXjoe Clearly this doesn't work if your font is not the system font
    return [UIFont boldSystemFontOfSize:font.pointSize];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)italicVersionOfFont:(UIFont*)font {
    // XXXjoe Clearly this doesn't work if your font is not the system font
    return [UIFont italicSystemFontOfSize:font.pointSize];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyledNode*)findLastNode:(TTStyledNode*)node {
    TTStyledNode* lastNode = nil;
    while (node) {
        if ([node isKindOfClass:[TTStyledElement class]]) {
            TTStyledElement* element = (TTStyledElement*)node;
            lastNode = [self findLastNode:element.firstChild];
            
        } else {
            lastNode = node;
        }
        node = node.nextSibling;
    }
    return lastNode;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)boldFont {
    if (!_boldFont) {
        _boldFont = [[self boldVersionOfFont:self.font] retain];
    }
    return _boldFont;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)italicFont {
    if (!_italicFont) {
        _italicFont = [[self italicVersionOfFont:self.font] retain];
    }
    return _italicFont;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyle*)linkStyle {
    if (!_linkStyle) {
        _linkStyle = [TTSTYLE(linkText:) retain];
    }
    return _linkStyle;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyledNode*)lastNode {
    if (!_lastNode) {
        _lastNode = [self findLastNode:_rootNode];
    }
    return _lastNode;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)offsetFrame:(TTStyledFrame*)frame by:(CGFloat)y {
    frame.y += y;
    
    if ([frame isKindOfClass:[TTStyledInlineFrame class]]) {
        TTStyledInlineFrame* inlineFrame = (TTStyledInlineFrame*)frame;
        TTStyledFrame* child = inlineFrame.firstChildFrame;
        while (child) {
            [self offsetFrame:child by:y];
            child = child.nextFrame;
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)offsetFrame:(TTStyledFrame*)frame byX:(CGFloat)x {
    frame.x += x;
    
    if ([frame isKindOfClass:[TTStyledInlineFrame class]]) {
        TTStyledInlineFrame* inlineFrame = (TTStyledInlineFrame*)frame;
        TTStyledFrame* child = inlineFrame.firstChildFrame;
        while (child) {
            [self offsetFrame:child byX:x];
            child = child.nextFrame;
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)expandLineWidth:(CGFloat)width {
    _lineWidth += width;
    TTStyledInlineFrame* inlineFrame = _inlineFrame;
    while (inlineFrame) {
        inlineFrame.width += width;
        inlineFrame = inlineFrame.inlineParentFrame;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)inflateLineHeight:(CGFloat)height {
    if (height > _lineHeight) {
        _lineHeight = height;
    }
    if (_inlineFrame) {
        TTStyledInlineFrame* inlineFrame = _inlineFrame;
        while (inlineFrame) {
            if (height > inlineFrame.height) {
                inlineFrame.height = height;
            }
            inlineFrame = inlineFrame.inlineParentFrame;
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addFrame:(TTStyledFrame*)frame {
    if (!_rootFrame) {
        _rootFrame = [frame retain];
        
    } else if (_topFrame) {
        if (!_topFrame.firstChildFrame) {
            _topFrame.firstChildFrame = frame;
            
        } else {
            _lastFrame.nextFrame = frame;
        }
        
    } else {
        _lastFrame.nextFrame = frame;
    }
    _lastFrame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pushFrame:(TTStyledBoxFrame*)frame {
    [self addFrame:frame];
    frame.parentFrame = _topFrame;
    _topFrame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)popFrame {
    _lastFrame = _topFrame;
    _topFrame = _topFrame.parentFrame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyledFrame*)addContentFrame:(TTStyledFrame*)frame width:(CGFloat)width {
    [self addFrame:frame];
    if (!_lineFirstFrame) {
        _lineFirstFrame = frame;
    }
    _x += width;
    return frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addContentFrame:(TTStyledFrame*)frame width:(CGFloat)width height:(CGFloat)height {
    frame.bounds = CGRectMake(_x, _height, width, height);
    [self addContentFrame:frame width:width];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addAbsoluteFrame:(TTStyledFrame*)frame width:(CGFloat)width height:(CGFloat)height {
    frame.bounds = CGRectMake(_x, _height, width, height);
    [self addFrame:frame];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyledInlineFrame*)addInlineFrame:(TTStyle*)style element:(TTStyledElement*)element
                                 width:(CGFloat)width height:(CGFloat)height {
    TTStyledInlineFrame* frame = [[[TTStyledInlineFrame alloc] initWithElement:element] autorelease];
    frame.style = style;
    frame.bounds = CGRectMake(_x, _height, width, height);
    [self pushFrame:frame];
    if (!_lineFirstFrame) {
        _lineFirstFrame = frame;
    }
    return frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyledInlineFrame*)cloneInlineFrame:(TTStyledInlineFrame*)frame {
    TTStyledInlineFrame* parent = frame.inlineParentFrame;
    if (parent) {
        [self cloneInlineFrame:parent];
    }
    
    TTStyledInlineFrame* clone = [self addInlineFrame:frame.style element:frame.element
                                                width:0 height:0];
    clone.inlinePreviousFrame = frame;
    frame.inlineNextFrame = clone;
    return clone;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyledFrame*)addBlockFrame:(TTStyle*)style element:(TTStyledElement*)element
                          width:(CGFloat)width height:(CGFloat)height {
    TTStyledBoxFrame* frame = [[[TTStyledBoxFrame alloc] initWithElement:element] autorelease];
    frame.style = style;
    frame.bounds = CGRectMake(_x, _height, width, height);
    [self pushFrame:frame];
    return frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)checkFloats {
    if (_floatHeight && _height > _floatHeight) {
        _minX -= _floatLeftWidth;
        _width += _floatLeftWidth+_floatRightWidth;
        _floatRightWidth = 0;
        _floatLeftWidth = 0;
        _floatHeight = 0;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)breakLine {
    
    if (_inlineFrame) {
        TTStyledInlineFrame* inlineFrame = _inlineFrame;
        while (inlineFrame) {
            if (inlineFrame.style) {
                TTBoxStyle* padding = [inlineFrame.style firstStyleOfClass:[TTBoxStyle class]];
                if (padding) {
                    TTStyledInlineFrame* inlineFrame2 = inlineFrame;
                    while (inlineFrame2) {
                        inlineFrame2.y -= padding.padding.top;
                        inlineFrame2.height += padding.padding.top+padding.padding.bottom;
                        inlineFrame2 = inlineFrame2.inlineParentFrame;
                    }
                }
            }
            inlineFrame = inlineFrame.inlineParentFrame;
        }
    }
    
    // Vertically align all frames on the current line
    if (_lineFirstFrame.nextFrame) {
        TTStyledFrame* frame;
        
        // Find the descender that descends the farthest below the baseline.
        // font.descender is a negative number if the descender descends below
        // the baseline (as most descenders do), but can also be a positive
        // number for a descender above the baseline.
        CGFloat lowestDescender = MAXFLOAT;
        frame = _lineFirstFrame;
        while (frame) {
            UIFont* font = frame.font ? frame.font : _font;
            lowestDescender = MIN(lowestDescender, font.descender);
            frame = frame.nextFrame;
        }
        
        frame = _lineFirstFrame;
        while (frame) {
            // Align to the text baseline
            // XXXjoe Support top, bottom, and center alignment also
            if (frame.height < _lineHeight) {
                UIFont* font = frame.font ? frame.font : _font;
                [self offsetFrame:frame by:(_lineHeight - (frame.height -
                                                           (lowestDescender - font.descender)))];
            }
            frame = frame.nextFrame;
        }
    }
    
    // Horizontally align all frames on current line if required
    if (_textAlignment != NSTextAlignmentLeft) {
        CGFloat remainingSpace = _width - _lineWidth;
        CGFloat offset = _textAlignment == NSTextAlignmentCenter ? remainingSpace/2 : remainingSpace;
        
        TTStyledFrame* frame = _lineFirstFrame;
        while (frame) {
            [self offsetFrame:frame byX:offset];
            frame = frame.nextFrame;
        }
    }
    
    if (_lineHeight)
    {
        lines ++;
        if(lines <= maxLines)
            _height += _lineHeight;
    }
    
    [self checkFloats];
    
    _lineWidth = 0;
    _lineHeight = 0;
    _x = _minX;
    _lineFirstFrame = nil;
    
    if (_inlineFrame) {
        while ([_topFrame isKindOfClass:[TTStyledInlineFrame class]]) {
            [self popFrame];
        }
        _inlineFrame = [self cloneInlineFrame:_inlineFrame];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTStyledFrame*)addFrameForText:(NSString*)text element:(TTStyledElement*)element
                             node:(TTStyledTextNode*)node width:(CGFloat)width height:(CGFloat)height {
    
    TTStyledTextFrame* frame = [[[TTStyledTextFrame alloc] initWithText:text element:element
                                                                   node:node] autorelease];
    frame.font = _font;
    [self addContentFrame:frame width:width height:height];
    return frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutElement:(TTStyledElement*)elt {
    TTStyle* style = nil;
    if (elt.className) {
        TTStyle* eltStyle = [[TTStyleSheet globalStyleSheet] styleWithSelector:elt.className];
        if (eltStyle) {
            style = eltStyle;
        }
    }
    if (!style && [elt isKindOfClass:[TTStyledLinkNode class]]) {
        style = self.linkStyle;
    }
    
    // Figure out which font to use for the node
    UIFont* font = nil;
    TTTextStyle* textStyle = nil;
    if (style) {
        textStyle = [style firstStyleOfClass:[TTTextStyle class]];
        if (textStyle) {
            font = textStyle.font;
        }
    }
    if (!font) {
//        if ([elt isKindOfClass:[TTStyledLinkNode class]]
//            || [elt isKindOfClass:[TTStyledBoldNode class]]) {
        if ([elt isKindOfClass:[TTStyledBoldNode class]]) {
            font = self.boldFont;
            
        } else if ([elt isKindOfClass:[TTStyledItalicNode class]]) {
            font = self.italicFont;
            
        } else {
            font = self.font;
        }
    }
    
    UIFont* lastFont = _font;
    self.font = font;
    
    TTBoxStyle* padding = style ? [style firstStyleOfClass:[TTBoxStyle class]] : nil;
    
    if (padding && padding.position) {
        TTStyledFrame* blockFrame = [self addBlockFrame:style element:elt width:_width height:_height];
        
        CGFloat contentWidth = padding.margin.left + padding.margin.right;
        CGFloat contentHeight = padding.margin.top + padding.margin.bottom;
        
        if (elt.firstChild) {
            TTStyledNode* child = elt.firstChild;
            TTStyledLayout* layout = [[[TTStyledLayout alloc] initWithX:_minX
                                                                  width:0 height:_height] autorelease];
            layout.font = _font;
            layout.invalidImages = _invalidImages;
            [layout layout:child];
            if (!_invalidImages && layout.invalidImages) {
                _invalidImages = [layout.invalidImages retain];
            }
            
            TTStyledFrame* frame = [self addContentFrame:layout.rootFrame width:layout.width];
            
            CGFloat frameHeight = layout.height - _height;
            contentWidth += layout.width;
            contentHeight += frameHeight;
            
            if (padding.position == TTPositionFloatLeft) {
                frame.x += _floatLeftWidth;
                _floatLeftWidth += contentWidth;
                if (_height+contentHeight > _floatHeight) {
                    _floatHeight = contentHeight+_height;
                }
                _minX += contentWidth;
                _width -= contentWidth;
                
            } else if (padding.position == TTPositionFloatRight) {
                frame.x += _width - (_floatRightWidth + contentWidth);
                _floatRightWidth += contentWidth;
                if (_height+contentHeight > _floatHeight) {
                    _floatHeight = contentHeight+_height;
                }
                _x -= contentWidth;
                _width -= contentWidth;
            }
            
            blockFrame.width = layout.width + padding.padding.left + padding.padding.right;
            blockFrame.height = frameHeight + padding.padding.top + padding.padding.bottom;
        }
        
    } else {
        CGFloat minX = _minX, width = _width, floatLeftWidth = _floatLeftWidth,
        floatRightWidth = _floatRightWidth, floatHeight = _floatHeight;
        BOOL isBlock = [elt isKindOfClass:[TTStyledBlock class]];
        TTStyledFrame* blockFrame = nil;
        
        if (isBlock) {
            if (padding) {
                _x += padding.margin.left;
                _minX += padding.margin.left;
                _width -= padding.margin.left + padding.margin.right;
                _height += padding.margin.top;
            }
            
            if (_lastFrame) {
                if (!_lineHeight && [elt isKindOfClass:[TTStyledLineBreakNode class]]) {
                    _lineHeight = [_font ttLineHeight];
                }
                [self breakLine];
            }
            if (style) {
                blockFrame = [self addBlockFrame:style element:elt width:_width height:_height];
            }
            
        } else {
            if (padding) {
                _x += padding.margin.left;
                _height += padding.margin.top;
            }
            if (style) {
                _inlineFrame = [self addInlineFrame:style element:elt width:0 height:0];
            }
        }
        
        if (padding) {
            if (isBlock) {
                _minX += padding.padding.left;
            }
            _width -= padding.padding.left+padding.padding.right;
            _x += padding.padding.left;
            [self expandLineWidth:padding.padding.left];
            
            if (isBlock) {
                _height += padding.padding.top;
            }
        }
        
        if (elt.firstChild) {
            [self layout:elt.firstChild container:elt];
        }
        
        if (isBlock) {
            _minX = minX, _width = width, _floatLeftWidth = floatLeftWidth,
            _floatRightWidth = floatRightWidth, _floatHeight = floatHeight;
            [self breakLine];
            
            if (padding) {
                _height += padding.padding.bottom;
            }
            
            blockFrame.height = _height - blockFrame.height;
            
            if (padding) {
                if (blockFrame.height < padding.minSize.height) {
                    _height += padding.minSize.height - blockFrame.height;
                    blockFrame.height = padding.minSize.height;
                }
                
                _height += padding.margin.bottom;
            }
            
        } else if (!isBlock && style) {
            if (padding) {
                _x += padding.padding.right + padding.margin.right;
                _lineWidth += padding.padding.right + padding.margin.right;
                
                TTStyledInlineFrame* inlineFrame = _inlineFrame;
                while (inlineFrame) {
                    if (inlineFrame != _inlineFrame) {
                        inlineFrame.width += padding.margin.right;
                    }
                    inlineFrame.width += padding.padding.right;
                    inlineFrame.y -= padding.padding.top;
                    inlineFrame.height += padding.padding.top+padding.padding.bottom;
                    inlineFrame = inlineFrame.inlineParentFrame;
                }
            }
            _inlineFrame = _inlineFrame.inlineParentFrame;
        }
    }
    
    self.font = lastFont;
    
    if (style) {
        [self popFrame];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutImage:(TTStyledImageNode*)imageNode container:(TTStyledElement*)element {
    UIImage* image = imageNode.image;
    if (!image && imageNode.URL) {
        if (!_invalidImages) {
            _invalidImages = TTCreateNonRetainingArray();
        }
        [_invalidImages addObject:imageNode];
    }
    
    TTStyle* style = imageNode.className
    ? [[TTStyleSheet globalStyleSheet] styleWithSelector:imageNode.className] : nil;
    TTBoxStyle* padding = style ? [style firstStyleOfClass:[TTBoxStyle class]] : nil;
    
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    if (imageNode.adjustsSizeToFitFont)
    {
        if (!_ajustImageHeight)
        {
            _ajustImageHeight =  [_font ttLineHeight];
        }
        imageWidth = imageHeight = _ajustImageHeight;
    }
    else
    {
        imageWidth = imageNode.width ? imageNode.width : image.size.width;
        imageHeight = imageNode.height ? imageNode.height : image.size.height;
    }
    CGFloat contentWidth = imageWidth;
    CGFloat contentHeight = imageHeight;
    
    if (padding && padding.position != TTPositionAbsolute) {
        _x += padding.margin.left;
        contentWidth += padding.margin.left + padding.margin.right;
        contentHeight += padding.margin.top + padding.margin.bottom;
    }
    
    if ((!padding || !padding.position) && (_lineWidth + contentWidth > _width)) {
        if (_lineWidth) {
            // The image will be placed on the next line, so create a new frame for
            // the current line and mark it with a line break
            [self breakLine];
            if(lines > maxLines)
            {
                _width = 0;
            }
        } else {
            _width = contentWidth;
        }
    }
    
    TTStyledImageFrame* frame = [[[TTStyledImageFrame alloc] initWithElement:element
                                                                        node:imageNode] autorelease];
    frame.whichLable = self.whichLable;
    frame.style = style;
    
    if (!padding || !padding.position) {
        [self addContentFrame:frame width:imageWidth height:imageHeight];
        [self expandLineWidth:contentWidth];
        [self inflateLineHeight:contentHeight];
        
    } else if (padding.position == TTPositionAbsolute) {
        [self addAbsoluteFrame:frame width:imageWidth height:imageHeight];
        frame.x += padding.margin.left;
        frame.y += padding.margin.top;
        
    } else if (padding.position == TTPositionFloatLeft) {
        [self addContentFrame:frame width:imageWidth height:imageHeight];
        
        frame.x += _floatLeftWidth;
        _floatLeftWidth += contentWidth;
        if (_height+contentHeight > _floatHeight) {
            _floatHeight = contentHeight+_height;
        }
        _minX += contentWidth;
        _width -= contentWidth;
        
    } else if (padding.position == TTPositionFloatRight) {
        [self addContentFrame:frame width:imageWidth height:imageHeight];
        
        frame.x += _width - (_floatRightWidth + contentWidth);
        _floatRightWidth += contentWidth;
        if (_height+contentHeight > _floatHeight) {
            _floatHeight = contentHeight+_height;
        }
        _x -= contentWidth;
        _width -= contentWidth;
    }
    
    if (padding && padding.position != TTPositionAbsolute) {
        frame.y += padding.margin.top;
        _x += padding.margin.right;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutText:(TTStyledTextNode*)textNode container:(TTStyledElement*)element {
    NSString* text = textNode.text;
    NSUInteger length = text.length;
    
    if (!textNode.nextSibling && textNode == _rootNode) {
        // This is the only node, so measure it all at once and move on
        CGSize textSize;
        if(!maxLines  || maxLines == INT_MAX)
        {
            if(!maxLines)
            {
                textSize = [text loocha_sizeWithFont:_font
                                   constrainedToSize:CGSizeMake(_width, CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
            }
            else
            {
                textSize = [text loocha_sizeWithFont:_font
                                   constrainedToSize:CGSizeMake(_width, maxLines * [_font ttLineHeight])
                                       lineBreakMode:NSLineBreakByWordWrapping];
            }
            if (textSize.width > _width) {
                textSize.width = _width;
            }
            [self addFrameForText:text element:element node:textNode width:textSize.width
                           height:textSize.height];
            _height += textSize.height;
            return;
        }
    }
    
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSInteger stringIndex = 0;
    NSInteger lineStartIndex = 0;
    CGFloat frameWidth = 0.0f;
    NSInteger frameStart = 0;
    
    while (stringIndex < length) {
        // Search for the next whitespace character
        NSRange searchRange = NSMakeRange(stringIndex, length - stringIndex);
        NSRange spaceRange = [text rangeOfCharacterFromSet:whitespace options:0 range:searchRange];
        
        // Get the word prior to the whitespace
        NSRange wordRange = spaceRange.location != NSNotFound
        ? NSMakeRange(searchRange.location, (spaceRange.location+1) - searchRange.location)
        : NSMakeRange(searchRange.location, length - searchRange.location);
        NSString* word = [text substringWithRange:wordRange];
        
        // If there is no width to constrain to, then just use an infinite width,
        // which will prevent any word wrapping
        CGFloat availWidth = _width ? _width : CGFLOAT_MAX;
        
        // Measure the word and check to see if it fits on the current line
        CGSize wordSize = [word loocha_sizeWithFont:_font];
        if (_lineWidth + wordSize.width > _width) {
            for (NSInteger i = 0; i < word.length; ++i) {
                NSString* c = [word substringWithRange:NSMakeRange(i, 1)];
                CGSize letterSize = [c loocha_sizeWithFont:_font];
                
                if (_lineWidth + letterSize.width > _width) {
                    NSRange lineRange = NSMakeRange(lineStartIndex, stringIndex - lineStartIndex);
                    if (lineRange.length)
                    {
                        NSString* line = nil;
                         if (lines == maxLines-1 && lineRange.length  >3)
                         { //    加省略...  dxw
                             //假设 ...  是所有3个字符中width 最小的
                             NSString *suspensionStr = @"...";
                              line = [NSString stringWithFormat:@"%@%@",[text substringWithRange:NSMakeRange(lineRange.location, lineRange.length - 3)],suspensionStr];
                         }
                        else
                        {
                            line = [text substringWithRange:lineRange];

                        }
                        
                        frameWidth = [[text substringWithRange:NSMakeRange(frameStart,
                                                                           stringIndex - frameStart)]
                                      loocha_sizeWithFont:_font].width;
                        [self addFrameForText:line element:element node:textNode width:frameWidth
                                       height:[_font ttLineHeight]];
                    }
                    
                    if (_lineWidth)
                    {
                        [self breakLine];
                        if(lines >= maxLines)
                        {
                              return;
                        }
                    }
                    
                    lineStartIndex = lineRange.location + lineRange.length;
                    frameStart = stringIndex;
                }
                
                [self expandLineWidth:letterSize.width];
                [self inflateLineHeight:wordSize.height];
                ++stringIndex;
            }
            
            NSRange lineRange = NSMakeRange(lineStartIndex, stringIndex - lineStartIndex);
            if (lineRange.length) {
                NSString* line = [text substringWithRange:lineRange];
                frameWidth = [[text substringWithRange:NSMakeRange(frameStart, stringIndex - frameStart)]
                              loocha_sizeWithFont:_font].width;
                [self addFrameForText:line element:element node:textNode width:frameWidth
                               height:[_font ttLineHeight]];
                
                lineStartIndex = lineRange.location + lineRange.length;
                frameStart = stringIndex;
            }
            
        } else {
            if (_lineWidth + wordSize.width > _width) {
                // The word will be placed on the next line, so create a new frame for
                // the current line and mark it with a line break
                NSRange lineRange = NSMakeRange(lineStartIndex, stringIndex - lineStartIndex);
                if (lineRange.length) {
                    NSString* line = [text substringWithRange:lineRange];
                    frameWidth = [[text substringWithRange:NSMakeRange(frameStart, stringIndex - frameStart)]
                                  loocha_sizeWithFont:_font].width;
                    [self addFrameForText:line element:element node:textNode width:frameWidth
                                   height:[_font ttLineHeight]];
                }
                
                if (_lineWidth) {
                    [self breakLine];
                    if(lines > maxLines)
                        return;
                }
                lineStartIndex = lineRange.location + lineRange.length;
                frameStart = stringIndex;
            }
            
            if (!_lineWidth && textNode == _lastNode) {
                // We are at the start of a new line, and this is the last node, so we don't need to
                // keep measuring every word.  We can just measure all remaining text and create a new
                // frame for all of it.
                NSString* lines = [text substringWithRange:searchRange];
                CGSize linesSize = [lines loocha_sizeWithFont:_font
                                            constrainedToSize:CGSizeMake(availWidth, CGFLOAT_MAX)
                                                lineBreakMode:NSLineBreakByWordWrapping];
                if (linesSize.width > availWidth) {
                    linesSize.width = availWidth;
                }
                [self addFrameForText:lines element:element node:textNode width:linesSize.width
                               height:linesSize.height];
                _height += linesSize.height;
                break;
            }
            
            [self expandLineWidth:wordSize.width];
            [self inflateLineHeight:wordSize.height];
            
            stringIndex = wordRange.location + wordRange.length;
            if (stringIndex >= length) {
                // The current word was at the very end of the string
                NSRange lineRange = NSMakeRange(lineStartIndex, (wordRange.location + wordRange.length)
                                                - lineStartIndex);
                NSString* line = !_lineWidth ? word : [text substringWithRange:lineRange];
                frameWidth = [[text substringWithRange:NSMakeRange(frameStart, stringIndex - frameStart)]
                              loocha_sizeWithFont:_font].width;
                [self addFrameForText:line element:element node:textNode width:frameWidth
                               height:[_font ttLineHeight]];
                frameWidth = 0;
            }
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
    if (!_font) {
        self.font =[(TTDefaultStyleSheet *)[TTStyleSheet globalStyleSheet] font];
        //TTSTYLEVAR(font);
    }
    return _font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
    if (font != _font) {
        [_font release];
        _font = [font retain];
        TT_RELEASE_SAFELY(_boldFont);
        TT_RELEASE_SAFELY(_italicFont);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layout:(TTStyledNode*)node container:(TTStyledElement*)element {
    while (node) {
        if ([node isKindOfClass:[TTStyledImageNode class]]) {
            TTStyledImageNode* imageNode = (TTStyledImageNode*)node;
            [self layoutImage:imageNode container:element];
            
        } else if ([node isKindOfClass:[TTStyledElement class]]) {
            TTStyledElement* elt = (TTStyledElement*)node;
            [self layoutElement:elt];
            
        } else if ([node isKindOfClass:[TTStyledTextNode class]]) {
            TTStyledTextNode* textNode = (TTStyledTextNode*)node;
            [self layoutText:textNode container:element];
        }
        if(lines >= maxLines)
            node.nextSibling = nil;
        node = node.nextSibling;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layout:(TTStyledNode*)node {
    [self layout:node container:nil];
    if (_lineWidth) {
        [self breakLine];
    }
}

+(void)setLines:(int)line
{
    lines = line;
}


@end
