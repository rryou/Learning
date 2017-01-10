//
//  EMTypeConversion.m
//  yStock
//
//  Created by frank on 15/5/7.
//
//

#import "EMTypeConversion.h"
#import <CommonCrypto/CommonDigest.h>


@implementation EMTypeConversion


#pragma mark - HightLowConvert 字节高低位转换
+ (NSData *)resetByteSequenceWithShort:(NSData *)data;
{
    NSData *result = [self  convertBasicType:data byteNumber:sizeof(int16_t)];
    return result;
}

+ (NSData *)resetByteSequenceWithInt:(NSData *)data;
{
    NSData *result = [self  convertBasicType:data byteNumber:sizeof(int32_t)];
    return result;
}

+ (NSData *)resetByteSequenceWithInt64:(NSData *)data;
{
    NSData *result = [self  convertBasicType:data byteNumber:sizeof(int64_t)];
    return result;
}

+ (NSData *)resetByteSequenceWithString:(NSData *)data;
{
    NSMutableData *result = [[NSMutableData alloc] init];
    //    字节数／2 ＝ 字符个数——比例为2
    NSInteger proportion = sizeof(short);
    NSUInteger charNumber = [data length]/proportion;
    {
        for(int i = 0;i < charNumber; i++)
        {
            NSRange range = NSMakeRange(i * proportion, proportion);
            NSData *tempdata = [data subdataWithRange:range];
            NSData *resetByteData = [self resetByteSequenceWithShort:tempdata];
            [result appendData:resetByteData];
        }
    }
    
    return result;
    
}


#pragma mark common
+ (NSData *)convertBasicType:(NSData *)data byteNumber:(NSUInteger)byteNumber;
{
    
    NSMutableData *result = [[NSMutableData alloc] init];
    if (byteNumber <= [data length])
    {
        Byte *bytes = (Byte *)[data bytes];
        
        for(int i = ((int)[data length] - 1);i >= 0; i--)
        {
            Byte byte = bytes[i];
            Byte tempbytes[] = {byte};
            [result appendBytes:tempbytes length:1];
            
        }
    }
    
    return result;
}

#pragma mark  NSDataConvert NSData转化为基本类型或字符串
+ (int8_t)NSDataConvertChar:(NSData *)data;
{
    int8_t result;  //short
    [data getBytes: &result length: sizeof(result)];
    return result;
}

+ (int16_t)NSDataConvertShort:(NSData *)data;
{
    int16_t result;  //short
    [data getBytes: &result length: sizeof(result)];
    return result;
}

+ (int32_t)NSDataConvertInt:(NSData *)data;
{
    int32_t result;
    [data getBytes: &result length: sizeof(result)];
    return result;
}

+ (int64_t)NSDataConvertInt64:(NSData *)data;
{
    int64_t result;
    [data getBytes: &result length: sizeof(result)];
    return result;
}

+ (NSString *)NSDataConvertNSString:(NSData *)data;
{
    const unichar *a = (unichar *)[data bytes];
    NSUInteger length = data.length/2;  //由于是unicode，是两个字节算一个字，所以长度为：总字节数／2
    NSString *result = [NSString stringWithCharacters:a length:length]; //该函数中的length是每个字符代表两个字节，而不是本身的字节数
    return result;
}

+ (NSString *)NSDataConvertVChar:(NSData *)data;
{
    const unichar *a = (unichar *)[data bytes];
    NSUInteger length = data.length;
    NSString *result = [NSString stringWithCharacters:a length:length];
    return result;
}
#pragma mark  ConvertNSData 基本类型及字符串转化为NSData
+ (NSData *)ShortConvertNSData:(int16_t)uint16;
{
    NSData *data = [NSData dataWithBytes:&uint16 length:sizeof(uint16)];
    return data;
}

+ (NSData *)intConvertNSData:(int32_t)uint32;
{
    NSData *data = [NSData dataWithBytes:&uint32 length:sizeof(uint32)];
    return data;
}

+ (NSData *)int64ConvertNSData:(int64_t)uint64;
{
    NSData *data = [NSData dataWithBytes:&uint64 length:sizeof(uint64)];
    return data;
}

//NSString与nsdata不能直接转换，因为nsdata的函数转换的时候会有格式头。NSString的函数可用，例如：cStringUsingEncoding
+ (NSData *)NSStringConvertNSData:(NSString *)string{
    const char *a = [string cStringUsingEncoding:NSUnicodeStringEncoding];
    NSUInteger length = string.length * 2;  //由于是unicode，是两个字节算一个字.这里的字节长度是字长度＊2
    NSData *result = [NSData dataWithBytes:a length:length];
    return result;
}

+ (NSData *)VCharConvertNSData:(NSString *)string;
{
    const char *a = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if(a){
        NSUInteger length = string.length;
        NSData *result = [NSData dataWithBytes:a length:length];
        return result;}
    else{
            return nil;
    }
}

+ (void )createFileMD5:(NSData *)filedata pcHash:(Byte* )pcHash{
    
    Byte *str = (Byte *)[filedata bytes];
    Byte r[16];
    CC_MD5(str, (int)filedata.length, r);
    memcpy(pcHash, r, 16);
    
}
@end




