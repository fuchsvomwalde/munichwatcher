//
//  UIView+FrameModification.h
//  TrafficAlarm
//
//  Created by Nikolas Burk on 08/03/14.
//  Copyright (c) 2014 Nikolas Burk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FrameModification)

// Move view
- (void)moveLeftWithDistance:(CGFloat)distance;
- (void)moveRightWithDistance:(CGFloat)distance;
- (void)moveDownWithDistance:(CGFloat)distance;
- (void)moveUpWithDistance:(CGFloat)distance;

// Modify frame rectangle
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;

// Modify the view's size
- (void)enlargeViewWithXDelta:(CGFloat)xDelta;
- (void)enlargeViewWithYDelta:(CGFloat)yDelta;



@end
