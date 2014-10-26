//
//  CameraMarker.h
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "Camera.h"

@interface CameraMarker : GMSMarker

@property (nonatomic, strong) Camera *camera;

- (void)highlight; // highlights this marker
- (void)reset; // resets the highlighting of this marker

@end
