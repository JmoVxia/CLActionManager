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
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(99, 99, 99, 99)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"变色" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(changeColor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    _headerView = [[CLHeaderView alloc] initWithFrame:CGRectMake(199, 199, 99, 99)];
    _headerView.backgroundColor = [UIColor lightGrayColor];
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
    [_headerView loadImage:[self getImage:[self randomCreatChinese:2]]];
}



//MARK:JmoVxia---生成带文字随机图片
- (NSMutableString*)randomCreatChinese:(NSInteger)count{
    NSMutableString*randomChineseString =@"".mutableCopy;
    for(NSInteger i =0; i < count; i++){
        NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        //随机生成汉字高位
        NSInteger randomH = 0xA1+arc4random()%(0xFE - 0xA1 + 1);
        //随机生成汉子低位
        NSInteger randomL =0xB0+arc4random()%(0xF7 - 0xB0 + 1);
        //组合生成随机汉字
        NSInteger number = (randomH<<8)+randomL;
        NSData *data = [NSData dataWithBytes:&number length:2];
        NSString *string = [[NSString alloc] initWithData:data encoding:gbkEncoding];
        [randomChineseString appendString:string];
    }
    return randomChineseString;
}
- (UIImage *)getImage:(NSString *)name
{
    UIColor *color = randomColor;  //获取随机颜色
    CGRect rect = CGRectMake(0.0f, 0.0f, 99, 99);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString *headerName = nil;
    if (name.length < 3) {
        headerName = name;
    }else{
        headerName = [name substringFromIndex:name.length-2];
    }
    UIImage *headerimg = [self imageToAddText:img withText:headerName];
    return headerimg;
}
//把文字绘制到图片上
- (UIImage *)imageToAddText:(UIImage *)img withText:(NSString *)text
{
    //1.获取上下文
    UIGraphicsBeginImageContext(img.size);
    //2.绘制图片
    [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    //3.绘制文字
    CGRect rect = CGRectMake(0,(img.size.height - 25) / 2.0, img.size.width, 25);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    //文字的属性
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:20],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:[UIColor whiteColor]};
    //将文字绘制上去
    [text drawInRect:rect withAttributes:dic];
    //4.获取绘制到得图片
    UIImage *watermarkImg = UIGraphicsGetImageFromCurrentImageContext();
    //5.结束图片的绘制
    UIGraphicsEndImageContext();
    return watermarkImg;
}




-(void)dealloc {
    NSLog(@"++++++++++>>>>BViewController销毁了");
}
@end
