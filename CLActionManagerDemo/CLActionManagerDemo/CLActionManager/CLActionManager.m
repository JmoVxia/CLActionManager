//
//  CLActionManager.m
//  CLActionManager
//
//  Created by AUG on 2018/8/12.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "CLActionManager.h"
#import <objc/message.h>

@interface CLActionManager ()

@property (nonatomic, strong) NSMapTable *observerMapTable;
@property (nonatomic, strong) NSMapTable *blockKeyMapTable;
@property (nonatomic, strong) NSMapTable *mainThreadKeyMapTable;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation CLActionManager
//第1步: 存储唯一实例
static CLActionManager *_manager = nil;
//第2步: 分配内存空间时都会调用这个方法. 保证分配内存alloc时都相同.
+ (id)allocWithZone:(struct _NSZone __unused*)zone {
    return [self sharedManager];
}
//第3步: 保证init初始化时都相同
+ (instancetype)sharedManager {
    //调用dispatch_once保证在多线程中也只被实例化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[super allocWithZone:NULL] init];
    });
    return _manager;
}
- (id)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super init];
        //弱引用value，强引用key
        self.observerMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        self.blockKeyMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        self.mainThreadKeyMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        //信号
        self.semaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_signal(self.semaphore);
    });
    return _manager;
}
//第4步: 保证copy时都相同
- (id)copyWithZone:(NSZone __unused*)zone {
    return _manager;
}
//第五步: 保证mutableCopy时相同
- (id)mutableCopyWithZone:(NSZone __unused*)zone {
    return _manager;
}

+ (void)addObserver:(id)observer actionType:(CLActionType)actionType mainThread:(BOOL)mainThread block:(void(^)(id observer, NSDictionary *dictionary))block {
    //增加信号保证线程安全
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //内存地址+key，使用内存地址保证一个对象只监听一次，key保证是同一类型
    NSString *key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], [[self keyWithActionType:actionType] stringByAppendingString:@"-1"]];
    NSString *actionBlock = [key stringByAppendingString:@"-CLActionBlock-1"];
    NSString *actionMainThread = [key stringByAppendingString:@"-CLActionMainThread-1"];
    [[CLActionManager sharedManager].observerMapTable setObject:observer forKey:key];
    [[CLActionManager sharedManager].blockKeyMapTable setObject:actionBlock forKey:key];
    [[CLActionManager sharedManager].mainThreadKeyMapTable setObject:actionMainThread forKey:key];
    //动态设置block
    objc_setAssociatedObject(observer, CFBridgingRetain(actionBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    //动态设置是否主线程
    objc_setAssociatedObject(observer, CFBridgingRetain(actionMainThread), [NSNumber numberWithBool:mainThread], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}

+ (void)actionWithDictionary:(NSDictionary *)dictionary actionType:(CLActionType)actionType {
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //key数组
    NSArray<NSString *> *keyArray = [[[CLActionManager sharedManager].observerMapTable keyEnumerator] allObjects];
    //匹配出对应key
    NSString *identifier = [[self keyWithActionType:actionType] stringByAppendingString:@"-1"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@",identifier];
    NSArray<NSString *> *array = [keyArray filteredArrayUsingPredicate:predicate];
    //遍历查找所有key
    for (NSString *key in array) {
        NSString *actionBlock = [[CLActionManager sharedManager].blockKeyMapTable objectForKey:key];
        NSString *actionMainThread = [[CLActionManager sharedManager].mainThreadKeyMapTable objectForKey:key];
        //找出对应类型的观察者
        id observer = [[CLActionManager sharedManager].observerMapTable objectForKey:key];
        //取出block
        void(^block)(id observer, NSDictionary *dictionary) = objc_getAssociatedObject(observer, CFBridgingRetain(actionBlock));
        BOOL mainThread = [(NSNumber *)objc_getAssociatedObject(observer, CFBridgingRetain(actionMainThread)) boolValue];
        //block存在并且是对应方法添加，调用block
        if (block) {
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
    //内存地址+key，使用内存地址保证一个对象只监听一次，key保证是同一类型
    NSString *key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], [identifier stringByAppendingString:@"-0"]];
    NSString *actionBlock = [key stringByAppendingString:@"-CLActionBlock-0"];
    NSString *actionMainThread = [key stringByAppendingString:@"-CLActionMainThread-0"];
    [[CLActionManager sharedManager].observerMapTable setObject:observer forKey:key];
    [[CLActionManager sharedManager].blockKeyMapTable setObject:actionBlock forKey:key];
    [[CLActionManager sharedManager].mainThreadKeyMapTable setObject:actionMainThread forKey:key];
    //动态设置block
    objc_setAssociatedObject(observer, CFBridgingRetain(actionBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    //动态设置是否主线程
    objc_setAssociatedObject(observer, CFBridgingRetain(actionMainThread), [NSNumber numberWithBool:mainThread], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}

+ (void)actionWithDictionary:(NSDictionary *)dictionary identifier:(NSString *)identifier {
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //key数组
    NSArray<NSString *> *keyArray = [[[CLActionManager sharedManager].observerMapTable keyEnumerator] allObjects];
    //匹配出对应key
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@",[identifier stringByAppendingString:@"-0"]];
    NSArray<NSString *> *array = [keyArray filteredArrayUsingPredicate:predicate];
    //遍历查找所有key
    for (NSString *key in array) {
        NSString *actionBlock = [[CLActionManager sharedManager].blockKeyMapTable objectForKey:key];
        NSString *actionMainThread = [[CLActionManager sharedManager].mainThreadKeyMapTable objectForKey:key];
        //找出对应类型的观察者
        id observer = [[CLActionManager sharedManager].observerMapTable objectForKey:key];
        //取出block
        void(^block)(id observer, NSDictionary *dictionary) = objc_getAssociatedObject(observer, CFBridgingRetain(actionBlock));
        BOOL mainThread = [(NSNumber *)objc_getAssociatedObject(observer, CFBridgingRetain(actionMainThread)) boolValue];
        //block存在并且是对应方法添加，调用block
        if (block) {
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
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}

@end
