//
//  DrawView.m
//  CaptureScrawl
//
//  Created by Kitty on 16/12/9.
//  Copyright © 2016年 Kitty. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView

- (void)drawLine:(NSMutableArray *)points color:(UIColor *)lineColor
{
    self.lineWidth = 2.5;
    self.lineColor = lineColor;
    self.points = [[NSMutableArray alloc] initWithArray:points];
    
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef cref = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(cref, self.lineColor.CGColor);
    CGContextSetLineWidth(cref, self.lineWidth);
    //设置为圆头
    CGContextSetLineCap(cref, kCGLineCapRound);
    
    CGPoint pt = [[self.points objectAtIndex:0] CGPointValue];
    CGContextBeginPath(cref);
    CGContextMoveToPoint(cref, pt.x, pt.y);
    CGPoint lpt = pt;
    
    for (int i=1; i<self.points.count; i++) {
        
        pt = [[self.points objectAtIndex:i] CGPointValue];
        CGContextAddQuadCurveToPoint(cref, lpt.x, lpt.y, (pt.x + lpt.x)/2, (pt.y + lpt.y)/2);
        lpt = pt;
    }
    
    CGContextAddLineToPoint(cref, pt.x, pt.y);
    CGContextStrokePath(cref);
    
}

@end
