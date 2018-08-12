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




+ (void)addObserver:(id)observer colorChangeBlock:(void(^)(id observer, UIColor *color))block;



+ (void)actionWithColor:(UIColor *)color;





@end
