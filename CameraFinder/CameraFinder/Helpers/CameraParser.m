//
//  CameraParser.m
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import "CameraParser.h"

@implementation CameraParser

+ (NSArray *)camerasFromFile:(NSString *)file
{
    NSMutableArray *cameras = [[NSMutableArray alloc] init];

    NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:file withExtension:@"json"];
    NSString *stringPath = [jsonURL absoluteString]; //this is correct
    
    NSLog(@"DEBUG | %s | Parse file at path: %@", __func__, stringPath);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringPath]];
    //    NSData *data = [NSData dataWithContentsOfURL:stringPath];

    NSError *error;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (error) {
        NSLog(@"%@ | %@", [error description], [error localizedFailureReason]);
    }
    
    if ([result isKindOfClass:[NSArray class]]) {
        Camera *camera = nil;
        for (NSDictionary *cameraInfo in result) {
            camera = [Camera  cameraWithCameraInfo:cameraInfo];
            [cameras addObject:camera];
        }
    }
    else if ([result isKindOfClass:[NSDictionary class]]){
        NSLog(@"DEBUG | %s | File at path returned a dictionary: %@", __func__, stringPath);
    }
    else {
        NSLog(@"DEBUG | %s | Error parsing file at path: %@", __func__, stringPath);
    }
    
    return [[NSArray alloc] initWithArray:cameras];
}

@end
