//
//  Camera.h
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCameraAddress @"adress"
#define kAudio @"audio"
#define kCategory @"category"
#define kCount @"count"
#define kCameraLatitude @"lat"
#define kCameraLongitude @"lng"
#define kObjectRecognition @"objectRecognition"
#define kOwner @"owner"
#define kRealTime @"realtime"

@interface Camera : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) BOOL audio;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) BOOL objectRecognition;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, assign) BOOL realtime;

+ (Camera *)cameraWithCameraInfo:(NSDictionary *)cameraInfo;

@end
