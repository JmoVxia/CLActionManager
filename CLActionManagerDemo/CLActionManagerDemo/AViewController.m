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
#import "CLHeaderView.h"

@interface AViewController ()

@end

@implementation AViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(99, 99, 99, 99)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"push" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    CLHeaderView *headerView = [[CLHeaderView alloc] initWithFrame:CGRectMake(199, 199, 99, 99)];
    headerView.layer.cornerRadius = 99 * 0.5;
    headerView.clipsToBounds = YES;
    [self.view addSubview:headerView];
    
    
//    [CLActionManager addObserver:self identifier:@"color" mainThread:YES block:^(AViewController *observer, NSDictionary *dictionary) {
//        UIColor *color = [dictionary objectForKey:@"color"];
//        observer.view.backgroundColor = color;
//        NSLog(@"AViewController收到颜色变化,当前线程%@",[NSThread currentThread]);
//    }];

    
    [CLActionManager addObserver:self actionType:CLActionColorChange mainThread:YES block:^(AViewController *observer, NSDictionary *dictionary) {
        UIColor *color = [dictionary objectForKey:@"color"];
        observer.view.backgroundColor = color;
        NSLog(@"AViewController收到颜色变化,当前线程%@",[NSThread currentThread]);
    }];
}

- (void)tap {
    [self.navigationController pushViewController:[BViewController new] animated:YES];
}
-(void)dealloc {
    NSLog(@"--------->>>>AViewController销毁了");
}
@end
