//
//  GMSDirectionService.h
//  TrafficAlarm
//
//  Created by Nikolas Burk on 23/04/14.
//  Copyright (c) 2014 Nikolas Burk. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "HTTPRequest.h"

#define kDistanceInfo @"kDistanceInfo"
#define kDurationInfo @"kDurationInfo"
#define kOverviewPolyline @"kOverviewPolyline"
#define kSteps @"kSteps"
#define kCoordinateBounds @"kCoordinateBounds"

#define DIRECTIONS_LANGUAGE @"de"

@class GMSDirectionService;

@protocol GMSDirectionServiceDelegate <NSObject>

@optional

- (void)gmsDirectionsService:(GMSDirectionService *)gmsDirectionsService didCalculateTravelInfo:(NSDictionary *)travelInfo fromOrigin:(NSString *)origin toDestination:(NSString *)destination arrivalTime:(NSDate *)arrivalTime;
- (void)gmsDirectionsService:(GMSDirectionService *)gmsDirectionsService couldNotCalculateTravelInfoFromOrigin:(NSString *)origin toDestination:(NSString *)destination arrivalTime:(NSDate *)arrivalTime;

- (void)gmsDirectionsService:(GMSDirectionService *)gmsDirectionsService didCalculateRouteWaypointsInfo:(NSDictionary *)routeWaypointsInfo fromOrigin:(NSString *)origin toDestination:(NSString *)destination arrivalTime:(NSDate *)arrivalTime;
- (void)gmsDirectionsService:(GMSDirectionService *)gmsDirectionsService couldNotCalculateRouteWaypointsInfoFromOrigin:(NSString *)origin toDestination:(NSString *)destination arrivalTime:(NSDate *)arrivalTime;

@end

@interface GMSDirectionService : NSObject <HTTPRequestDelegate>

- (id)initWithDelegate:(id<GMSDirectionServiceDelegate>)delegate;

// can handle textual addresses as well as coordinates (for coordinates format is @"<lat>,<long>")
- (void)calculateRouteFromOrigin:(NSString *)origin toDestination:(NSString *)destination arrivalTime:(NSDate *)arrivalTime;



@end
