//
//  CamerasOnRouteView.h
//  CameraFinder
//
//  Created by Nikolas Burk on 26/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@class CamerasOnRouteView;

@protocol CamerasOnRouteViewDelegate <NSObject>

- (void)camerasOnRouteViewDismissButtonPressed:(CamerasOnRouteView *)camerasOnRouteView;
- (void)camerasOnRouteViewShareButtonPressed:(CamerasOnRouteView *)camerasOnRouteView;


@end

@interface CamerasOnRouteView : UIView

@property (weak, nonatomic) UIVisualEffectView *visualEffectView;

- (IBAction)dismissButtonPressed:(id)sender;
- (IBAction)shareButtonPressed;

@property (weak, nonatomic) IBOutlet UILabel *howManyCamerasLabel;
@property (nonatomic, assign) NSInteger howManyCameras;

@property (nonatomic, weak) id<CamerasOnRouteViewDelegate>delegate;

- (void)initialize;

@end
