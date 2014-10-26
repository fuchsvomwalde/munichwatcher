//
//  ShareViewController.m
//  CameraFinder
//
//  Created by Nikolas Burk on 26/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.camerasOnRouteView.howManyCameras = self.howManyCameras;

    self.title = @"Teilen";

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Fertig" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)dismiss
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
