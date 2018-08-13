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
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"变色" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeColor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    // 开启异步子线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger i = 0; i < 100; i++) {
            [CLActionManager addObserver:self identifier:@"color" block:^(BViewController *observer, NSDictionary *dictionary) {
                observer.view.backgroundColor = [dictionary objectForKey:@"color"];
                NSLog(@"BViewController收到颜色变化");
            }];
        }
    });
}
- (void)changeColor {
    NSDictionary *dict = @{
                           @"color" : randomColor,
                           };
    [CLActionManager actionWithDictionary:dict identifier:@"color"];
}
-(void)dealloc {
    NSLog(@"++++++++++++>>>>BViewController销毁了");
}
@end
