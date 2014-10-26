//
//  UIView+DashedBorder.m
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import "UIView+DashedBorder.h"

@implementation UIView (DashedBorder)

#pragma mark - API

- (void)addDashedBorderWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius borderWith:(CGFloat)borderWith
{
    if (!color) {
        color = [self tintColor];
    }
    
    CAShapeLayer *dashedBorderLayer = [self dashedBorderWithColor:[color CGColor] cornerRadius:cornerRadius borderWith:borderWith];
    [self.layer addSublayer:dashedBorderLayer];
}

- (void)removeDashedBorder
{
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.name isEqualToString:idDashedBorder]) {
            [layer removeFromSuperlayer];
        }
    }
}


#pragma mark - Helpers

- (CAShapeLayer *)dashedBorderWithColor:(CGColorRef)color cornerRadius:(CGFloat)cornerRadius borderWith:(CGFloat)borderWith
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.name = idDashedBorder;
    
    CGSize frameSize = self.bounds.size;
    
    CGRect shapeRect = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    [shapeLayer setBounds:shapeRect];
    [shapeLayer setPosition:CGPointMake( frameSize.width/2,frameSize.height/2)];
    
    [shapeLayer setCornerRadius:cornerRadius];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:color];
    [shapeLayer setLineWidth:borderWith];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5],
      nil]];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shapeRect cornerRadius:15.0];
    [shapeLayer setPath:path.CGPath];
    
    return shapeLayer;
}

@end
