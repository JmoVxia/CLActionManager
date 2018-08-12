//
//  AViewController.m
//  CLActionManagerDemo
//
//  Created by AUG on 2018/8/12.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "AViewController.h"
#import "CLActionManager.h"
#import "BViewController.h"
@interface AViewController ()

@end

@implementation AViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(99, 99, 99, 99)];
    button.backgroundColor = randomColor;
    [button addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [CLActionManager addObserver:self colorChangeBlock:^(AViewController *observer, UIColor *color) {
        observer.view.backgroundColor = color;
        NSLog(@"AViewController收到颜色变化");
    }];
}
- (void)tap {
    [self.navigationController pushViewController:[BViewController new] animated:YES];
}
-(void)dealloc {
    NSLog(@"AViewController销毁了");
}
@end
