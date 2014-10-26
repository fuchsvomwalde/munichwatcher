//
//  CamerasOnRouteDetector.m
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import "CamerasOnRouteDetector.h"
#import "Camera.h"
#import "NSString+Util.h"

#define forbidden @[@"der", @"die", @"das", @"in", @"links", @"rechts", @"halten", @"nehmen", @"um", @"nach", @"auf", @"zu", @"straße", @"platz", @"weg", @"alter"]

#define THRESHOLD 0.0075

@implementation CamerasOnRouteDetector

+ (NSArray *)findCamerasInArray:(NSArray *)cameras onRouteWithSteps:(NSArray *)steps
{
    NSMutableArray *camerasOnRoute = [[NSMutableArray alloc] init];
    for (Camera *camera in cameras) {
        if ([CamerasOnRouteDetector camera:camera liesOnStepUsingStringSearchInSteps:steps]) {
            [camerasOnRoute addObject:camera];
        }
        else if ([CamerasOnRouteDetector camera:camera liesOnStepUsingCoordinatesInSteps:steps]) {
            [camerasOnRoute addObject:camera];
        }
    }
    
    return [[NSMutableArray alloc] initWithArray:camerasOnRoute];
}

+ (BOOL)camera:(Camera *)camera liesOnStepUsingStringSearchInSteps:(NSArray *)steps
{
    for (NSDictionary *stepInfo in steps) {
        NSString *htmlInstructions = stepInfo[@"html_instructions"];
        NSString *instructionsWithoutHTML = [htmlInstructions stringByStrippingHTML];
        NSArray *instructionParts = [instructionsWithoutHTML componentsSeparatedByString:@" "];
        for (NSString *component in instructionParts) {
            NSArray *forbiddenWords = forbidden;
            if (![forbiddenWords containsObject:[component lowercaseString]]) {
                if ([camera.address containsString:component caseSensitive:NO]) {
                    
                    NSLog(@"Found camera: %@ --> %@ (%@)", camera.address, instructionsWithoutHTML, component);
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

+ (BOOL)camera:(Camera *)camera liesOnStepUsingCoordinatesInSteps:(NSArray *)steps
{
    for (NSDictionary *stepInfo in steps) {
        NSDictionary *startLocationInfo = stepInfo[@"start_location"];
        NSDictionary *endLocationInfo = stepInfo[@"end_location"];
        
        double startLocationLatitude = [startLocationInfo[@"lat"] doubleValue];
        double startLocationLongitude = [startLocationInfo[@"lng"] doubleValue];
        
        if ([CamerasOnRouteDetector camera:camera liesCloseToCoordinatesWithLatitude:startLocationLatitude longitude:startLocationLongitude]) {
            NSLog(@"Camera (%f/%f) lies close to step's START: %@", startLocationLatitude, startLocationLongitude, startLocationInfo);
            return YES;
        }
        
        double endLocationLatitude = [endLocationInfo[@"lat"] doubleValue];
        double endLocationLongitude = [endLocationInfo[@"lng"] doubleValue];
        
        if ([CamerasOnRouteDetector camera:camera liesCloseToCoordinatesWithLatitude:endLocationLatitude longitude:endLocationLongitude]) {
            NSLog(@"Camera (%f/%f) lies close to step's END: %@", endLocationLatitude, endLocationLongitude, endLocationInfo);
            return YES;
        }
        
        return NO;
        
        
}
    
    return NO;
}

+ (BOOL)camera:(Camera *)camera liesCloseToCoordinatesWithLatitude:(double)latitude longitude:(double)longitude
{
    if( (latitude - THRESHOLD < camera.latitude && camera.latitude < latitude + THRESHOLD) && (longitude - THRESHOLD < camera.longitude && camera.longitude < longitude + THRESHOLD) ){
        return YES;
    }
    else{
        return NO;
    }
}

//- (BOOL)camera:(Camera *)camera liesOnStepInSteps:(NSArray *)steps
//{
//    for (NSDictionary *stepInfo in steps) {
//        
//    }
//    
//    return YES;
//}

@end
