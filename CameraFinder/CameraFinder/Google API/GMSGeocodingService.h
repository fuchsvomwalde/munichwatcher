//
//  GMSGeocodingService.h
//  TrafficAlarm
//
//  Created by Nikolas Burk on 10/03/14.
//  Copyright (c) 2014 Nikolas Burk. All rights reserved.
//

#import "HTTPRequest.h"

#define kAddress @"kAddress"
#define kLongitude @"kLongitude"
#define kLatitude @"kLatitude"

#define kStreet @"kStreet"
#define kCity @"kCity"
#define kCountry @"kCountry"
#define kZipCode @"kZipCode"

#define GEOCODING_LANGUAGE @"de"

@class GMSGeocodingService;

@protocol GMSGeocodingServiceDelegate <NSObject>

@optional

- (void)gmsGeodocodingService:(GMSGeocodingService *)gmsGeocodingService didGeocodeAddress:(NSString *)geolocation withGeocodingResult:(NSDictionary *)geocodingResult;
- (void)gmsGeodocodingService:(GMSGeocodingService *)gmsGeocodingService couldNotGeocodeAddress:(NSString *)geolocation;

- (void)gmsGeodocodingService:(GMSGeocodingService *)gmsGeocodingService didReverseGeocodeLatitude:(float)latitude longitude:(float)longitude withGeocodingResult:(NSDictionary *)geocodingResult;
- (void)gmsGeodocodingService:(GMSGeocodingService *)gmsGeocodingService couldNotReverseGeocodeLatitude:(float)latitude longitude:(float)longitude;

- (void)gmsGeodocodingService:(GMSGeocodingService *)gmsGeocodingServiceDid didCancelRequest:(HTTPRequest *)request;
@end

@interface GMSGeocodingService : NSObject <HTTPRequestDelegate>

@property (nonatomic, strong) NSDictionary *geocode;
@property (nonatomic, readonly, getter = isExecutingRequest) BOOL executingRequest;

- (id)initWithDelegate:(id<GMSGeocodingServiceDelegate>)delegate;

- (void)geocodeAddress:(NSString *)address;
- (void)getAddressFromLatidute:(float)latitude longitude:(float)longitude;
- (void)cancelRequests;

@end
