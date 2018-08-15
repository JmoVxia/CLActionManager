//
//  CLActionManager.m
//  CLActionManager
//
//  Created by AUG on 2018/8/12.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "CLActionManager.h"
#import <objc/message.h>

static void *CLActionBlock = "CLActionBlock";
static void *CLActionMainThread = "CLActionMainThread";
static void *CLActionMethodType = "CLActionMethodType";


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
        self.semaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_signal(self.semaphore);
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

+ (void)addObserver:(id)observer actionType:(CLActionType)actionType mainThread:(BOOL)mainThread block:(void(^)(id observer, NSDictionary *dictionary))block {
    //增加信号保证线程安全
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //动态设置block
    objc_setAssociatedObject(observer, CLActionBlock, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //动态设置是否主线程
    objc_setAssociatedObject(observer, CLActionMainThread, [NSNumber numberWithBool:mainThread], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //动态设置方法类型，用于保障监听和调用方式成对，互不干扰
    objc_setAssociatedObject(observer, CLActionMethodType, [NSNumber numberWithBool:1], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //内存地址+MD5Key，使用内存地址保证一个对象只监听一次，增加MD5Key保证是同一类型
    NSString *key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], [self keyWithActionType:actionType]];
    //添加到字典
    [[CLActionManager sharedManager].mapTable setObject:observer forKey:key];
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}


+ (void)actionWithDictionary:(NSDictionary *)dictionary actionType:(CLActionType)actionType {
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //key数组
    NSArray<NSString *> *keyArray = [[[CLActionManager sharedManager].mapTable keyEnumerator] allObjects];
    //遍历查找所有key
    [keyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger __unused idx, BOOL * _Nonnull __unused stop) {
        //找出对应类型的观察者
        if ([key containsString:[self keyWithActionType:actionType]]) {
            id observer = [[CLActionManager sharedManager].mapTable objectForKey:key];
            //取出block
            void(^block)(id observer, NSDictionary *dictionary) = objc_getAssociatedObject(observer, CLActionBlock);
            BOOL mainThread = [(NSNumber *)objc_getAssociatedObject(observer, CLActionMainThread) boolValue];
            BOOL actionMethod = [(NSNumber *)objc_getAssociatedObject(observer, CLActionMethodType) isEqualToNumber:@1];
            //block存在并且是对应方法添加，调用block
            if (block && actionMethod) {
                if (mainThread) {
                    //主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(observer, dictionary);
                    });
                }else {
                    //子线程
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        block(observer, dictionary);
                    });
                }
            }
        }
    }];
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}

+ (NSString *)keyWithActionType:(CLActionType)actionType {
    NSString *key;
    switch (actionType) {
        case CLActionTextChange:
            key = @"CLActionTextChange";
            break;
        case CLActionColorChange:
            key = @"CLActionColorChange";
            break;
        case CLActionImageChange:
            key = @"CLActionImageChange";
            break;
    }
    return key;
}


+ (void)addObserver:(id)observer identifier:(NSString *)identifier mainThread:(BOOL)mainThread block:(void(^)(id observer, NSDictionary *dictionary))block {
    //增加信号保证线程安全
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //动态设置属性
    objc_setAssociatedObject(observer, CLActionBlock, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(observer, CLActionMainThread, [NSNumber numberWithBool:mainThread], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(observer, CLActionMethodType, [NSNumber numberWithBool:0], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], identifier];
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
        if ([key containsString:identifier]) {
            id observer = [[CLActionManager sharedManager].mapTable objectForKey:key];
            //取出block
            void(^block)(id observer, NSDictionary *dictionary) = objc_getAssociatedObject(observer, CLActionBlock);
            BOOL mainThread = [(NSNumber *)objc_getAssociatedObject(observer, CLActionMainThread) boolValue];
            BOOL actionMethod = [(NSNumber *)objc_getAssociatedObject(observer, CLActionMethodType) isEqualToNumber:@0];
            //调用
            if (block && actionMethod) {
                if (mainThread) {
                    //主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(observer, dictionary);
                    });
                }else {
                    //子线程
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        block(observer, dictionary);
                    });
                }
            }
        }
    }];
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}
@end
