//
//  SelectRouteViewController.m
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import "SelectRouteViewController.h"
#import "SVProgressHUD.h"

#define idStart 1
#define idDestination 2

@interface SelectRouteViewController()

@property (nonatomic, assign) NSInteger verify; // 1 = start; 2 = destination

// Google services
@property (nonatomic, strong) GMSGeocodingService *geocodingService;
@property (nonatomic, strong) GMSDirectionService *directionService;

// Buttons
@property (weak, nonatomic) IBOutlet UIButton *useOwnLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *verifyStartLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *verifyDestinationLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *calculateRouteButton;

// Actions
- (IBAction)useOwnLocationButtonPressed:(id)sender;
- (IBAction)verifyStartLocationButtonPressed:(id)sender;
- (IBAction)verifyDestinationLocationButton:(id)sender;
- (IBAction)calculateRouteButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

// Text fields
@property (weak, nonatomic) IBOutlet UITextField *startLocationTextfield;
@property (weak, nonatomic) IBOutlet UITextField *destinationLocationTextfield;



@end

@implementation SelectRouteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.geocodingService = [[GMSGeocodingService alloc] initWithDelegate:self];
    self.directionService = [[GMSDirectionService alloc] initWithDelegate:self];
    self.verify = -1;
    
    // Add tap gesture recognizer to dismiss keyboard on tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - Directions service delegate

-(void)gmsDirectionsService:(GMSDirectionService *)gmsDirectionsService didCalculateRouteWaypointsInfo:(NSDictionary *)routeWaypointsInfo fromOrigin:(NSString *)origin toDestination:(NSString *)destination arrivalTime:(NSDate *)arrivalTime
{
    if ([self.delegate respondsToSelector:@selector(selectRouteViewController:didCollectWaypointsInfo:)]) {
        [self.delegate selectRouteViewController:self didCollectWaypointsInfo:routeWaypointsInfo];
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)gmsDirectionsService:(GMSDirectionService *)gmsDirectionsService couldNotCalculateRouteWaypointsInfoFromOrigin:(NSString *)origin toDestination:(NSString *)destination arrivalTime:(NSDate *)arrivalTime
{
    
}


#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Geocoding service delegate

-(void)gmsGeodocodingService:(GMSGeocodingService *)gmsGeocodingService didGeocodeAddress:(NSString *)geolocation withGeocodingResult:(NSDictionary *)geocodingResult
{
    NSLog(@"DEBUG | Did receive geocoding response with result: %@", geocodingResult);
    [SVProgressHUD showSuccessWithStatus:@"Adresse gefunden"];
    
    UITextField *textFieldToUpdate = nil;
    
    if (self.verify == idStart) {
        textFieldToUpdate = self.startLocationTextfield;
    }
    else if (self.verify == idDestination){
        textFieldToUpdate = self.destinationLocationTextfield;
    }
    else{
        return;
    }
    
    NSString *verifiedAddressString = geocodingResult[kAddress];
    textFieldToUpdate.text = verifiedAddressString;
}

-(void)gmsGeodocodingService:(GMSGeocodingService *)gmsGeocodingService didReverseGeocodeLatitude:(float)latitude longitude:(float)longitude withGeocodingResult:(NSDictionary *)geocodingResult
{
    
}

- (void)gmsGeodocodingService:(GMSGeocodingService *)gmsGeocodingService couldNotGeocodeAddress:(NSString *)geolocation
{
    NSLog(@"ERROR | Could not geocode address: %@", geolocation);
    [SVProgressHUD showErrorWithStatus:@"Adresse nicht gefunden"];
}

-(void)gmsGeodocodingService:(GMSGeocodingService *)gmsGeocodingService couldNotReverseGeocodeLatitude:(float)latitude longitude:(float)longitude
{
    
}

#pragma mark - Actions

- (IBAction)useOwnLocationButtonPressed:(id)sender
{
    
}

- (IBAction)verifyStartLocationButtonPressed:(id)sender
{
    NSString *addressString = self.startLocationTextfield.text;
    [SVProgressHUD showWithStatus:@"Adresse verifizieren..." maskType:SVProgressHUDMaskTypeGradient];
    [self.geocodingService geocodeAddress:addressString];
    self.verify = idStart;
}

- (IBAction)verifyDestinationLocationButton:(id)sender
{
    NSString *addressString = self.destinationLocationTextfield.text;
    [SVProgressHUD showWithStatus:@"Adresse verifizieren..." maskType:SVProgressHUDMaskTypeGradient];
    [self.geocodingService geocodeAddress:addressString];
    self.verify = idDestination;
}

- (IBAction)calculateRouteButtonPressed:(id)sender
{
    NSString *startAddress = self.startLocationTextfield.text;
    NSString *destinationAddress = self.destinationLocationTextfield.text;
    [self.directionService calculateRouteFromOrigin:startAddress toDestination:destinationAddress arrivalTime:[[NSDate date] dateByAddingTimeInterval:3600]];
    [SVProgressHUD showWithStatus:@"Route berechnen..." maskType:SVProgressHUDMaskTypeGradient];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
