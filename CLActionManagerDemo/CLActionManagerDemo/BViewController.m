//
//  BViewController.m
//  CLActionManagerDemo
//
//  Created by AUG on 2018/8/12.
//  Copyright © 2018年 JmoVxia. All rights reserved.
//

#import "BViewController.h"
#import "CLActionManager.h"
#import "CLHeaderView.h"


@interface BViewController ()


/*imageView*/
@property (nonatomic, strong) CLHeaderView *headerView;


@end

@implementation BViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(99, 99, 99, 99)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"变色" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeColor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    _headerView = [[CLHeaderView alloc] initWithFrame:CGRectMake(199, 199, 99, 99)];
    _headerView.layer.cornerRadius = 99 * 0.5;
    _headerView.clipsToBounds = YES;
    [self.view addSubview:_headerView];
    
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(199, 99, 99, 99)];
    button1.backgroundColor = [UIColor redColor];
    [button1 setTitle:@"切换图片" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(changeImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];

    
    
        for (NSInteger i = 0; i < 1000; i++) {
            // 开启异步子线程
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [CLActionManager addObserver:self identifier:@"CLActionTextChange" mainThread:YES block:^(BViewController *observer, NSDictionary *dictionary) {
//                    observer.view.backgroundColor = [dictionary objectForKey:@"color"];
//                    NSLog(@"BViewController收到颜色变化，当前线程%@",[NSThread currentThread]);
//                }];
                [CLActionManager addObserver:self actionType:CLActionColorChange mainThread:YES block:^(BViewController *observer, NSDictionary *dictionary) {
                    observer.view.backgroundColor = [dictionary objectForKey:@"color"];
                    NSLog(@"BViewController收到颜色变化，当前线程%@",[NSThread currentThread]);
                }];
            });
        }
}
- (void)changeColor {
    NSDictionary *dict = @{
                           @"color" : randomColor,
                           };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [CLActionManager actionWithDictionary:dict identifier:@"CLActionColorChange"];
        [CLActionManager actionWithDictionary:dict actionType:CLActionColorChange];
    });
}

- (void)changeImage {
    [_headerView loadImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",[self getRandomNumber:1 to:9]]]];
}
-(int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}






-(void)dealloc {
    NSLog(@"++++++++++>>>>BViewController销毁了");
}
@end
