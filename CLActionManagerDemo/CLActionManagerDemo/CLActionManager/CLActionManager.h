//
//  CLActionManager.h
//  CLActionManager
//
//  Created by AUG on 2018/8/12.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import <Foundation/Foundation.h>

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

typedef NS_ENUM(NSUInteger, CLActionType) {
    CLActionColorChange,///<颜色变化
    CLActionTextChange,///<文字变化
    CLActionImageChange,///<图片变化
};


@interface CLActionManager : NSObject
/*
    所有响应block生命周期和观察者对象生命周期一样，一个对象多次添加同一类型或者同一标识符的观察者，只会添加最后一次，响应的block回掉会随着观察者对象销毁自动销毁，建议使用枚举管理所有标识符
 */


/**
 根据类型添加观察者
 
 @param observer 观察者
 @param actionType 响应类型
 @param block 数据回掉
 */
+ (void)addObserver:(id)observer actionType:(CLActionType)actionType mainThread:(BOOL)mainThread block:(void(^)(id observer, NSDictionary *dictionary))block;

/**
 根据类型调用
 
 @param dictionary 数据
 @param actionType 响应类型
 */
+ (void)actionWithDictionary:(NSDictionary *)dictionary actionType:(CLActionType)actionType;

//------------------------------------字符串作为唯一标识符，内部已经处理，不会和上面枚举方式冲突-------------------------------------


/**
 根据标识符添加观察者

 @param observer 观察者
 @param identifier 标识
 @param mainThread 是否在主线程回掉
 @param block 数据回掉
 */
+ (void)addObserver:(id)observer identifier:(NSString *)identifier mainThread:(BOOL)mainThread block:(void(^)(id observer, NSDictionary *dictionary))block;

/**
 根据标识符调用

 @param dictionary 数据
 @param identifier 标识符
 */
+ (void)actionWithDictionary:(NSDictionary *)dictionary identifier:(NSString *)identifier;





@end
