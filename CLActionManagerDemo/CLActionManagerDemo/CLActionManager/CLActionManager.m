//
//  CLActionManager.m
//  CLActionManager
//
//  Created by AUG on 2018/8/12.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "CLActionManager.h"
#import <objc/message.h>
#import <CommonCrypto/CommonDigest.h>

static void *CLBlockKey = "CLBlockKey";


@interface CLActionManager ()

/*弱引用字典*/
@property (nonatomic, strong) NSMapTable *mapTable;
/*信号量*/
@property (nonatomic, strong) dispatch_semaphore_t semaphore;


@end

@implementation CLActionManager
//第1步: 存储唯一实例
static CLActionManager *_manager = nil;
//第2步: 分配内存空间时都会调用这个方法. 保证分配内存alloc时都相同.
+(id)allocWithZone:(struct _NSZone *)zone{
    //调用dispatch_once保证在多线程中也只被实例化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}
//第3步: 保证init初始化时都相同
+(instancetype)sharedManager{
    return [[self alloc] init];
}
-(id)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super init];
        //弱引用value，强引用key
        self.mapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        //信号
        self.semaphore = dispatch_semaphore_create(1);
    });
    return _manager;
}
//第4步: 保证copy时都相同
-(id)copyWithZone:(NSZone __unused*)zone{
    return _manager;
}
//第五步: 保证mutableCopy时相同
- (id)mutableCopyWithZone:(NSZone __unused*)zone{
    return _manager;
}

+ (void)addObserver:(id)observer identifier:(NSString *)identifier block:(void(^)(id observer, NSDictionary *dictionary))block;{
    //增加信号保证线程安全
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //动态设置属性
    objc_setAssociatedObject(observer, CLBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *key = [NSString stringWithFormat:@"%@-%@",NSStringFromClass([observer class]),[self MD5ForUpper32Bate:identifier]];
    //添加到字典
    [[CLActionManager sharedManager].mapTable setObject:observer forKey:key];
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}



+ (void)actionWithDictionary:(NSDictionary *)dictionary identifier:(NSString *)identifier {
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //key数组
    NSArray<NSString *> *keyArray = [[[CLActionManager sharedManager].mapTable keyEnumerator] allObjects];
    //遍历查找所有key
    [keyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        //找出对应的观察者
        if ([key containsString:[self MD5ForUpper32Bate:identifier]]) {
            id observer = [[CLActionManager sharedManager].mapTable objectForKey:key];
            //取出block
            void(^block)(id observer, NSDictionary *dictionary) = objc_getAssociatedObject(observer, CLBlockKey);
            //调用
            if (block) {
                block(observer, dictionary);
            }
        }
    }];
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}
/**
 32位 大写
 */
+(NSString *)MD5ForUpper32Bate:(NSString *)str{
    
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    
    return digest;
}

@end
