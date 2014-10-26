//
//  AddCameraViewController.m
//  CameraFinder
//
//  Created by Nikolas Burk on 25/10/14.
//  Copyright (c) 2014 Burda. All rights reserved.
//

#import "AddCameraViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+DashedBorder.h"
#import "Camera.h"
#import "SVProgressHUD.h"

#define IOS_BLUE [[[[UIApplication sharedApplication] delegate] window] tintColor]

@interface AddCameraViewController ()

// View components
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITextField *ownerTextfield;

// Action
- (IBAction)takePictureButtonPressed;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)sendButtonPressed;

// Parameters for body
@property (nonatomic, strong) UIImage *cameraPhoto;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;


@end


@implementation AddCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Hinzufügen";
    
    // On iOS 8 location authorization needs to be requested explicitly
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion rangeOfString:@"8"].location != NSNotFound) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestAlwaysAuthorization];
    }
    
    // Configure the empty camera image view
    UIColor *dashedBorderColor = [self.view tintColor];
    [self.cameraImageView addDashedBorderWithColor:dashedBorderColor cornerRadius:10.0 borderWith:3.0];
    
    // Configure the map view
    self.mapView.userInteractionEnabled = NO;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.layer.cornerRadius = self.mapView.bounds.size.width/2.0;
    
    // Add tap gesture recognizer to dismiss keyboard on tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - Map view delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.02; // the higher the more it zooms out
    span.longitudeDelta = 0.02;
    
    self.coordinate = userLocation.coordinate;
    
    region.span = span;
    region.center = userLocation.location.coordinate;
    [mapView setRegion:region animated:NO];
    
    [mapView regionThatFits:region]; // Set `regionThatFits:` with `region` like bellow...
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    annotationView.image = [UIImage imageNamed:@"camera64_48"];
    
    return annotationView;
}


#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Image picker controller delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    if (image) {
        
        UIImage *compressedImage = [self compressImage:image];
        
        self.cameraImageView.image = compressedImage;
        [self.cameraImageView removeDashedBorder];
        self.cameraImageView.layer.cornerRadius = 5.0;
        [self.infoLabel removeFromSuperview];
        self.cameraPhoto = compressedImage;
    }
    else{
        NSLog(@"No picture taken");
    }
}


#pragma mark - Actions

- (IBAction)takePictureButtonPressed
{
    [self showCameraViewController];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonPressed
{
    
    [SVProgressHUD showWithStatus:@"Sende daten..." maskType:SVProgressHUDMaskTypeGradient];
    NSDictionary *body = [self generateParameters];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = nil;
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
//    NSLog(@"Body: %@", jsonString);
    
    
    NSData *postData = [jsonString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.43.46:3000/addCamera"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    NSLog(@"Send to URL: %@", [[request URL] absoluteString]);
    
    if(conn)
    {
        NSLog(@"Connection Successful");
    }
    else
    {
        NSLog(@"Connection could not be made");
    }
}

#pragma mark - URL Connection delegate

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Did fail: %@", [error description]);
    [SVProgressHUD showErrorWithStatus:@"Fehlgeschlagen"];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    NSLog(@"Did receive data: %d", [data length]);

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Did finish loading");
    [SVProgressHUD showSuccessWithStatus:@"Gesendet!"];
}

- (void)showCameraViewController
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    picker.showsCameraControls = YES;
    
    UIView *focus = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
    focus.center = picker.view.center;
    
    [self presentViewController:picker animated:YES
                     completion:^ {
    }];
}


#pragma mark - Helpers

- (UIImage *)compressImage:(UIImage *)image
{
//    CGSize oldSize = image.size;
    
    CGSize newSize = CGSizeMake(320.0, 567.0);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSDictionary *)generateParameters
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"img"] =  [self encodeToBase64String:self.cameraPhoto];
    parameters[kObjectRecognition] = @(NO);
    parameters[kCameraAddress] = @"";
    parameters[kAudio] = @(NO);
    parameters[kCategory] = @"Noch nicht bestätigt";
    parameters[kCount] = @(1);
    parameters[@"countPublic"] = @(1);
    parameters[kCameraLatitude] = @(self.coordinate.latitude);
    parameters[kCameraLongitude] = @(self.coordinate.longitude);
    parameters[kObjectRecognition] = @(NO);
    parameters[kOwner] = self.ownerTextfield.text;
    parameters[kRealTime] = @(NO);
    return [[NSDictionary alloc] initWithDictionary:parameters];
}

- (NSString *)encodeToBase64String:(UIImage *)image
{
    NSString *prefix = @"data:image/jpeg;base64,";
//    NSData *imageData = UIImageJPEGRepresentation(image);
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString *content = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]; // NSDataBase64Encoding64CharacterLineLength
    return [NSString stringWithFormat:@"%@%@", prefix, content];
}

- (NSData *)dataFromBase64EncodedString:(NSString *)string{
    if (string.length > 0) {
        
        //the iPhone has base 64 decoding built in but not obviously. The trick is to
        //create a data url that's base 64 encoded and ask an NSData to load it.
        NSString *data64URLString = [NSString stringWithFormat:@"data:;base64,%@", string];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:data64URLString]];
        return data;
    }
    return nil;
}


#pragma mark - Build UI

- (void)addCameraBarButton
{
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCameraViewController)];
    self.navigationItem.rightBarButtonItem = cameraButton;
}



@end
