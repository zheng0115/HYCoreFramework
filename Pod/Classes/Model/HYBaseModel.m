//
//  HYModel.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/16.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYBaseModel.h"
#import "MJExtension/MJExtension.h"
#import "HYStorage.h"

@interface HYBaseModel ()

@property (nonatomic, retain, readwrite) NSDictionary *dic;

@end

@implementation HYBaseModel

- (instancetype)init
{
    return [self initWithDictionary:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        [self initExtension];
        return self;
    }
    return nil;
}

- (instancetype)initWithDictionary:(id)dic
{
    self = [super init];
    if (self)
    {
        if (!dic)
        {
            self.dic = nil;
            [self initExtension];
            return self;
        }
        
        
        if ([dic isKindOfClass:[NSDictionary class]])
        {
            self.dic = dic;
        }
        else if ([dic isKindOfClass:[NSData class]])
        {
            self.dic = [NSJSONSerialization JSONObjectWithData:dic
                                                       options:NSJSONReadingMutableContainers
                                                         error:nil];
        }
        else
        {
            NSLog(@"dic to %@ error", [self class]);
        }
        
        [self initExtension];
        
        return self;
    }
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (void)initExtension
{
    
}

- (void)dicMapModelFinish
{
    
}

//MJExtension
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return [[self class] transferDic];
}

//MJExtension
+ (NSDictionary *)mj_objectClassInArray
{
    return [[self class] hy_objectClassInArray];
}

- (void)mj_keyValuesDidFinishConvertingToObject
{
    [self dicMapModelFinish];
}

+ (NSDictionary *)transferDic
{
    return nil;
}

+ (NSDictionary *)hy_objectClassInArray
{
    return nil;
}

#pragma mark setter

- (void)setDic:(NSDictionary *)dic
{
    _dic = dic;
    [self mj_setKeyValues:dic];
}

- (void)setStorageDirectory:(NSString *)storageDirectory
{
    _storageDirectory = [storageDirectory copy];
    
    if (!storageDirectory)
    {
        NSLog(@"storageDirectory must not be nil !!! in %@ model class", [self class]);
        return;
    }
    
    //for tread safe
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if (![fileManager fileExistsAtPath:[_storageDirectory hasPrefix:@"~"] ? [_storageDirectory stringByExpandingTildeInPath] : _storageDirectory])
    {
        NSError *error = nil;
        BOOL result = [fileManager createDirectoryAtPath:_storageDirectory  withIntermediateDirectories:YES attributes:nil error:&error];
        if (!result)
        {
            NSLog(@"%@", error);
        }
    }
}

@end
