//
//  RouteViewController.h
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectRouteViewController.h"
#import "CamerasOnRouteView.h"


#define segueShowSelectRouteViewController @"segueShowSelectRouteViewController"

@interface RouteViewController : UIViewController <SelectRouteViewControllerDelegate, CamerasOnRouteViewDelegate>

@end
