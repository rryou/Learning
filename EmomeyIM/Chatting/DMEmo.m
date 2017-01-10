//
//  DMEmo.m
//  LoochaCampus
//
//  Created by 胡恒恺 on 1/30/13.
//
//

#import "DMEmo.h"
@implementation DMEmo
@synthesize name = _name;
@synthesize src = _src;
@synthesize id = _id;
@synthesize type;
-(id)initWithName:(NSString *)name src:(NSString *)src
{
    self = [super init];
    if(self)
    {
        self.name = name;
        self.src = src;
    }
    return self;
}


-(id)initFromDic:(NSDictionary *)dic
{
    self = [super init];
    if(self)
    {
        self.name = [dic valueForKey:@"name"];
        self.src = [dic valueForKey:@"src"];
        self.id = [dic valueForKey:@"id"];
    }
    return self;
}

-(void)dealloc{

}

+ (DMEmo *)generateDMEmoFromDic:(NSDictionary *)dic
{
    DMEmo *emo = [[DMEmo alloc] initFromDic:dic];
    return emo;
}

-(NSDictionary *)dictionary {
    return [self dictionaryWithValuesForKeys:@[@"name", @"src", @"id"]];
}

@end
