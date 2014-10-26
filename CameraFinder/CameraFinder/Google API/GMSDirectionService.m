//
//  GMSDirectionService.m
//  TrafficAlarm
//
//  Created by Nikolas Burk on 23/04/14.
//  Copyright (c) 2014 Nikolas Burk. All rights reserved.
//

#import "GMSDirectionService.h"

@interface GMSDirectionService ()

@property (nonatomic, strong) NSString *origin;
@property (nonatomic, strong) NSString *destination;
@property (nonatomic, strong) NSDate *arrivalTime;

@property (nonatomic, weak) id<GMSDirectionServiceDelegate> delegate;
@end

@implementation GMSDirectionService

- (id)initWithDelegate:(id<GMSDirectionServiceDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
    }
    return self;
}


#pragma mark - API

- (void)calculateRouteFromOrigin:(NSString *)origin toDestination:(NSString *)destination arrivalTime:(NSDate *)arrivalTime
{
    self.origin = origin;
    self.destination = destination;
    self.arrivalTime = arrivalTime;
    
    NSString *geocodingBaseURL = @"https://maps.googleapis.com/maps/api/directions/json?"; 
    NSString *targetURL = [NSString stringWithFormat:@"%@origin=%@&destination=%@&arrival_time=%f&sensor=false&language=%@", geocodingBaseURL, origin, destination, [arrivalTime timeIntervalSince1970], DIRECTIONS_LANGUAGE];
    targetURL = [targetURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    HTTPRequest *request = [[HTTPRequest alloc] initWithRequestType:RT_Directions delegate:self urlString:targetURL];
    [request send];

}


#pragma mark - HTTP Request delegate

- (void)httpRequest:(HTTPRequest *)httpRequest didReturnWithResponse:(NSURLResponse *)response andData:(NSData *)responseData
{
//    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"DEBUG | %s | Response: %@", , responseString);
    [self handleDirectionRequestWithResponseData:responseData];
}

- (void)httpRequest:(HTTPRequest *)httpRequest didFailWithError:(NSError *)error
{
    NSLog(@"ERROR | %@", error);
}


#pragma mark - Response handlers

- (void)handleDirectionRequestWithResponseData:(NSData *)responseData
{
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    NSArray *routes = [json objectForKey:@"routes"];
    NSArray *legs = ((NSDictionary *)[routes firstObject])[@"legs"]; // @[distance, duration, end_address, end_location] --> these are the names of the keys of the dictionaries that legs contains
    NSDictionary *resultsInfo = [legs firstObject];
    
    // Get the travel info and tell the delegate
    NSDictionary *distanceInfo = resultsInfo[@"distance"];
    NSDictionary *durationInfo = resultsInfo[@"duration"];
    NSDictionary *travelInfo = @{kDurationInfo : durationInfo, kDistanceInfo : distanceInfo};
    NSLog(@"Route (%@ --> %@): %@", self.origin, self.destination, travelInfo);
    if ([self.delegate respondsToSelector:@selector(gmsDirectionsService:didCalculateTravelInfo:fromOrigin:toDestination:arrivalTime:)]) {
        [self.delegate gmsDirectionsService:self didCalculateTravelInfo:travelInfo fromOrigin:self.origin toDestination:self.destination arrivalTime:self.arrivalTime];
    }
    
    // Get the waypoints info and tell the delegate
    NSDictionary *overviewPolyline = ((NSDictionary *)[routes firstObject])[@"overview_polyline"];
    NSArray *steps = ((NSDictionary *)[legs firstObject])[@"steps"];
    NSDictionary *bounds = ((NSDictionary *)[routes firstObject])[@"bounds"];

    NSDictionary *routeWaypointsInfo = @{kSteps : steps, kOverviewPolyline : overviewPolyline, kCoordinateBounds : bounds};
    if ([self.delegate respondsToSelector:@selector(gmsDirectionsService:didCalculateRouteWaypointsInfo:fromOrigin:toDestination:arrivalTime:)]) {
        [self.delegate gmsDirectionsService:self didCalculateRouteWaypointsInfo:routeWaypointsInfo fromOrigin:self.origin toDestination:self.destination arrivalTime:self.arrivalTime];
    }
    
}

@end
