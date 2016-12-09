//
//  ViewController.m
//  CaptureScrawl
//
//  Created by Kitty on 16/12/6.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "ViewController.h"
#import "Cutter.h"
#import "ShowImageViewController.h"

@interface ViewController () <UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"截屏涂鸦";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
}


#pragma mark - 初始化视图
- (void)initView
{
    // 截屏按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 60, 44);
    [button setTitle:@"截屏" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = btnItem;
    
    // WebView
    // https://www.baidu.com
    // http://property.brc.com.cn:8084/house-web/#/access/signin
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [self.webView loadRequest:request];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleGes)];
    [tap setNumberOfTapsRequired:2];
    tap.delegate = self;
    [self.webView.scrollView addGestureRecognizer:tap];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (touch.tapCount == 2) {
       
        ShowImageViewController *vc = [[ShowImageViewController alloc] init];
        vc.image = [self.webView viewCutter];
        vc.navigationController.navigationBarHidden = YES;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        vc.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:vc animated:YES completion:nil];
    }
    return YES; // Return NO to prevent html document from receiving the touch event.
}

#pragma mark - 导航按钮
- (void)rightButton:(UIButton *)sender
{
    ShowImageViewController *vc = [[ShowImageViewController alloc] init];
    vc.image = [self.webView viewCutter];
    vc.navigationController.navigationBarHidden = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)doubleGes
{
    ShowImageViewController *vc = [[ShowImageViewController alloc] init];
    vc.image = [self.webView viewCutter];
    vc.navigationController.navigationBarHidden = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
