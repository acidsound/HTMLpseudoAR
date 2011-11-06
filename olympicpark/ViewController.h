//
//  ViewController.h
//  olympicpark
//
//  Created by LEE JAEHO on 11. 11. 5..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIWebViewDelegate, CLLocationManagerDelegate, UIAccelerometerDelegate> {
    UIWebView* webView;
    CLLocationManager* locationManager;
    UIAccelerometer* accelerometerManager;
	UIImagePickerController* cameraController;
}

@end
