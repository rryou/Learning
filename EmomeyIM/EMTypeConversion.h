//
//  EMTypeConversion.h
//  yStock
//
//  Created by frank on 15/5/7.
//
//

#import <Foundation/Foundation.h>

@interface EMTypeConversion : NSObject
//字节高低位转换(字符串方式，不带unicode的格式头)——unicode的大端和小端格式转换
+ (NSData *)resetByteSequenceWithShort:(NSData *)data;

+ (NSData *)resetByteSequenceWithInt:(NSData *)data;

+ (NSData *)resetByteSequenceWithInt64:(NSData *)data;

+ (NSData *)resetByteSequenceWithString:(NSData *)data;


//NSData转化为基本类型或字符串(字符串方式，不带unicode的格式头)
+ (int16_t)NSDataConvertShort:(NSData *)data;

+ (int32_t)NSDataConvertInt:(NSData *)data;

+ (int64_t)NSDataConvertInt64:(NSData *)data;

+ (NSString *)NSDataConvertNSString:(NSData *)data;

+ (NSString *)NSDataConvertVChar:(NSData *)data;

//基本类型及字符串转化为NSData(字符串方式，不带unicode的格式头)
+ (int8_t)NSDataConvertChar:(NSData *)data;

+ (NSData *)ShortConvertNSData:(int16_t)uint16;

+ (NSData *)intConvertNSData:(int32_t)uint32;

+ (NSData *)int64ConvertNSData:(int64_t)uint64;

+ (NSData *)NSStringConvertNSData:(NSString *)string;

+ (NSData *)VCharConvertNSData:(NSString *)string;
+ (void )createFileMD5:(NSData *)filedata pcHash:(Byte *)pcHash;
@end



