//
//  DMEmo.h
//  LoochaCampus
//
//  Created by 胡恒恺 on 1/30/13.
//
//

#import <Foundation/Foundation.h>
#import "EmojiLayoutAttribute.h"

#define LocalEmoTypeNormal       -1
//#define LocalEmoTypeSpecial      -2


@interface DMEmo : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *src;
@property (nonatomic,copy) NSString *id;
@property (nonatomic,assign)int type;  //-1，-2是本地特殊 以前就有的表情。

@property (nonatomic, retain) EmojiLayoutAttribute *layoutAttribute;

@property (nonatomic,strong)id superData;
@property (nonatomic,strong)id originData;

-(id)initWithName:(NSString *)name src:(NSString *)src;
-(id)initFromDic:(NSDictionary *)dic;
//+(NSArray *)generateDMemoArray:(NSString *)dic;

-(NSDictionary *)dictionary;

+ (DMEmo *)generateDMEmoFromDic:(NSDictionary *)dic;

@end
