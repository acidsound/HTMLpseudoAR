//
//  ViewController.m
//  olympicpark
//
//  Created by LEE JAEHO on 11. 11. 5..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVCaptureSession.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AVFoundation/AVCaptureInput.h>
#import <AVFoundation/AVCaptureOutput.h>

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)launchCamera {
    
    // Set up the camera
    cameraController = [[UIImagePickerController alloc] init];
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraController.delegate = self;
    
    cameraController.showsCameraControls = NO;
    cameraController.navigationBarHidden = YES;
    cameraController.toolbarHidden = YES;
    
    // overlay on top of camera lens view
    cameraController.cameraOverlayView = webView;
        
    [self presentModalViewController:cameraController animated:YES];
}

- (id)init {
	if (!(self = [super init])) return nil;
	return self;
}

- (void)closeCameraView{
	[cameraController.view removeFromSuperview];
}

#pragma mark - accelometer stuffs
/* referenced from 
http://developer.apple.com/library/ios/#documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/MotionEvents/MotionEvents.html#//apple_ref/doc/uid/TP40009541-CH4-SW18
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setAccelerometer(%f,%f,%f)", 
                                                     acceleration.x, acceleration.y, acceleration.z]];
    
}

#pragma mark - CoreLocation stuffs

- (void)startListening {
    if (!locationManager) {
        CLLocationManager* theManager = [[CLLocationManager alloc] init];
        
        // Retain the object in a property.
        locationManager = theManager;
        locationManager.delegate = self;

        // Start location services to get the true heading.
        // we want every move.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    }
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        locationManager.headingFilter = kCLHeadingFilterNone;
        [locationManager startUpdatingHeading];
    }

    if (!accelerometerManager) {
        accelerometerManager = [UIAccelerometer sharedAccelerometer];
        accelerometerManager.updateInterval = 0.02f;
        accelerometerManager.delegate = self;
        // Delegate events begin immediately.
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    // when updated compass heading value
    if (newHeading.headingAccuracy < 0)
        return;
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setHeading(%f)", 
                                                     ((newHeading.trueHeading > 0) ?
                                                      newHeading.trueHeading : newHeading.magneticHeading)]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 0.5)
    {
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setLocation(%+.6f,%+.6f)",
                                                         newLocation.coordinate.latitude,
                                                         newLocation.coordinate.longitude ]];
    }
    // else skip the event and process the next one.    
}


#pragma mark - Callback for WebView
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] absoluteString] isEqualToString:@"appsoulute://readyToActivate"]) {
        [self startListening];
#if !TARGET_IPHONE_SIMULATOR
        [self launchCamera];
#endif
        return false;
    }
    return true;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 480.0f)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:
                                                       [[NSBundle mainBundle] pathForResource:@"html/whereIgo" ofType:@"html"]]]];
    webView.delegate = self;

    // Set a WebView to make a background color transparent
    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:webView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
