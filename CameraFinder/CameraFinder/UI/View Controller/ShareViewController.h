//
//  ShareViewController.h
//  CameraFinder
//
//  Created by Nikolas Burk on 26/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CamerasOnRouteView.h"

@interface ShareViewController : UIViewController

@property (weak, nonatomic) IBOutlet CamerasOnRouteView *camerasOnRouteView;
@property (nonatomic,assign) NSInteger howManyCameras;


@end
