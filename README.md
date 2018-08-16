
# 前言
iOS开发中，很多情况下会使用到通知，通知的好处很多，但是也有很多坑点，一旦没有管理好，就会造成很多莫名其妙的bug。既然通知使用不当很容易出现问题，那有没有什么办法来避免？经过思考后，决定使用block回调的方式来实现通知，并且避免掉通知的弊端。
# 原理
参考通知原理，采用单例全局管理，单例持有一个字典，字典中储存所有添加的block，在调用block的时候从字典中取出对应的block调用。通知原理参考--->>[深入理解iOS NSNotification
](http://weslyxl.coding.me/2018/03/21/2018/3/%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3iOS%20NSNotification/)

#### 1.完整的单例创建
单例创建需要考虑到各种初始化方法以及拷贝，还有线程安全。具体参考--->>[完整单例模式写法](https://www.jianshu.com/p/e9e6f2f788b9)
#### 2.保证观察者生命周期不受单例影响
因为是单例持有的字典，就会造成block得不到释放，从而引起一系列问题。这里采用`NSMapTable`来储存block，`NSMapTable`使用强引用key，弱引用value，这样做的好处在于，当其中储存的对象销毁后，会自动从`NSMapTable`移除。使用`NSMapTable`可以保证生命周期不受单例影响。具体参考--->>[Cocoa 集合类型：NSPointerArray，NSMapTable，NSHashTable](http://www.saitjr.com/ios/nspointerarray-nsmaptable-nshashtable.html)
#### 3.观察者和block绑定
为了使用简单，并且保证block生命周期和观察者一样，使用`RunTime`动态绑定，将block和观察者绑定起来。具体参考--->>[iOS Runtime详解](https://juejin.im/post/5ac0a6116fb9a028de44d717)
#### 4.保证一个对象只添加一次观察者
多次添加观察者会造成调用的时候响应多次，这里采用对象内存地址和标识符作为字典的key，保证一个对象只添加一次。
#### 5.多线程安全
这里采用GCD信号量来保证线程安全，具体参考--->>[GCD信号量](https://zhangbuhuai.com/dispatch-semaphore/)
#### 6.block循环引用
对于block循环引用，这里采用回调观察者替代self，保证不会循环引用，具体参考--->>[Block循环引用详解](https://www.jianshu.com/p/53cedd7bafa4)

# 代码
上面讲解的就是整个项目实现的关键点，这里贴出具体代码。
#### CLActionManager.h实现代码
```
typedef NS_ENUM(NSUInteger, CLActionType) {
    CLActionColorChange,///<颜色变化
    CLActionTextChange,///<文字变化
    CLActionImageChange,///<图片变化
};


@interface CLActionManager : NSObject
/*
    所有响应block生命周期和观察者对象生命周期一样，一个对象多次添加同一类型或者同一标识符的观察者，只会添加最后一次，响应的block回掉会随着观察者对象销毁自动销毁，建议使用枚举管理所有标识符
 */


/**
 根据类型添加观察者
 
 @param observer 观察者
 @param actionType 响应类型
 @param block 数据回掉
 */
+ (void)addObserver:(id)observer actionType:(CLActionType)actionType mainThread:(BOOL)mainThread block:(void(^)(id observer, NSDictionary *dictionary))block;

/**
 根据类型调用
 
 @param dictionary 数据
 @param actionType 响应类型
 */
+ (void)actionWithDictionary:(NSDictionary *)dictionary actionType:(CLActionType)actionType;

//------------------------------------字符串作为唯一标识符，内部已经处理，不会和上面枚举方式冲突-------------------------------------


/**
 根据标识符添加观察者

 @param observer 观察者
 @param identifier 标识
 @param mainThread 是否在主线程回掉
 @param block 数据回掉
 */
+ (void)addObserver:(id)observer identifier:(NSString *)identifier mainThread:(BOOL)mainThread block:(void(^)(id observer, NSDictionary *dictionary))block;

/**
 根据标识符调用

 @param dictionary 数据
 @param identifier 标识符
 */
+ (void)actionWithDictionary:(NSDictionary *)dictionary identifier:(NSString *)identifier;



```
#### CLActionManager.m实现代码
```
#import "CLActionManager.h"
#import <objc/message.h>

static void *CLActionBlock = "CLActionBlock";
static void *CLActionMainThread = "CLActionMainThread";
static void *CLActionMethodType = "CLActionMethodType";


@interface CLActionManager ()

/*弱引用字典*/
@property (nonatomic, strong) NSMapTable *mapTable;
/*信号量*/
@property (nonatomic, strong) dispatch_semaphore_t semaphore;


@end

@implementation CLActionManager
//第1步: 存储唯一实例
static CLActionManager *_manager = nil;
//第2步: 分配内存空间时都会调用这个方法. 保证分配内存alloc时都相同.
+(id)allocWithZone:(struct _NSZone *)zone{
    //调用dispatch_once保证在多线程中也只被实例化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}
//第3步: 保证init初始化时都相同
+(instancetype)sharedManager{
    return [[self alloc] init];
}
-(id)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super init];
        //弱引用value，强引用key
        self.mapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
        //信号
        self.semaphore = dispatch_semaphore_create(0);
        dispatch_semaphore_signal(self.semaphore);
    });
    return _manager;
}
//第4步: 保证copy时都相同
-(id)copyWithZone:(NSZone __unused*)zone{
    return _manager;
}
//第五步: 保证mutableCopy时相同
- (id)mutableCopyWithZone:(NSZone __unused*)zone{
    return _manager;
}

+ (void)addObserver:(id)observer actionType:(CLActionType)actionType mainThread:(BOOL)mainThread block:(void(^)(id observer, NSDictionary *dictionary))block {
    //增加信号保证线程安全
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //动态设置block
    objc_setAssociatedObject(observer, CLActionBlock, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //动态设置是否主线程
    objc_setAssociatedObject(observer, CLActionMainThread, [NSNumber numberWithBool:mainThread], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //动态设置方法类型，用于保障监听和调用方式成对，互不干扰
    objc_setAssociatedObject(observer, CLActionMethodType, [NSNumber numberWithBool:1], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //内存地址+key，使用内存地址保证一个对象只监听一次，key保证是同一类型
    NSString *key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], [self keyWithActionType:actionType]];
    //添加到字典
    [[CLActionManager sharedManager].mapTable setObject:observer forKey:key];
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}


+ (void)actionWithDictionary:(NSDictionary *)dictionary actionType:(CLActionType)actionType {
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //key数组
    NSArray<NSString *> *keyArray = [[[CLActionManager sharedManager].mapTable keyEnumerator] allObjects];
    //遍历查找所有key
    [keyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger __unused idx, BOOL * _Nonnull __unused stop) {
        //找出对应类型的观察者
        if ([key containsString:[self keyWithActionType:actionType]]) {
            id observer = [[CLActionManager sharedManager].mapTable objectForKey:key];
            //取出block
            void(^block)(id observer, NSDictionary *dictionary) = objc_getAssociatedObject(observer, CLActionBlock);
            BOOL mainThread = [(NSNumber *)objc_getAssociatedObject(observer, CLActionMainThread) boolValue];
            BOOL actionMethod = [(NSNumber *)objc_getAssociatedObject(observer, CLActionMethodType) isEqualToNumber:@1];
            //block存在并且是对应方法添加，调用block
            if (block && actionMethod) {
                if (mainThread) {
                    //主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(observer, dictionary);
                    });
                }else {
                    //子线程
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        block(observer, dictionary);
                    });
                }
            }
        }
    }];
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}

+ (NSString *)keyWithActionType:(CLActionType)actionType {
    NSString *key;
    switch (actionType) {
        case CLActionTextChange:
            key = @"CLActionTextChange";
            break;
        case CLActionColorChange:
            key = @"CLActionColorChange";
            break;
        case CLActionImageChange:
            key = @"CLActionImageChange";
            break;
    }
    return key;
}


+ (void)addObserver:(id)observer identifier:(NSString *)identifier mainThread:(BOOL)mainThread block:(void(^)(id observer, NSDictionary *dictionary))block {
    //增加信号保证线程安全
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //动态设置属性
    objc_setAssociatedObject(observer, CLActionBlock, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(observer, CLActionMainThread, [NSNumber numberWithBool:mainThread], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(observer, CLActionMethodType, [NSNumber numberWithBool:0], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *key = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%p",observer], identifier];
    //添加到字典
    [[CLActionManager sharedManager].mapTable setObject:observer forKey:key];
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}



+ (void)actionWithDictionary:(NSDictionary *)dictionary identifier:(NSString *)identifier {
    dispatch_semaphore_wait([CLActionManager sharedManager].semaphore, DISPATCH_TIME_FOREVER);
    //key数组
    NSArray<NSString *> *keyArray = [[[CLActionManager sharedManager].mapTable keyEnumerator] allObjects];
    //遍历查找所有key
    [keyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        //找出对应的观察者
        if ([key containsString:identifier]) {
            id observer = [[CLActionManager sharedManager].mapTable objectForKey:key];
            //取出block
            void(^block)(id observer, NSDictionary *dictionary) = objc_getAssociatedObject(observer, CLActionBlock);
            BOOL mainThread = [(NSNumber *)objc_getAssociatedObject(observer, CLActionMainThread) boolValue];
            BOOL actionMethod = [(NSNumber *)objc_getAssociatedObject(observer, CLActionMethodType) isEqualToNumber:@0];
            //调用
            if (block && actionMethod) {
                if (mainThread) {
                    //主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(observer, dictionary);
                    });
                }else {
                    //子线程
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        block(observer, dictionary);
                    });
                }
            }
        }
    }];
    dispatch_semaphore_signal([CLActionManager sharedManager].semaphore);
}
@end
```
# 测试结果
![效果图](https://upload-images.jianshu.io/upload_images/1979970-dbde3cfe739c248e.gif?imageMogr2/auto-orient/strip)
测试效果已经达到我们需要的效果，看一下打印结果，所有的观察者的生命周期都没有受到影响
```
AViewController收到颜色变化,当前线程<NSThread: 0x608000263000>{number = 1, name = main}
BViewController收到颜色变化，当前线程<NSThread: 0x608000263000>{number = 1, name = main}
ViewController收到颜色变化,当前线程<NSThread: 0x608000263000>{number = 1, name = main}
收到其他地方头像变化了,当前线程--<NSThread: 0x608000263000>{number = 1, name = main}
收到其他地方头像变化了,当前线程--<NSThread: 0x608000263000>{number = 1, name = main}
++++++++++>>>>BViewController销毁了
头像View销毁了----0x7fbee1d08fb0
--------->>>>AViewController销毁了
头像View销毁了----0x7fbee1e1a3b0
```
# 总结
以上是根据通知原理来自己实现的自定义响应类，希望能够给大家帮助，demo地址--->>[CLActionManager](https://github.com/JmoVxia/CLActionManager)



