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
#import "CLHeaderView.h"
#import <Masonry/Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"push" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    CLHeaderView *headerView = [[CLHeaderView alloc] init];
    headerView.layer.cornerRadius = 100 * 0.5;
    headerView.clipsToBounds = YES;
    [self.view addSubview:headerView];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(headerView.mas_bottom).mas_offset(90);
    }];

    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.mas_topLayoutGuideBottom).mas_offset(100);
    }];

    [CLActionManager addObserver:self type:CLActionColorChange mainThread:YES actionBlock:^(ViewController *observer, NSDictionary *dictionary) {
        observer.view.backgroundColor = [dictionary objectForKey:@"color"];
        NSLog(@"ViewController收到颜色变化,方式一");
    }];
    [CLActionManager addObserver:self identifier:@"CLActionColorChange" mainThread:YES actionBlock:^(ViewController *observer, NSDictionary *dictionary) {
        observer.view.backgroundColor = [dictionary objectForKey:@"color"];
        NSLog(@"ViewController收到颜色变化,方式二");
    }];
    
}

- (void)tap {
    [self.navigationController pushViewController:[AViewController new] animated:YES];
}


@end
