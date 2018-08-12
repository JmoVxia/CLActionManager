//
//  CLActionManager.m
//  CLActionManager
//
//  Created by AUG on 2018/8/12.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "CLActionManager.h"
#import <objc/message.h>

static void *CLBlockKey = "CLBlockKey";


@interface CLActionManager ()

/*字典*/
@property (nonatomic, strong) NSMapTable *mapTable;


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
        self.mapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
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

+ (void)addObserver:(id)observer colorChangeBlock:(void(^)(id observer, UIColor *color))block {
    objc_setAssociatedObject(observer, CLBlockKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *key = NSStringFromClass([observer class]);
    [[CLActionManager sharedManager].mapTable setObject:observer forKey:key];
}



+ (void)actionWithColor:(UIColor *)color {
    NSArray<NSString *> *keyArray = [[[CLActionManager sharedManager].mapTable keyEnumerator] allObjects];
    [keyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        id observer = [[CLActionManager sharedManager].mapTable objectForKey:key];
        void(^block)(id observer, UIColor *color) = objc_getAssociatedObject(observer, CLBlockKey);
        if (block) {
            block(observer, color);
        }
    }];
}


@end
