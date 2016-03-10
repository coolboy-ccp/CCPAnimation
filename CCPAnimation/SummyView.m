//
//  SummyView.m
//  CCPAnimation
//
//  Created by liqunfei on 16/3/9.
//  Copyright © 2016年 chuchengpeng. All rights reserved.
//

#import "SummyView.h"

#define VIEW_W self.bounds.size.width

@interface SummyView()
{
   CGFloat smallViewR;
}
@property (nonatomic,strong)CAShapeLayer *shapeLayer;
@property (nonatomic,strong) UIView *smallView;
@end

@implementation SummyView


- (void)layoutSubviews {
    [self buildUI];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}


- (void)buildUI {
    self.layer.cornerRadius = VIEW_W * 0.5;
    smallViewR = VIEW_W * 0.5;
    self.smallView.layer.cornerRadius = self.smallView.frame.size.width * 0.5;
}

- (UIView *)smallView {
    if (!_smallView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W, VIEW_W)];
        view.center = self.center;
        view.backgroundColor = self.backgroundColor;
        [self.superview insertSubview:view atIndex:0];
        _smallView = view;
    }
    return _smallView;
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.path = [self createBezierPathWithSmallView:self.smallView andBigView:self].CGPath;
        _shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:_shapeLayer atIndex:0];
    }
    return _shapeLayer;
}

- (CGFloat)distanceWithPA:(CGPoint)a PB:(CGPoint)b {
    CGFloat x = b.x - a.x;
    CGFloat y = b.y - a.y;
    return sqrt(x * x + y * y);
}

- (UIBezierPath *)createBezierPathWithSmallView:(UIView *)smallV andBigView:(UIView *)bigV {
    CGPoint smallcenter = smallV.center;
    CGFloat sx = smallcenter.x;
    CGFloat sy = smallcenter.y;
    CGFloat sr = self.smallView.bounds.size.width * 0.5;
    CGPoint bigCenter = bigV.center;
    CGFloat bx = bigCenter.x;
    CGFloat by = bigCenter.y;
    CGFloat br = VIEW_W * 0.5;
    CGFloat d = [self distanceWithPA:bigCenter PB:smallcenter];
    CGFloat sinθ = (bx - sx) / d;
    CGFloat cosθ = (by - sy) / d;
    CGPoint pA = CGPointMake(sx - sr * cosθ, sy + sr * sinθ);
    CGPoint pB = CGPointMake(sx + sr * cosθ, sy - sr * sinθ);
    CGPoint pC = CGPointMake(bx + br * cosθ, by - br * sinθ);
    CGPoint pD = CGPointMake(bx - br * cosθ, by + br * sinθ);
    CGPoint pO = CGPointMake(pA.x + d / 2 * sinθ, pA.y + d / 2 * cosθ);
    CGPoint pP = CGPointMake(pB.x + d / 2 * sinθ, pB.y + d / 2 * cosθ);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pD];
    [path addQuadCurveToPoint:pA controlPoint:pO];
    [path addLineToPoint:pB];
    [path addQuadCurveToPoint:pC controlPoint:pP];
    [path addLineToPoint:pD];
    return path;
}


static const float maxDistance = 100.0;
- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.superview];
    CGPoint center = self.center;
    center.x += point.x;
    center.y += point.y;
    self.center = center;
    [pan setTranslation:CGPointZero inView:self];
    CGFloat distance = [self distanceWithPA:self.smallView.center PB:self.center];
    if (distance == 0) {
        return;
    }
    CGFloat nr = smallViewR - distance / 15.0;
    self.smallView.bounds = CGRectMake(0, 0, nr * 2, nr * 2);
    self.smallView.layer.cornerRadius = nr;
    if (distance > maxDistance || nr <= 0) {
        self.smallView.hidden = YES;
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
    }
    if (distance <= maxDistance && self.smallView.hidden == NO) {
        self.shapeLayer.path = [self createBezierPathWithSmallView:self.smallView andBigView:self].CGPath;
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (distance <= maxDistance) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.shapeLayer removeFromSuperlayer];
                self.shapeLayer = nil;
            });
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.center = self.smallView.center;
            } completion:^(BOOL finished) {
                self.smallView.hidden = NO;
            }];
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });
        }
      
    }
}
@end
