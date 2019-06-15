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
        [CLActionManager addObserver:self type:CLActionImageChange mainThread:YES actionBlock:^(CLHeaderView *observer, NSDictionary *dictionary) {
            //判断是不是收到自己变化
            if (observer != [dictionary objectForKey:@"observer"]) {
                NSLog(@"----    方式一   =====收到其他地方头像变化了");
                observer.image = [dictionary objectForKey:@"image"];
            }
        }];

        //方式二
        [CLActionManager addObserver:self identifier:@"CLActionImageChange" mainThread:YES actionBlock:^(CLHeaderView *observer, NSDictionary *dictionary) {
            //判断是不是收到自己变化
            if (![observer isEqual:[dictionary objectForKey:@"observer"]]) {
                NSLog(@"----方式二----收到其他地方头像变化了");
                observer.image = [dictionary objectForKey:@"image"];
            }
        }];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)loadImage:(UIImage *)image  type:(NSInteger)type{
    self.image = image;
    NSDictionary *dict = @{
                           @"observer" : self,
                           @"image" : image,
                           };
    if (type == 0) {
        //方式一
        [CLActionManager postType:CLActionImageChange dictionary:dict];
    }else {
        //方式二
        [CLActionManager postIdentifier:@"CLActionImageChange" dictionary:dict];
    }
}

-(void)dealloc {
    NSLog(@"头像View销毁了----%p",self);
}

@end
