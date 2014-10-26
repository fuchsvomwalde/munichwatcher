//
//  HTTPRequest.m
//  TrafficAlarm
//
//  Created by Nikolas Burk on 10/03/14.
//  Copyright (c) 2014 Nikolas Burk. All rights reserved.
//

#import "HTTPRequest.h"

@interface HTTPRequest ()

@property (nonatomic, strong) NSURL *targetURL;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSHTTPURLResponse *response;

@property (nonatomic, weak) id<HTTPRequestDelegate>delegate;

@end


@implementation HTTPRequest

#pragma mark - API

- (id)initWithRequestType:(RequestType)requestType delegate:(id<HTTPRequestDelegate>)delegate urlString:(NSString *)urlString;
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        _urlString = urlString;
        _requestType = requestType;
    }
    return self;
}

- (void)send
{
    self.targetURL = [NSURL URLWithString:self.urlString];
    
    if (!self.targetURL)
    {
        NSString *errorMessage = [NSString stringWithFormat:@"Could not create url from string: %@", self.urlString];
        NSLog(@"ERROR | %s | %@", __func__, errorMessage);
        return;
    }
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.targetURL];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    NSString *logMessage = [NSString stringWithFormat:@"Send request to: %@", self.urlString];
    NSLog(@"DEBUG | %s | %@", __func__, logMessage);
    NSLog(@"%@", logMessage);

    [self.connection start];
    
    _executing = YES;
}

- (void)cancel
{
    NSString *logMessage = [NSString stringWithFormat:@"Cancel request to: %@", self.urlString];
//    NSLog(@"DEBUG | %s | %@", __func__, logMessage);
    NSLog(@"%@", logMessage);
    
    if (self.connection)
    {
        [self.connection cancel];
    }
    [self cleanUp];
}

#pragma mark - URL connection data delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    self.response = response;
    
    NSString *logMessage = [NSString stringWithFormat:@"Did receive response with code: %ld", (long)self.response.statusCode];
    //    NSLog(@"DEBUG | %s | %@", __func__, logMessage);    DLog(@"%@", logMessage);
    NSLog(@"%@", logMessage);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!self.responseData) self.responseData = [[NSMutableData alloc] init];
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSString *errorMessage = [NSString stringWithFormat:@"Did fail with error: %@", error];
    NSLog(@"ERROR | %s | %@", __func__, errorMessage);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(httpRequest:didFailWithError:)])
    {
        [self.delegate httpRequest:self didFailWithError:error];
    }
    [self cleanUp];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSString *logMessage = [NSString stringWithFormat:@"Did finish loading: %@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]];
//    NSLog(@"DEBUG | %s | %@", __func__, logMessage);
    
    if ([self.delegate respondsToSelector:@selector(httpRequest:didReturnWithResponse:andData:)])
    {
        [self.delegate httpRequest:self didReturnWithResponse:self.response andData:self.responseData];
    }
    else
    {
        NSLog(@"ERROR | Delegate object: %@ doesn't respond to selector (httpRequest:didReturnWithResponse:andData:)", self.delegate);
    }
    [self cleanUp];
}


#pragma mark - Helpers

- (void)cleanUp
{
    self.connection = nil;
    self.targetURL = nil;
    self.responseData = nil;
    _executing = NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Request (%@) | executing: %@", self.urlString, self.isExecuting ? @"YES" : @"NO"];
}



@end
