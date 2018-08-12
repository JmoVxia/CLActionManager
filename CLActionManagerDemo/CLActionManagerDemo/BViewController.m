//
//  BViewController.m
//  CLActionManagerDemo
//
//  Created by AUG on 2018/8/12.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "BViewController.h"
#import "CLActionManager.h"
@interface BViewController ()

@end

@implementation BViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(99, 99, 99, 99)];
    button.backgroundColor = randomColor;
    [button addTarget:self action:@selector(changeColor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [CLActionManager addObserver:self colorChangeBlock:^(BViewController *observer, UIColor *color) {
        observer.view.backgroundColor = color;
        NSLog(@"BViewController收到颜色变化");
    }];
}
- (void)changeColor {
    [CLActionManager actionWithColor:randomColor];
}
-(void)dealloc {
    NSLog(@"BViewController销毁了");
}
@end
