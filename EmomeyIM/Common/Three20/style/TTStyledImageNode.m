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

#import "TTStyledImageNode.h"

// Network
//#import "TTURLCache.h"

// Core
#import "TTCorePreprocessorMacros.h"
#import "TTGlobalCorePaths.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyledImageNode

@synthesize URL           = _URL;
@synthesize image         = _image;
@synthesize defaultImage  = _defaultImage;
@synthesize width         = _width;
@synthesize height        = _height;

@synthesize adjustsSizeToFitFont;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURL:(NSString*)URL {
	self = [super initWithText:nil next:nil];
  if (self) {
    self.URL = URL;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [self initWithURL:nil];
  if (self) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_URL);
  TT_RELEASE_SAFELY(_image);
  TT_RELEASE_SAFELY(_defaultImage);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)description {
  return [NSString stringWithFormat:@"(%@)", _URL];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTStyledNode


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)outerHTML {
  NSString* html = [NSString stringWithFormat:@"<img src=\"%@\"/>", _URL];
  if (_nextSibling) {
    return [NSString stringWithFormat:@"%@%@", html, _nextSibling.outerHTML];

  } else {
    return html;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setURL:(NSString*)URL
{

//    NSLog(@"dxw node");
  if (nil == _URL || ![URL isEqualToString:_URL])
  {
    [_URL release];
    _URL = [URL retain];

    if (nil != _URL)
    {
        if ([URL hasPrefix:@"emo"])
        {
            self.image = [UIImage imageNamed:URL];
        }
        else if (TTIsBundleURL(URL))
        {
            NSString* path = TTPathForBundleResource([URL substringFromIndex:9]);
            self.image = [UIImage imageWithContentsOfFile:path];
        }
        else
        {
            self.image = nil;
        }
    }
    else
    {
      self.image = nil;
    }
  }
}




@end
