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
#import <Masonry/Masonry.h>

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))


@interface BViewController ()


/*imageView*/
@property (nonatomic, strong) CLHeaderView *headerView;


@end

@implementation BViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _headerView = [[CLHeaderView alloc] init];
    _headerView.layer.cornerRadius = 100 * 0.5;
    _headerView.clipsToBounds = YES;
    [self.view addSubview:_headerView];
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.center.mas_equalTo(self.view);
    }];

    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"方式一变色" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeColor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 150));
        make.left.mas_equalTo(30);
        make.bottom.mas_equalTo(_headerView.mas_top).mas_offset(-40);
    }];
    
    UIButton *button1 = [[UIButton alloc] init];
    button1.backgroundColor = [UIColor redColor];
    [button1 setTitle:@"方式二变色" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(changeColor1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 150));
        make.right.mas_equalTo(-30);
        make.bottom.mas_equalTo(_headerView.mas_top).mas_offset(-40);
    }];
    
    UIButton *button2 = [[UIButton alloc] init];
    button2.backgroundColor = [UIColor redColor];
    [button2 setTitle:@"方式一切换图片" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(changeImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 150));
        make.left.mas_equalTo(30);
        make.top.mas_equalTo(_headerView.mas_bottom).mas_offset(40);
    }];
    
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(300, 300, 150, 150)];
    button3.backgroundColor = [UIColor orangeColor];
    [button3 setTitle:@"方式二切换图片" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(changeImage2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    [button3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150, 150));
        make.right.mas_equalTo(-30);
        make.top.mas_equalTo(_headerView.mas_bottom).mas_offset(40);
    }];

    
    
    [CLActionManager addObserver:self type:CLActionColorChange mainThread:YES actionBlock:^(BViewController *observer, NSDictionary *dictionary) {
        observer.view.backgroundColor = [dictionary objectForKey:@"color"];
        NSLog(@"BViewController收到颜色变化,方式一");
    }];
    [CLActionManager addObserver:self identifier:@"CLActionColorChange" mainThread:YES actionBlock:^(BViewController *observer, NSDictionary *dictionary) {
        observer.view.backgroundColor = [dictionary objectForKey:@"color"];
        NSLog(@"BViewController收到颜色变化,方式二");
    }];

    
}
- (void)changeColor {
    NSDictionary *dict = @{
                           @"color" : randomColor,
                           };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [CLActionManager postType:CLActionColorChange dictionary:dict];
    });
}
- (void)changeColor1 {
    NSDictionary *dict = @{
                           @"color" : randomColor,
                           };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [CLActionManager postIdentifier:@"CLActionColorChange" dictionary:dict];
    });

}

- (void)changeImage {
    [_headerView loadImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",[self getRandomNumber:1 to:9]]] type:0];
}
- (void)changeImage2 {
    [_headerView loadImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",[self getRandomNumber:1 to:9]]] type:1];
}
-(int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}






-(void)dealloc {
    NSLog(@"++++++++++>>>>BViewController销毁了");
}
@end
