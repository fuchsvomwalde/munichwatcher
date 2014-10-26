//
//  RouteViewController.m
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import "RouteViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "CameraParser.h"
#import "CamerasOnRouteDetector.h"
#import "CameraMarker.h"
#import "UIView+FrameModification.h"
#import "ShareViewController.h"

#define CAMERAS_FILE_NAME @"cameras"

@interface RouteViewController ()

@property (nonatomic, strong) NSArray *cameras;
@property (nonatomic, strong) NSMutableArray *cameraMarkers;
@property (nonatomic, strong) NSArray *formerCamerasOnRoute;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (nonatomic, strong) CamerasOnRouteView *camerasOnRouteView;

@end

@implementation RouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Route"; 
    
    self.cameras = [CameraParser camerasFromFile:CAMERAS_FILE_NAME];
    [self addCameraMarkers];
    
    self.camerasOnRouteView = [[[NSBundle mainBundle] loadNibNamed:@"CamerasOnRouteView" owner:self options:nil] firstObject];
    [self.camerasOnRouteView initialize];
    self.camerasOnRouteView.delegate = self;
    
    NSLog(@"%@", [self.view tintColor]);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:48.1333
                                                            longitude:11.5667
                                                                 zoom:12];
    [self.mapView setCamera:camera];
}


#pragma mark - Select route view controller delegate

-(void)selectRouteViewController:(SelectRouteViewController *)delectRouteViewController didCollectWaypointsInfo:(NSDictionary *)waypointsInfo
{
    for (CameraMarker *cameraMarker in self.cameraMarkers) {
        [cameraMarker reset];
    }
    
    NSDictionary *overviewPolyline = waypointsInfo[kOverviewPolyline];
    NSString *routePoints = [overviewPolyline objectForKey:@"points"];
    GMSPath *path = [GMSPath pathFromEncodedPath:routePoints];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.map = self.mapView;
    
    [self zoomInForRouteWithWaypointsInfo:waypointsInfo];
    
    NSArray *camerasOnRoute = [CamerasOnRouteDetector findCamerasInArray:self.cameras onRouteWithSteps:waypointsInfo[kSteps]];
    NSLog(@"Did find %i cameras on the route", [camerasOnRoute count]);

    NSInteger actualCamerasOnRoute = 0;
    for(Camera *cameraOnRoute in camerasOnRoute){
        actualCamerasOnRoute += cameraOnRoute.count;
    }
    
    self.formerCamerasOnRoute = camerasOnRoute;
    
    [self showCameraOnRoutesViewOverlayWithFoundCameras:actualCamerasOnRoute];
}

- (CameraMarker *)markerForCamera:(Camera *)camera
{
    for (CameraMarker *marker in self.cameraMarkers) {
        if ([marker.camera isEqual:camera]) {
            return marker;
        }
    }
    return nil;
}


#pragma mark - Cameras on route view delegate

- (void)camerasOnRouteViewDismissButtonPressed:(CamerasOnRouteView *)camerasOnRouteView
{
    [self removeCamerasOnRouteViewOverlay];
}

- (void)camerasOnRouteViewShareButtonPressed:(CamerasOnRouteView *)camerasOnRouteView
{
    ShareViewController *shareViewController = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
    shareViewController.howManyCameras = camerasOnRouteView.howManyCameras;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:shareViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:segueShowSelectRouteViewController]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SelectRouteViewController *selectRouteViewController = [navigationController.viewControllers firstObject];
        selectRouteViewController.delegate = self;
    }
}

#pragma mark - UI

- (void)showCameraOnRoutesViewOverlayWithFoundCameras:(NSInteger)foundCameras
{
    self.camerasOnRouteView.howManyCameras = foundCameras;
    
    [self.camerasOnRouteView setX:0.0];
    [self.camerasOnRouteView setY:self.view.bounds.size.height];
    [self.view addSubview:self.camerasOnRouteView];
    
    [UIView animateWithDuration:1.5 animations:^{
        [self.camerasOnRouteView setY:self.view.bounds.size.height-self.camerasOnRouteView.bounds.size.height];
    }];
}

- (void)removeCamerasOnRouteViewOverlay
{
    [UIView animateWithDuration:1.0 animations:^{
        [self.camerasOnRouteView setY:self.view.bounds.size.height+self.camerasOnRouteView.bounds.size.height];
    } completion:^(BOOL finished){
        [self.camerasOnRouteView removeFromSuperview];
    }];
}


#pragma mark - Helpers

- (void)addCameraMarkers
{
    self.cameraMarkers = [[NSMutableArray alloc] init];
    CameraMarker *marker = nil;
    for (Camera *camera in self.cameras) {
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(camera.latitude, camera.longitude);
        marker = [CameraMarker markerWithPosition:position];
        NSString *addressString = [camera.address length] > 15 ? [NSString stringWithFormat:@"%@...", [camera.address substringToIndex:15]] : camera.address;
        marker.title = [NSString stringWithFormat:@"%@ (Anzahl: %d)", addressString, camera.count];
        marker.icon = [UIImage imageNamed:@"camera32_24"];
        marker.map = self.mapView;
        marker.camera = camera;
        [self.cameraMarkers addObject:marker];
    }
}

- (void)zoomInForRouteWithWaypointsInfo:(NSDictionary *)wayPointsInfo
{
    NSDictionary *bounds = wayPointsInfo[kCoordinateBounds];
    NSDictionary *northEastBounds = bounds[@"northeast"];
    NSDictionary *southWestBounds = bounds[@"southwest"];
    
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake([northEastBounds[@"lat"] doubleValue], [northEastBounds[@"lng"] doubleValue]);
    CLLocationCoordinate2D southwest = CLLocationCoordinate2DMake([southWestBounds[@"lat"] doubleValue], [southWestBounds[@"lng"] doubleValue]);
    
    GMSCoordinateBounds *coordinateBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast coordinate:southwest];
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:coordinateBounds
                                             withPadding:100.0f];
    [self.mapView moveCamera:update];
}


@end
