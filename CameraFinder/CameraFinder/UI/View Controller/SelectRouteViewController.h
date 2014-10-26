//
//  SelectRouteViewController.h
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSGeocodingService.h"
#import "GMSDirectionService.h"

@class SelectRouteViewController;

@protocol SelectRouteViewControllerDelegate <NSObject>

- (void)selectRouteViewController:(SelectRouteViewController *)delectRouteViewController didCollectWaypointsInfo:(NSDictionary *)waypointsInfo;

@end

@interface SelectRouteViewController : UIViewController <GMSGeocodingServiceDelegate, GMSDirectionServiceDelegate, UITextFieldDelegate>

@property (nonatomic, strong) id<SelectRouteViewControllerDelegate> delegate;

@end
