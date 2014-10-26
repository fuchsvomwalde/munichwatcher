//
//  HTTPRequest.h
//  TrafficAlarm
//
//  Created by Nikolas Burk on 10/03/14.
//  Copyright (c) 2014 Nikolas Burk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RT_Geocode = 1,
    RT_ReverseGeocode,
    RT_Directions
} RequestType;

@class HTTPRequest;

@protocol HTTPRequestDelegate <NSObject>

- (void)httpRequest:(HTTPRequest *)httpRequest didReturnWithResponse:(NSURLResponse *)response andData:(NSData *)responseData;
- (void)httpRequest:(HTTPRequest *)httpRequest didFailWithError:(NSError *)error;

@end

@interface HTTPRequest : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong, readonly) NSString *urlString;
@property (nonatomic, assign, readonly) RequestType requestType;
@property (nonatomic, assign, readonly, getter = isExecuting) BOOL executing;

- (id)initWithRequestType:(RequestType)requestType delegate:(id<HTTPRequestDelegate>)delegate urlString:(NSString *)urlString;
- (void)send;
- (void)cancel;

@end
