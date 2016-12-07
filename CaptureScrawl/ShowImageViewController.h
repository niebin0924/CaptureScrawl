//
//  ShowImageViewController.h
//  ScreenShotTest
//
//  Created by 张雷 on 14/10/26.
//  Copyright (c) 2014年 zhanglei. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, DrawRectType) {
    DrawRectTypeLine,
    DrawRectTypeRadio,
    DrawRectTypeCub,
    DrawRectTypeText
};

typedef NS_ENUM(NSUInteger, DrawViewType) {
    DrawViewTypeRawImage,
    DrawViewTypeDrawImage,
    DrawViewTypeMiddleImage
};

struct DrawPath {
    CGRect rect;
    NSUInteger type;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
};

typedef struct DrawPath DrawPath;

#define DrawViewTagStart 100


@interface ShowImageViewController : UIViewController

@property (nonatomic,retain) UIImage *image;

@end
