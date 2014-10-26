//
//  CamerasOnRouteView.m
//  CameraFinder
//
//  Created by Nikolas Burk on 26/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import "CamerasOnRouteView.h"

@implementation CamerasOnRouteView

- (void)initialize
{
//    [self setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.5]];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [bluredEffectView setFrame:self.bounds];
    
    
    [self addSubview:bluredEffectView];
    
    [self sendSubviewToBack:bluredEffectView];
    

    
//    // Vibrancy Effect
//    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
//    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
//    [vibrancyEffectView setFrame:self.bounds];
//    
//    // Add Label to Vibrancy View
////    [vibrancyEffectView.contentView addSubview:self.movieTitle];
////    [vibrancyEffectView.contentView addSubview:self.movieReleaseDate];
//    
//    // Add Vibrancy View to Blur View
//    [bluredEffectView.contentView addSubview:vibrancyEffectView];
    

}

- (IBAction)dismissButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(camerasOnRouteViewDismissButtonPressed:)]) {
        [self.delegate camerasOnRouteViewDismissButtonPressed:self];
    }
}

- (IBAction)shareButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(camerasOnRouteViewShareButtonPressed:)]) {
        [self.delegate camerasOnRouteViewShareButtonPressed:self];
    }
}

- (void)setHowManyCameras:(NSInteger)howManyCameras
{
    _howManyCameras = howManyCameras;
    
    NSMutableAttributedString *newLabelText = nil;
    
    if (self.howManyCameras == 0) {
        NSString *text = @"Auf der Route werden sich keine Kameras in deiner Nähe befinden.";
        NSRange range = NSMakeRange(24, 13);
        newLabelText = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
        [newLabelText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0] range:range];
    }
    else if(self.howManyCameras == 1){
        NSString *text = [NSString stringWithFormat:@"Auf der Route wird sich eine Kamera in deiner Nähe befinden."];
        NSRange range = NSMakeRange(23, 12);
        newLabelText = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
        [newLabelText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0] range:range];
    }
    else{
        NSString *text = [NSString stringWithFormat:@"Auf der Route werden sich %d Kameras in deiner Nähe befinden.", self.howManyCameras];
        NSRange range = self.howManyCameras < 10 ?  NSMakeRange(25, 9) : NSMakeRange(25, 10);
        newLabelText = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
        [newLabelText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0] range:range];
    }
    
    self.howManyCamerasLabel.attributedText = newLabelText;
}

@end
