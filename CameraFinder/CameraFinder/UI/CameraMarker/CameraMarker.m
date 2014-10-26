//
//  CameraMarker.m
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import "CameraMarker.h"

@implementation CameraMarker

- (void)highlight
{
    self.icon = [UIImage imageNamed:@"camera128_96"];
}

- (void)reset
{
    self.icon = [UIImage imageNamed:@"camera32_24"];

}


@end
