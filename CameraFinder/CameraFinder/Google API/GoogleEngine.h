//
//  GoogleEngine.h
//  TrafficAlarm
//
//  Created by Nikolas Burk on 10/03/14.
//  Copyright (c) 2014 Nikolas Burk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GMSGeocodingService.h"

#define GOOGLE_API_KEY @"AIzaSyD-SOBRBotvJ3Yzrhp0GQOUeaDWsrvJ1Bs"

@class GoogleEngine;

@protocol GoogleEngineDelegate <NSObject>



@end

@interface GoogleEngine : NSObject

@end
