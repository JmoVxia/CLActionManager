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
 添加颜色变化观察者

 @param observer 观察者
 @param block 变化回掉，在主线程调用就在主线程回掉，在子线程调用，就在子线程回掉
 */
+ (void)addObserver:(id)observer colorChangeBlock:(void(^)(id observer, UIColor *color))block;



/**
 颜色变化调用

 @param color 颜色
 */
+ (void)actionWithColor:(UIColor *)color;





@end
