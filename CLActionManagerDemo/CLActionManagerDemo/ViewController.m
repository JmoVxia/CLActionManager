//
//  ViewController.m
//  CLActionManagerDemo
//
//  Created by AUG on 2018/8/12.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "ViewController.h"
#import "CLActionManager.h"
#import "AViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(99, 99, 99, 99)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"push" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
//    [CLActionManager addObserver:self identifier:@"color" mainThread:YES block:^(ViewController *observer, NSDictionary *dictionary) {
//        observer.view.backgroundColor = [dictionary objectForKey:@"color"];
//        NSLog(@"ViewController收到颜色变化,当前线程%@",[NSThread currentThread]);
//    }];
    
    [CLActionManager addObserver:self actionType:CLActionColorChange mainThread:YES block:^(ViewController *observer, NSDictionary *dictionary) {
        observer.view.backgroundColor = [dictionary objectForKey:@"color"];
        NSLog(@"ViewController收到颜色变化,当前线程%@",[NSThread currentThread]);
    }];
    
}

- (void)tap {
    [self.navigationController pushViewController:[AViewController new] animated:YES];
}


@end
