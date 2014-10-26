//
//  CameraParser.h
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Camera.h"

@interface CameraParser : NSObject

+ (NSArray *)camerasFromFile:(NSString *)file;

@end
