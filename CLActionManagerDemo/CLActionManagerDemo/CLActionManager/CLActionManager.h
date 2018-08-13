//
//  CLActionManager.h
//  CLActionManager
//
//  Created by AUG on 2018/8/12.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@interface CLActionManager : NSObject

/**
 添加观察者

 @param observer 观察者
 @param identifier 标识
 @param block 数据回掉
 */
+ (void)addObserver:(id)observer identifier:(NSString *)identifier block:(void(^)(id observer, NSDictionary *dictionary))block;

/**
 调用

 @param dictionary 数据
 @param identifier 标识符
 */
+ (void)actionWithDictionary:(NSDictionary *)dictionary identifier:(NSString *)identifier;





@end
