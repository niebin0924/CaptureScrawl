//
//  ShowImageViewController.m
//  ScreenShotTest
//
//  Created by 张雷 on 14/10/26.
//  Copyright (c) 2014年 zhanglei. All rights reserved.
//

#import "ShowImageViewController.h"

static NSUInteger viewTagValue = DrawViewTagStart;

@interface ShowImageViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *selectedImage;
@property (nonatomic, assign) CGPoint previousPoint;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) CGPoint movePoint;
@property (nonatomic, strong) UIImageView *drawView;
@property (nonatomic, assign) DrawRectType rectType;
@property (nonatomic, assign) UIColor *color;
@property (nonatomic, strong) NSDictionary *colors;
@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIImageView *oneTimeView;

@end

@implementation ShowImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.colors = @{@"红色":[UIColor redColor],@"黄色":[UIColor yellowColor],@"蓝色":[UIColor blueColor],@"绿色":[UIColor greenColor],@"青色":[UIColor grayColor],@"紫色":[UIColor purpleColor],@"橙色":[UIColor orangeColor],@"黑色":[UIColor blackColor],@"白色":[UIColor whiteColor]};
    self.paths = [[NSMutableArray alloc] init];
    self.text = @"";
    
    [self initView];
}

#pragma mark - 初始化视图
-(void)initView
{
    //定宽算高，最宽为父视图的宽，按比例算高
    CGFloat width = self.image.size.width > self.view.frame.size.width ? self.view.frame.size.width : self.image.size.width;
    CGFloat height = self.image.size.height * width / self.image.size.width;
    
    self.selectedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 65,  width, height-65)];
    self.selectedImage.image = self.image;
    self.selectedImage.center = self.view.center;
//    [self.view addSubview:self.selectedImage];
    
    //遮罩层
    self.drawView = [[UIImageView alloc] initWithFrame:self.selectedImage.frame];
    self.drawView.backgroundColor = [UIColor grayColor];
    self.drawView.image = _image;
    self.drawView.layer.masksToBounds = YES;
    self.drawView.layer.cornerRadius = 8;
    self.drawView.userInteractionEnabled = YES;
    [self.view addSubview:self.drawView];
    
    //直线、蓝色
    self.rectType = DrawRectTypeRadio;
    self.color = self.colors[[self.colors allKeys][0]];
    
    //UIButton
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveBtn setTitle:@"保存图片到相册" forState:UIControlStateNormal];
    saveBtn.frame = CGRectMake(20, self.view.bounds.size.height-50, (self.view.bounds.size.width - 40)/2.0-10, 35);
    saveBtn.backgroundColor = [UIColor grayColor];
    saveBtn.layer.cornerRadius = 5;
    saveBtn.alpha = 0.8;
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(self.view.bounds.size.width / 2.0+10, self.view.bounds.size.height-50, (self.view.bounds.size.width - 40)/2.0-10, 35);
    [cancelBtn addTarget:self action:@selector(cancelBtn) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.backgroundColor = [UIColor grayColor];
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.alpha = 0.8;
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:cancelBtn];
    
    //形状
    UIButton *upBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 25, (self.view.frame.size.width-5*5)/4, 35)];
    [upBtn setBackgroundColor:[UIColor grayColor]];
    [upBtn setTitle:@"椭圆" forState:UIControlStateNormal];
    [upBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    upBtn.layer.cornerRadius = 5;
    upBtn.alpha = 0.8;
    [upBtn addTarget:self action:@selector(shap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:upBtn];
    
    
    //撤销
    UIButton *rollbackBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(upBtn.frame)+5, CGRectGetMinY(upBtn.frame), (self.view.frame.size.width-5*5)/4, 35)];
    [rollbackBtn setBackgroundColor:[UIColor grayColor]];
    [rollbackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rollbackBtn setTitle:@"撤销" forState:UIControlStateNormal];
    rollbackBtn.layer.cornerRadius = 5;
    rollbackBtn.alpha = 0.8;
    [rollbackBtn addTarget:self action:@selector(rollback) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rollbackBtn];
    
    // 重置
    UIButton *resetBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(rollbackBtn.frame)+5, CGRectGetMinY(upBtn.frame), (self.view.frame.size.width-5*5)/4, 35)];
    [resetBtn setBackgroundColor:[UIColor grayColor]];
    [resetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [resetBtn setTitle:@"重置" forState:UIControlStateNormal];
    resetBtn.layer.cornerRadius = 5;
    resetBtn.alpha = 0.8;
    [resetBtn addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetBtn];
    
    //颜色
    UIButton *downBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(resetBtn.frame)+5, CGRectGetMinY(upBtn.frame), (self.view.frame.size.width-5*5)/4, 35)];
    [downBtn setBackgroundColor:[UIColor grayColor]];
    [downBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [downBtn setTitle:[self.colors allKeys][0] forState:UIControlStateNormal];
    downBtn.layer.cornerRadius = 5;
    downBtn.alpha = 0.8;
    [downBtn addTarget:self action:@selector(colorChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downBtn];

    
    self.oneTimeView = [[UIImageView alloc] init];
    self.oneTimeView.userInteractionEnabled = NO;
    [self.drawView addSubview:self.oneTimeView];
    
}

#pragma mark - 添加文字
- (void)addText:(UIButton *)btn {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入文字"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"填写文字";
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UITextField *textField = [alert.textFields objectAtIndex:0];
        if (![textField.text isEqualToString:@""]) {
            self.text = textField.text;
        }
        self.rectType = DrawRectTypeText;
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 保存图片到相册
-(void)saveBtn
{
    /*
    //1 保存照片到沙盒目录
    NSData *imageData = UIImagePNGRepresentation(_image);
    
    //创建文件夹  createIntermediates该参数bool类型,是否创建文件夹路径中没有的文件夹目录
    NSString *documentsDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"ScreenShot"];
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSInteger seconds = [[NSDate date] timeIntervalSince1970];
    NSString *pictureName= [NSString stringWithFormat:@"%ld.png",(long)seconds];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:pictureName];
    [imageData writeToFile:savedImagePath atomically:YES];
    */
    //2 保存图片到照片库
    UIImageWriteToSavedPhotosAlbum(_image, nil, nil, nil);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 取消
-(void)cancelBtn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 撤销
- (void)rollback {
    if (viewTagValue > DrawViewTagStart) {
        UIImageView *imageView = [self.drawView viewWithTag:viewTagValue-- - 1];
        [imageView removeFromSuperview];
        [self.paths removeObjectAtIndex:self.paths.count - 1];
    }
}

#pragma mark - 重置
- (void)reset
{
    if (viewTagValue > DrawViewTagStart) {
        for (NSInteger i=viewTagValue; i>=DrawViewTagStart; i--) {
            UIImageView *imageView = [self.drawView viewWithTag:i - 1];
            [imageView removeFromSuperview];
        }
        
        [self.paths removeAllObjects];
    }
}

#pragma mark - 形状
- (void)shap:(UIButton *)btn {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择图形" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *camaraAction = [UIAlertAction actionWithTitle:@"椭圆" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.rectType = DrawRectTypeRadio;
        [btn setTitle:@"椭圆" forState:UIControlStateNormal];
    }];
    
    UIAlertAction *lineAction = [UIAlertAction actionWithTitle:@"直线（暂未实现）" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.rectType = DrawRectTypeLine;
        [btn setTitle:@"直线" forState:UIControlStateNormal];
    }];
    
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"矩形" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.rectType = DrawRectTypeCub;
        [btn setTitle:@"矩形" forState:UIControlStateNormal];
    }];
    
    UIAlertAction *textAction = [UIAlertAction actionWithTitle:@"文字" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.rectType = DrawRectTypeText;
        [btn setTitle:@"文字" forState:UIControlStateNormal];
        [self addText:btn];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
    [alert addAction:camaraAction];
    [alert addAction:lineAction];
    [alert addAction:libraryAction];
    [alert addAction:textAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 颜色改变
- (void)colorChange:(UIButton *)btn {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择颜色" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *array = [self.colors allKeys];
    for (int i = 0; i < array.count; i++) {
        NSString *key = array[i];
        UIAlertAction *action = [UIAlertAction actionWithTitle:key style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            self.color = self.colors[key];
            [btn setTitle:array[i] forState:UIControlStateNormal];
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - 触摸事件

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches != nil && touches.count > 0) {
        NSArray *array = [touches allObjects];
        UITouch *touch = array[0];
        UIImageView *imageView = (UIImageView *)touch.view;
        if (imageView == self.drawView) {
            self.startPoint = [touch locationInView:imageView];
        }
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches != nil && touches.count > 0) {
        NSArray *array = [touches allObjects];
        UITouch *touch = array[0];
        UIImageView *imageView = (UIImageView *)touch.view;
        if (imageView == self.drawView) {
            self.movePoint = [touch locationInView:imageView];
            
            self.previousPoint = [touch previousLocationInView:imageView];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (self.rectType == DrawRectTypeLine) {
                        [self drawLineWay:DrawViewTypeDrawImage rectType:_rectType color:_color fromPoint:self.previousPoint toPoint:self.movePoint];
                    }else{
//                        [self drawNewWay:DrawViewTypeDrawImage rectType:_rectType color:_color];
                        [self drawRawView];
                    }
                });
                
            });
            
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches != nil && touches.count > 0) {
        NSArray *array = [touches allObjects];
        UITouch *touch = array[0];
        UIImageView *imageView = (UIImageView *)touch.view;
        if (imageView == self.drawView) {
            self.endPoint = [touch locationInView:imageView];
            if (!CGPointEqualToPoint(self.previousPoint, CGPointZero))
            {
                self.previousPoint = [touch previousLocationInView:imageView];
                
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (self.rectType == DrawRectTypeLine) {
                        [self drawLineWay:DrawViewTypeDrawImage rectType:_rectType color:_color fromPoint:self.previousPoint toPoint:self.endPoint];
                    }else{
//                        [self drawNewWay:DrawViewTypeMiddleImage rectType:_rectType color:_color];
                        [self drawRawView];
                    }
                });
                
            });
        }
    }
}

#pragma mark - 绘图方法

- (void)drawRawView {
    UIImageView *imageView = _selectedImage;
    BOOL opaque = NO;
    CGSize size = self.image.size;
    CGRect rect = CGRectZero;
    
    //开始绘制
    UIGraphicsBeginImageContextWithOptions(size, opaque, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //将图片根据原始大小绘制到上下文
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height)];
    NSArray *array = [self.paths copy];
    for (int i = 0; i < array.count; i++) {
        DrawPath path;
        [array[i] getValue:&path];
        rect = path.rect;
        DrawRectType rectType = path.type;
        UIColor *color = [UIColor colorWithRed:path.red green:path.green blue:path.blue alpha:path.alpha];
        
        //线条宽度转换，因为两个画布的大小不一样，按比例计算
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineWidth(context, 2.5 * fabs(imageView.image.size.width / _drawView.frame.size.width));
        
        //转换遮罩层上的大小，对应背景层的大小
        rect.origin.x = rect.origin.x / _drawView.frame.size.width * imageView.image.size.width;
        rect.origin.y = rect.origin.y / _drawView.frame.size.height * imageView.image.size.height;
        rect.size.width = rect.size.width / _drawView.frame.size.width * imageView.image.size.width;
        rect.size.height = rect.size.height / _drawView.frame.size.height * imageView.image.size.height;
        
        [self drawShapWith:rectType context:context rect:rect adjustFont:YES color:color];
        
        //渲染
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
}

#pragma mark - 绘制文字
- (void)drawTextInRect:(CGRect)rect color:(UIColor *)color adjustFont:(BOOL)adjust {
    
    /*写文字*/
    
    UIFont  *font = [UIFont boldSystemFontOfSize:adjust ? 16.0 * _selectedImage.image.size.width / self.view.frame.size.width:16];//定义默认字体
    
    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;//文字居中：发现只能水平居中，而无法垂直居中
    NSDictionary* attribute = @{
                                NSForegroundColorAttributeName:color,//设置文字颜色
                                NSFontAttributeName:font,//设置文字的字体
                                NSKernAttributeName:@0,//文字之间的字距
                                NSParagraphStyleAttributeName:paragraphStyle,//设置文字的样式
                                };
    
    //计算文字的宽度和高度：支持多行显示
    CGSize sizeText = [_text boundingRectWithSize:rect.size
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{
                                                    NSFontAttributeName:font,//设置文字的字体
                                                    NSKernAttributeName:@0,//文字之间的字距
                                                    }
                                          context:nil].size;
    
    //为了能够垂直居中，需要计算显示起点坐标x,y
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y, sizeText.width, sizeText.height);
    [_text drawInRect:newRect withAttributes:attribute];
}

#pragma mark - 绘制形状
- (void)drawShapWith:(DrawRectType)type context:(CGContextRef)context rect:(CGRect)rect adjustFont:(BOOL)adjust color:(UIColor *)color{
    switch (type) {
        case DrawRectTypeRadio:
            CGContextAddEllipseInRect(context, rect); //椭圆
            break;
        case DrawRectTypeCub:
            CGContextAddRect(context, rect); //矩形
            break;
        case DrawRectTypeText:
            [self drawTextInRect:rect color:color adjustFont:adjust]; // 文字
            break;
        default:
            break;
    }
}

#pragma mark - 绘制直线、手写
- (void)drawLineWay:(DrawViewType)viewType rectType:(DrawRectType)rectType color:(UIColor *)color fromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    CGPoint finishedPoint;
    UIImageView *tmpView;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    long bitmapByteCount;
    long bitmapBytesPerRow;
    
    //获取遮罩层画布大小、移动位置
    switch (viewType) {
        case DrawViewTypeDrawImage:
            finishedPoint = _movePoint;
            tmpView = _oneTimeView;
            break;
        case DrawViewTypeMiddleImage:
            finishedPoint = _endPoint;
            _oneTimeView.image = nil;
            tmpView = [[UIImageView alloc] init];
            [self.drawView insertSubview:tmpView belowSubview:_oneTimeView];
            break;
        default:
            break;
    }
    
    CGRect rect = CGRectZero;
    
    //根据手指位移计算图形大小
    rect.origin = CGPointMake(finishedPoint.x > _startPoint.x ? _startPoint.x:finishedPoint.x, finishedPoint.y > _startPoint.y ? _startPoint.y:finishedPoint.y);
    rect.size = CGSizeMake(fabs(finishedPoint.x - _startPoint.x), fabs(finishedPoint.y - _startPoint.y));
    
    tmpView.frame = rect;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    size_t imageWidth = CGImageGetWidth(self.drawView.image.CGImage);
    size_t imageHeight = CGImageGetHeight(self.drawView.image.CGImage);
    
    bitmapBytesPerRow = (imageWidth * 4);
    bitmapByteCount = (bitmapBytesPerRow * imageHeight);
    CFMutableDataRef pixels = CFDataCreateMutable(NULL, imageWidth * imageHeight);
//    CGContextRef context = CGBitmapContextCreate(CFDataGetMutableBytePtr(pixels), imageWidth, imageHeight , 8, imageWidth, colorspace, kCGImageAlphaNone);
//    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //绘图上下文获取失败则跳转
    if (context == 0x0) {
        goto finished;
    }
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 2.5);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    //开始绘制
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, startPoint.x, self.drawView.frame.size.height-startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, self.drawView.frame.size.height - endPoint.y);
    CGContextStrokePath(context);
    
    tmpView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    //手指绘图结束则纪录该绘图信息
    if (DrawViewTypeMiddleImage == viewType) {
        DrawPath path;
        path.rect = rect;
        path.type = rectType;
        [color getRed:&path.red green:&path.green blue:&path.blue alpha:&path.alpha];
        [self.paths addObject:[NSValue valueWithBytes:&path objCType:@encode(DrawPath)]];
        tmpView.tag = viewTagValue++;
    }
    
finished:
    UIGraphicsEndImageContext();
}

#pragma mark - 测试新绘图方法
- (void)drawNewWay:(DrawViewType)viewType rectType:(DrawRectType)rectType color:(UIColor *)color {
    CGPoint finishedPoint;
    UIImageView *tmpView;
    
    //获取遮罩层画布大小、移动位置
    switch (viewType) {
        case DrawViewTypeDrawImage:
            finishedPoint = _movePoint;
            tmpView = _oneTimeView;
            break;
        case DrawViewTypeMiddleImage:
            finishedPoint = _endPoint;
            _oneTimeView.image = nil;
            tmpView = [[UIImageView alloc] init];
            [self.drawView insertSubview:tmpView belowSubview:_oneTimeView];
            break;
        default:
            break;
    }
    
    CGRect rect = CGRectZero;
    
    //根据手指位移计算图形大小
    rect.origin = CGPointMake(finishedPoint.x > _startPoint.x ? _startPoint.x:finishedPoint.x, finishedPoint.y > _startPoint.y ? _startPoint.y:finishedPoint.y);
    rect.size = CGSizeMake(fabs(finishedPoint.x - _startPoint.x), fabs(finishedPoint.y - _startPoint.y));
    
    tmpView.frame = rect;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //绘图上下文获取失败则跳转
    if (context == 0x0) {
        goto finished;
    }
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 2.5);
    
    [self drawShapWith:rectType context:context rect:CGRectMake(2.5, 2.5, rect.size.width - 5, rect.size.height - 5) adjustFont:NO color:_color];
    
   
    //渲染
    CGContextDrawPath(context, kCGPathStroke);
    
    tmpView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    //手指绘图结束则纪录该绘图信息
    if (DrawViewTypeMiddleImage == viewType) {
        DrawPath path;
        path.rect = rect;
        path.type = rectType;
        [color getRed:&path.red green:&path.green blue:&path.blue alpha:&path.alpha];
        [self.paths addObject:[NSValue valueWithBytes:&path objCType:@encode(DrawPath)]];
        tmpView.tag = viewTagValue++;
    }
    
finished:
    UIGraphicsEndImageContext();
}


@end
