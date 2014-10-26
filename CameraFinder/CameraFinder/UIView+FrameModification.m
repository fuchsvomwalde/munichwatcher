//
//  UIView+FrameModification.m
//  TrafficAlarm
//
//  Created by Nikolas Burk on 08/03/14.
//  Copyright (c) 2014 Nikolas Burk. All rights reserved.
//

#import "UIView+FrameModification.h"

@implementation UIView (FrameModification)


#pragma mark - Move view

- (void)moveLeftWithDistance:(CGFloat)distance
{
    CGRect newFrame = CGRectMake(self.frame.origin.x - distance, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    self.frame = newFrame;
}

- (void)moveRightWithDistance:(CGFloat)distance
{
    CGRect newFrame = CGRectMake(self.frame.origin.x + distance, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    self.frame = newFrame;
}

- (void)moveDownWithDistance:(CGFloat)distance
{
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y + distance, self.frame.size.width, self.frame.size.height);
    self.frame = newFrame;
}

- (void)moveUpWithDistance:(CGFloat)distance
{
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - distance, self.frame.size.width, self.frame.size.height);
    self.frame = newFrame;
}


#pragma mark - Modify frame rectangle

- (void)setX:(CGFloat)x
{
    CGRect newFrame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    self.frame = newFrame;
}

- (void)setY:(CGFloat)y
{
    CGRect newFrame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
    self.frame = newFrame;
}

- (void)setWidth:(CGFloat)width
{
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
    self.frame = newFrame;
}

- (void)setHeight:(CGFloat)height
{
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    self.frame = newFrame;
}


#pragma mark - Modify view's size

- (void)enlargeViewWithXDelta:(CGFloat)xDelta
{
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + xDelta, self.frame.size.height);
    self.frame = newFrame;
}

- (void)enlargeViewWithYDelta:(CGFloat)yDelta
{
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + yDelta);
    self.frame = newFrame;
}

@end
