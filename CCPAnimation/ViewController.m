//
//  ViewController.m
//  CCPAnimation
//
//  Created by liqunfei on 16/3/9.
//  Copyright © 2016年 chuchengpeng. All rights reserved.
//

#import "ViewController.h"
#define CRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a].CGColor
#import "SummyView.h"
@interface ViewController ()
{
    NSMutableArray *arr;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createModel];
}

- (void)createModel {
    arr = [NSMutableArray array];
    for (int i = 0; i < 2;i++) {
        CALayer *layer = [CALayer layer];
        layer.position = CGPointMake(self.view.center.x, 40+50*i);
        layer.bounds = CGRectMake(0, 0, 100.0, 40.0);
        layer.backgroundColor = CRGBA(80, (80.0+i*20.0),(100.0+i*30), 1.0);
        [self.view.layer addSublayer:layer];
        [arr addObject:layer];
    }
}


- (IBAction)buttonAction:(UIButton *)sender {
    switch (sender.tag - 101) {
        case 0:
            [self pathShakeAnimationWithLayer:arr[0]];
            break;
        case 1:
            [self shakeAnimationWithLayer:arr[1]];
            break;
        case 2:
        {
            SummyView *sView = [[SummyView alloc] initWithFrame:CGRectMake(self.view.center.x, self.view.center.y, 50.0, 50.0)];
                sView.backgroundColor = [UIColor redColor];
                [self.view addSubview:sView];
        }
            break;
        default:
            break;
    }
}
#pragma mark -- shake震动效果

- (void)pathShakeAnimationWithLayer:(CALayer *)layer {
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, layer.position.x, layer.position.y);
    for (int i = 0; i < 3; i++) {
        CGPathAddLineToPoint(path, NULL, CGRectGetMidX(layer.frame) - 3.0, layer.position.y);
        CGPathAddLineToPoint(path, NULL, CGRectGetMidX(layer.frame) + 3.0, layer.position.y);
    }
    CGPathCloseSubpath(path);
    keyAnimation.path = path;
    keyAnimation.duration = 0.5;
    CFRelease(path);
    [layer addAnimation:keyAnimation forKey:kCATransition];
}

- (void)shakeAnimationWithLayer:(CALayer *)layer {
    CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    CGPoint beginPoint = CGPointMake(layer.position.x - 3.0, layer.position.y - 3.0);
    CGPoint endPoint = CGPointMake(layer.position.x + 3.0, layer.position.y + 3.0);
    [baseAnimation setFromValue:[NSValue valueWithCGPoint:beginPoint]];
    [baseAnimation setToValue:[NSValue valueWithCGPoint:endPoint]];
    [baseAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    baseAnimation.duration = 0.3;
    baseAnimation.autoreverses = YES;
    baseAnimation.repeatCount = 3.0;
    [layer addAnimation:baseAnimation forKey:kCATransition];
}

@end
