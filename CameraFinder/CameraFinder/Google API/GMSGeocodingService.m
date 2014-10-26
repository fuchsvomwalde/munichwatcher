//
//  GMSGeocodingService.m
//  TrafficAlarm
//
//  Created by Nikolas Burk on 10/03/14.
//  Copyright (c) 2014 Nikolas Burk. All rights reserved.
//

#import "GoogleEngine.h"

#define HOUSE_NUMBER_INDEX 0
#define STREET_INDEX 0
//#define CITY_INDEX 4
//#define COUNTRY_INDEX 6
//#define ZIP_CODE_INDEX 7


@interface GMSGeocodingService ()

// Temporary variables to provide richer information to delegate
@property (nonatomic, strong) NSString *unformattedAddress;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

@property (nonatomic, weak) id<GMSGeocodingServiceDelegate> delegate;
@property (nonatomic, strong) HTTPRequest *request;

@end

@implementation GMSGeocodingService

- (id)initWithDelegate:(id<GMSGeocodingServiceDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}


#pragma mark - API

- (void)geocodeAddress:(NSString *)address
{
    self.unformattedAddress = address;
    NSString *geocodingBaseURL = @"https://maps.googleapis.com/maps/api/geocode/json?"; //
    NSString *targetURL = [NSString stringWithFormat:@"%@address=%@&sensor=false&language=%@", geocodingBaseURL, address, GEOCODING_LANGUAGE];
    targetURL = [targetURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    self.request = [[HTTPRequest alloc] initWithRequestType:RT_Geocode delegate:self urlString:targetURL];
    [self.request send];
}

- (void)getAddressFromLatidute:(float)latitude longitude:(float)longitude
{
    self.latitude = latitude;
    self.longitude = longitude;
    
    NSString *geocodingBaseURL = @"https://maps.googleapis.com/maps/api/geocode/json?"; //
    NSString *latitudeString = [NSString stringWithFormat:@"%f", latitude];
    NSString *longitudeString = [NSString stringWithFormat:@"%f", longitude];
    NSString *targetURL = [NSString stringWithFormat:@"%@latlng=%@,%@&sensor=false&language=%@", geocodingBaseURL, latitudeString, longitudeString, GEOCODING_LANGUAGE];
    targetURL = [targetURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    self.request = [[HTTPRequest alloc] initWithRequestType:RT_ReverseGeocode delegate:self urlString:targetURL];
    [self.request send];
    
//    [[Mixpanel sharedInstance] track:MPE_1_ReverseGeocodingRequestSent properties:@{
//                                                                        MPP_1_TargetURL: [self.request urlString]
//                                                                        }];
}

- (BOOL)isExecutingRequest
{
    return self.request.isExecuting;
}

- (void)cancelRequests
{
    [self.request cancel];
    
    if ([self.delegate respondsToSelector:@selector(gmsGeodocodingService:didCancelRequest:)])
    {
        [self.delegate gmsGeodocodingService:self didCancelRequest:self.request];
    }
}

#pragma mark - HTTP Request delegate

- (void)httpRequest:(HTTPRequest *)httpRequest didReturnWithResponse:(NSURLResponse *)response andData:(NSData *)responseData
{
    switch (httpRequest.requestType)
    {
        case RT_Geocode:
            [self handleGeocodingResponseWithResponseData:responseData];
            break;
            
        case RT_ReverseGeocode:
            [self handleReverseGeocodingResponseWithResponseData:responseData];

            break;
        default:
            break;
    }
    
    self.request = nil;
}

- (void)httpRequest:(HTTPRequest *)httpRequest didFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(gmsGeodocodingService:couldNotGeocodeAddress:)])
    {
        [self.delegate gmsGeodocodingService:self couldNotGeocodeAddress:self.unformattedAddress];
    }
    
    self.request = nil;
}

#pragma mark - Response handlers

- (void)handleGeocodingResponseWithResponseData:(NSData *)responseData
{
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    NSArray *results = [json objectForKey:@"results"];
    NSDictionary *result = [results firstObject];
    
//    NSArray *addressComponents = result[@"address_components"];
//    NSString *houseNumber = addressComponents[HOUSE_NUMBER_INDEX][@"short_name"];
//    NSString *street = addressComponents[STREET_INDEX][@"short_name"];
//    street = [street stringByAppendingString:[NSString stringWithFormat:@" %@", houseNumber]];
    //    NSString *city = addressComponents[STREET_INDEX][@"short_name"];
    //    NSString *zipCode = addressComponents[ZIP_CODE_INDEX][@"short_name"];
    //    NSString *country = addressComponents[COUNTRY_INDEX][@"short_name"];
    
    NSString *address = result[@"formatted_address"];
    
    NSDictionary *geometry = result[@"geometry"];
    NSDictionary *location = geometry[@"location"];
    
    NSString *latitude = location[@"lat"];
    NSString *longitude = location[@"lng"];
    
    NSMutableDictionary *geocodingResults = [[NSMutableDictionary alloc] initWithDictionary:[self splitFormattedAddress:address]];
    //NSMutableDictionary *geocodingResults = [[NSMutableDictionary alloc] init];
    //[geocodingResults addEntriesFromDictionary:@{ kAddress : address, kLatitude : latitude, kLongitude : longitude, kStreet : street, kCity : city, kCountry : country, kZipCode : zipCode }];
    [geocodingResults addEntriesFromDictionary:@{ kAddress : address, kLatitude : latitude, kLongitude : longitude }];
    
    if (geocodingResults)
    {
        self.geocode = geocodingResults;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(gmsGeodocodingService:didGeocodeAddress:withGeocodingResult:)])
        {
            [self.delegate gmsGeodocodingService:self didGeocodeAddress:self.unformattedAddress withGeocodingResult:self.geocode];
        }
    }
}

- (void)handleReverseGeocodingResponseWithResponseData:(NSData *)responseData
{
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    NSArray *results = [json objectForKey:@"results"];
    NSDictionary *result = [results firstObject];
    
    NSArray *addressComponents = result[@"address_components"];
    NSString *houseNumber = addressComponents[HOUSE_NUMBER_INDEX][@"short_name"];
    NSString *street = addressComponents[STREET_INDEX][@"short_name"];
    street = [street stringByAppendingString:[NSString stringWithFormat:@" %@", houseNumber]];
    //    NSString *city = addressComponents[STREET_INDEX][@"short_name"];
    //    NSString *zipCode = addressComponents[ZIP_CODE_INDEX][@"short_name"];
    //    NSString *country = addressComponents[COUNTRY_INDEX][@"short_name"];
    
    NSString *address = result[@"formatted_address"];
    
//    [[Mixpanel sharedInstance] track:MPE_2_ReverseGeocodingResponseReceived properties:@{
//                                                                                    MPP_2_FormattedAddress: address
//                                                                                    }];
    
    NSDictionary *geometry = result[@"geometry"];
    NSDictionary *location = geometry[@"location"];
    
    NSString *latitude = location[@"lat"];
    NSString *longitude = location[@"lng"];
    
    
    NSMutableDictionary *geocodingResults = [[NSMutableDictionary alloc] initWithDictionary:[self splitFormattedAddress:address]];
    [geocodingResults addEntriesFromDictionary:@{ kAddress : address, kLatitude : latitude, kLongitude : longitude }];
    
    if (geocodingResults)
    {
        self.geocode = geocodingResults;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(gmsGeodocodingService:didReverseGeocodeLatitude:longitude:withGeocodingResult:)])
        {
            [self.delegate gmsGeodocodingService:self didReverseGeocodeLatitude:self.latitude longitude:self.longitude withGeocodingResult:self.geocode];
        }
    }
}



#pragma mark - Helpers

- (NSDictionary *)splitFormattedAddress:(NSString *)formattedAddress
{
    //    const int FORMATTED_ADDRESS_STREET_INDEX = 0;
    //    const int FORMATTED_ADDRESS_CITY_ZIPCODE_INDEX = 1;
    //    const int FORMATTED_ADDRESS_COUNTRY_INDEX = 2;
    //    const int FORMATTED_CITY_ZIPCODE_INDEX = 0;
    //    const int FORMATTED_CITY_CITY_INDEX = 1;
    NSArray *addressComponentsArray = [formattedAddress componentsSeparatedByString:@", "];
    
    const int FORMATTED_ADDRESS_STREET_INDEX = 0;
    const int FORMATTED_ADDRESS_CITY_ZIPCODE_INDEX = [addressComponentsArray count]-2;
    const int FORMATTED_ADDRESS_COUNTRY_INDEX = [addressComponentsArray count]-1;
    
//    NSArray *cityComponentsArray = [(NSString *)addressComponentsArray[FORMATTED_ADDRESS_CITY_ZIPCODE_INDEX] componentsSeparatedByString:@" "];
//    NSDictionary *addressComponentsDictionary = @{ kStreet : addressComponentsArray[FORMATTED_ADDRESS_STREET_INDEX], kCity : cityComponentsArray[FORMATTED_CITY_CITY_INDEX], kCountry : addressComponentsArray[FORMATTED_ADDRESS_COUNTRY_INDEX], kZipCode : cityComponentsArray[FORMATTED_CITY_ZIPCODE_INDEX] };
    NSString *zipcodeAndCityString = addressComponentsArray[FORMATTED_ADDRESS_CITY_ZIPCODE_INDEX];
    NSArray *zipcodeAndCityArray = [zipcodeAndCityString componentsSeparatedByString:@" "];
    NSString *zipcode = zipcodeAndCityArray[0];
    NSString *city = [zipcodeAndCityString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ ", zipcode] withString:@""];
    
    NSDictionary *addressComponentsDictionary = @{ kStreet : addressComponentsArray[FORMATTED_ADDRESS_STREET_INDEX], kCity : city, kZipCode : zipcode, kCountry : addressComponentsArray[FORMATTED_ADDRESS_COUNTRY_INDEX]};
    return addressComponentsDictionary;
}

@end
