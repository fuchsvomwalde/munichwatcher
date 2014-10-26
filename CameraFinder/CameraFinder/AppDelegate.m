//
//  AppDelegate.m
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import "AppDelegate.h"
#import "GoogleEngine.h"

#define IOS_BLUE [[[[UIApplication sharedApplication] delegate] window] tintColor]


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GMSServices provideAPIKey:GOOGLE_API_KEY];
    
    
    return YES;
}

@end
