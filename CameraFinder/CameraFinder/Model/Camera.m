//
//  Camera.m
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import "Camera.h"

@implementation Camera

- (id)initWithCameraInfo:(NSDictionary *)cameraInfo
{
    self = [super init];
    if (self) {
        _address = cameraInfo[kCameraAddress];
        _audio = [cameraInfo[kAudio] boolValue];
        _category = cameraInfo[kCategory];
        _count = [cameraInfo[kCount] integerValue];
        _latitude = [cameraInfo[kCameraLatitude] doubleValue];
        _longitude = [cameraInfo[kCameraLongitude] doubleValue];
        _objectRecognition = [cameraInfo[kObjectRecognition] boolValue];
        _owner = cameraInfo[kOwner];
        _realtime = [cameraInfo[kRealTime] boolValue];
    }
    return self;
}

+ (Camera *)cameraWithCameraInfo:(NSDictionary *)cameraInfo
{
    return [[Camera alloc] initWithCameraInfo:cameraInfo];
}


@end
