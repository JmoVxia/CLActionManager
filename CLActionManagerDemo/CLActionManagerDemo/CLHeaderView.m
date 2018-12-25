//
//  CLHeaderView.m
//  CLActionManagerDemo
//
//  Created by AUG on 2018/8/14.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "CLHeaderView.h"
#import "CLActionManager.h"
@implementation CLHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //方式一
        [CLActionManager addObserver:self actionType:CLActionImageChange mainThread:YES block:^(CLHeaderView *observer, NSDictionary *dictionary) {
            //判断是不是收到自己变化
            if (observer != [dictionary objectForKey:@"observer"]) {
                NSLog(@"收到其他地方头像变化了");
                observer.image = [dictionary objectForKey:@"image"];
            }
        }];
        

        //方式二
//        [CLActionManager addObserver:self identifier:@"imageChange" mainThread:YES block:^(CLHeaderView *observer, NSDictionary *dictionary) {
//            //判断是不是收到自己变化
//            if (![observer isEqual:[dictionary objectForKey:@"observer"]]) {
//                NSLog(@"收到其他地方头像变化了,当前线程--%@",[NSThread currentThread]);
//                observer.image = [dictionary objectForKey:@"image"];
//            }
//        }];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)loadImage:(UIImage *)image {
    self.image = image;
    NSDictionary *dict = @{
                           @"observer" : self,
                           @"image" : image,
                           };
    //方式一
    [CLActionManager actionWithDictionary:dict actionType:CLActionImageChange];
    
    //方式二
//    [CLActionManager actionWithDictionary:dict identifier:@"imageChange"];
}

-(void)dealloc {
    NSLog(@"头像View销毁了----%p",self);
}

@end
