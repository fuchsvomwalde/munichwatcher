//
//  CamerasOnRouteDetector.h
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CamerasOnRouteDetector : NSObject

+ (NSArray *)findCamerasInArray:(NSArray *)cameras onRouteWithSteps:(NSArray *)steps;


@end
