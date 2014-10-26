//
//  UIView+DashedBorder.h
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import <UIKit/UIKit.h>

#define idDashedBorder @"idDashedBorder"

@interface UIView (DashedBorder)

- (void)addDashedBorderWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius borderWith:(CGFloat)borderWith;
- (void)removeDashedBorder;

@end
