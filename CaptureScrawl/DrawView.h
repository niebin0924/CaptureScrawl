//
//  DrawView.h
//  CaptureScrawl
//
//  Created by Kitty on 16/12/9.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawView : UIImageView

@property (nonatomic,strong) UIColor *lineColor;
@property (nonatomic,assign) CGFloat lineWidth;
@property (nonatomic,strong) NSMutableArray *points;

- (void)drawLine:(NSMutableArray *)points color:(UIColor *)lineColor;

@end
