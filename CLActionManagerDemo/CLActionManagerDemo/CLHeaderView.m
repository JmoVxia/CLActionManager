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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [CLActionManager addObserver:self actionType:CLActionImageChange mainThread:YES block:^(CLHeaderView *observer, NSDictionary *dictionary) {
            if (observer != [dictionary objectForKey:@"observer"]) {
                NSLog(@"收到其他地方头像变化了");
                observer.image = [dictionary objectForKey:@"image"];
            }
        }];
    }
    return self;
}
- (void)loadImage:(UIImage *)image {
    self.image = image;
    NSDictionary *dict = @{
                           @"observer" : self,
                           @"image" : image,
                           };
    [CLActionManager actionWithDictionary:dict actionType:CLActionImageChange];
}

-(void)dealloc {
    NSLog(@"头像View销毁了----%@",self);
}

@end
