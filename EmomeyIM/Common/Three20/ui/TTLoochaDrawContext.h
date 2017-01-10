//
//  TTLoochaDrawContext.h
//  LoochaCampusMain
//
//  Created by zhang jinquan on 9/24/14.
//  Copyright (c) 2014 Real Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TTLoochaDrawContext : NSObject

@property (nonatomic, retain) UIColor *foregroundColor;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) NSParagraphStyle *paragraphStyle;

+ (TTLoochaDrawContext *)sharedInstance;

- (void)reset;

@end

TTLoochaDrawContext *TTLoochaGetDrawContext();

#define ttLoochaDrawContext TTLoochaGetDrawContext()
