//
//  SCGIFImageView.h
//  TestGIF
//
//  Created by shichangone on 11-7-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnimatedGifFrame : NSObject
{
	NSData *data;
	NSData *header;
	double delay;
	int disposalMethod;
	CGRect area;
}

@property (nonatomic, strong) NSData *header;
@property (nonatomic, strong) NSData *data;
@property (nonatomic,assign) double delay;
@property (nonatomic, assign) int disposalMethod;
@property (nonatomic, assign) CGRect area;
@end

@interface SCGIFImageView : UIImageView {
	NSData *GIF_pointer;
	NSMutableData *GIF_buffer;
	NSMutableData *GIF_screen;
	NSMutableData *GIF_global;
	NSMutableArray *GIF_frames;
	
	int GIF_sorted;
	int GIF_colorS;
	int GIF_colorC;
	int GIF_colorF;
	int animatedGifDelay;
	
	int dataPointer;
    
    NSData *giftData;
    
    int _rePeatCount;
}
@property (nonatomic, retain) NSMutableArray *GIF_frames;
@property (nonatomic, retain)NSData  *giftData;
@property (nonatomic,retain) UIImage *lastImage;


- (id)initWithGIFFile:(NSString*)gifFilePath;
- (id)initWithGIFData:(NSData*)gifImageData;
- (id)initWithGIFFile:(NSString*)gifFilePath  withAnimationRepeatCount:(int)count;


- (void)loadImageData;

+ (NSMutableArray*)getGifFrames:(NSData*)gifImageData;
+ (BOOL)isGifImage:(NSData*)imageData;

- (void) decodeGIF:(NSData *)GIFData;
- (void) GIFReadExtensions;
- (void) GIFReadDescriptor;
- (bool) GIFGetBytes:(int)length;
- (bool) GIFSkipBytes: (int) length;
- (NSData*) getFrameAsDataAtIndex:(int)index;
- (UIImage*) getFrameAsImageAtIndex:(int)index;

@end
