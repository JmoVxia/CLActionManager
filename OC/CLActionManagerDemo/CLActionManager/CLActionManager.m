//
//  CLActionManager.m
//  CLActionManager
//
//  Created by AUG on 2018/8/12.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "CLActionManager.h"

@interface CLActionManager ()

@property (nonatomic, strong) NSMapTable *observerMapTable;
@property (nonatomic, strong) NSMapTable *blockDictionaryMapTable;
@property (nonatomic, strong) NSMapTable *mainThreadDictionaryMapTable;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation CLActionManager

static CLActionManager *_manager = nil;

+ (id)allocWithZone:(struct _NSZone __unused*)zone {
    return [self sharedManager];
}

+ (instancetype)sharedManager {
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
        self.observerMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        self.blockDictionaryMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        self.mainThreadDictionaryMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableStrongMemory];
        self.semaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_signal(self.semaphore);
    });
    return _manager;
}
- (id)copyWithZone:(NSZone __unused*)zone {
    return _manager;
}
- (id)mutableCopyWithZone:(NSZone __unused*)zone {
    return _manager;
}
+ (void)addObserver:(id)observer type:(CLActionType)type mainThread:(BOOL)mainThread actionBlock:(void(^)(id observer, NSDictionary *dictionary))actionBlock {
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    NSString *key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], [[self keyWithActionType:type] stringByAppendingString:@"-1"]];
    NSString *actionBlockKey = [key stringByAppendingString:@"-CLActionBlock-1"];
    NSString *actionMainThreadKey = [key stringByAppendingString:@"-CLActionMainThread-1"];

    NSMutableDictionary *blockDictionary = [[CLActionManager sharedManager].blockDictionaryMapTable objectForKey:observer];
    if (!blockDictionary) {
        blockDictionary = [NSMutableDictionary dictionary];
    }
    [blockDictionary setObject:actionBlock forKey:actionBlockKey];

    NSMutableDictionary *mainThreadDictionary = [[CLActionManager sharedManager].mainThreadDictionaryMapTable objectForKey:observer];
    if (!mainThreadDictionary) {
        mainThreadDictionary = [NSMutableDictionary dictionary];
    }
    [mainThreadDictionary setObject:[NSNumber numberWithBool:mainThread] forKey:actionMainThreadKey];

    [[CLActionManager sharedManager].observerMapTable setObject:observer forKey:key];
    [[CLActionManager sharedManager].blockDictionaryMapTable setObject:blockDictionary forKey:observer];
    [[CLActionManager sharedManager].mainThreadDictionaryMapTable setObject:mainThreadDictionary forKey:observer];
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}

+ (void)postType:(CLActionType)type dictionary:(NSDictionary *)dictionary {
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    NSArray<NSString *> *keyArray = [[[CLActionManager sharedManager].observerMapTable keyEnumerator] allObjects];
    NSString *identifier = [[self keyWithActionType:type] stringByAppendingString:@"-1"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@",identifier];
    NSArray<NSString *> *array = [keyArray filteredArrayUsingPredicate:predicate];
    for (NSString *key in array) {
        NSString *actionBlockKey = [key stringByAppendingString:@"-CLActionBlock-1"];
        NSString *actionMainThreadKey = [key stringByAppendingString:@"-CLActionMainThread-1"];
        id observer = [[CLActionManager sharedManager].observerMapTable objectForKey:key];
        NSMutableDictionary *blockDictionary = [[CLActionManager sharedManager].blockDictionaryMapTable objectForKey:observer];
        NSMutableDictionary *mainThreadDictionary = [[CLActionManager sharedManager].mainThreadDictionaryMapTable objectForKey:observer];
        void(^block)(id observer, NSDictionary *dictionary) = [blockDictionary objectForKey:actionBlockKey];
        BOOL mainThread = [[mainThreadDictionary objectForKey:actionMainThreadKey] boolValue];
        if (block) {
            if (mainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(observer, dictionary);
                });
            }else {
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
        case CLActionColorChange:
            key = @"CLActionColorChange";
            break;
        case CLActionImageChange:
            key = @"CLActionImageChange";
            break;
    }
    return key;
}

+ (void)addObserver:(id)observer identifier:(NSString *)identifier mainThread:(BOOL)mainThread actionBlock:(void(^)(id observer, NSDictionary *dictionary))actionBlock {
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    NSString *key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], [identifier stringByAppendingString:@"-0"]];
    NSString *actionBlockKey = [key stringByAppendingString:@"-CLActionBlock-0"];
    NSString *actionMainThreadKey = [key stringByAppendingString:@"-CLActionMainThread-0"];
    NSMutableDictionary *blockDictionary = [[CLActionManager sharedManager].blockDictionaryMapTable objectForKey:observer];
    if (!blockDictionary) {
        blockDictionary = [NSMutableDictionary dictionary];
    }
    [blockDictionary setObject:actionBlock forKey:actionBlockKey];

    NSMutableDictionary *mainThreadDictionary = [[CLActionManager sharedManager].mainThreadDictionaryMapTable objectForKey:observer];
    if (!mainThreadDictionary) {
        mainThreadDictionary = [NSMutableDictionary dictionary];
    }
    [mainThreadDictionary setObject:[NSNumber numberWithBool:mainThread] forKey:actionMainThreadKey];

    [[CLActionManager sharedManager].observerMapTable setObject:observer forKey:key];
    [[CLActionManager sharedManager].blockDictionaryMapTable setObject:blockDictionary forKey:observer];
    [[CLActionManager sharedManager].mainThreadDictionaryMapTable setObject:mainThreadDictionary forKey:observer];
    
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}

+ (void)postIdentifier:(NSString *)identifier dictionary:(NSDictionary *)dictionary {
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    NSArray<NSString *> *keyArray = [[[CLActionManager sharedManager].observerMapTable keyEnumerator] allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@",[identifier stringByAppendingString:@"-0"]];
    NSArray<NSString *> *array = [keyArray filteredArrayUsingPredicate:predicate];
    for (NSString *key in array) {
        NSString *actionBlockKey = [key stringByAppendingString:@"-CLActionBlock-0"];
        NSString *actionMainThreadKey = [key stringByAppendingString:@"-CLActionMainThread-0"];
        id observer = [[CLActionManager sharedManager].observerMapTable objectForKey:key];
        NSMutableDictionary *blockDictionary = [[CLActionManager sharedManager].blockDictionaryMapTable objectForKey:observer];
        NSMutableDictionary *mainThreadDictionary = [[CLActionManager sharedManager].mainThreadDictionaryMapTable objectForKey:observer];
        void(^block)(id observer, NSDictionary *dictionary) = [blockDictionary objectForKey:actionBlockKey];
        BOOL mainThread = [[mainThreadDictionary objectForKey:actionMainThreadKey] boolValue];
        if (block) {
            if (mainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(observer, dictionary);
                });
            }else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    block(observer, dictionary);
                });
            }
        }
    }
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}

@end
