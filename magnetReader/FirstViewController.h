//
//  FirstViewController.h
//  magnetReader
//
//  Created by Sam Royston on 2/27/14.
//  Copyright (c) 2014 Sam Royston. All rights reserved.
//


#import <opencv2/opencv.hpp>
using namespace cv;
#import <opencv2/highgui/cap_ios.h>

#import "opencv2/highgui/highgui.hpp"
#import "opencv2/objdetect/objdetect.hpp"
#import "opencv2/core/core.hpp"
#import "opencv2/ml/ml.hpp"
#import <UIKit/UIKit.h>
#import "CVDelegate.h"
#import "MusicDecoder.h"



@interface FirstViewController : UIViewController

@property (nonatomic, retain) CVDelegate *cv_handler;
@property (nonatomic, retain) CvVideoCamera *camera;
@property (nonatomic, retain) MusicDecoder *musicDecoder;
@property (nonatomic, retain) NSArray *colorCalibrateButtons;
@property (nonatomic, retain) NSArray *sizeCalibrateButtons;
@property (nonatomic, assign) int integerFromCircles;

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIView *hud_one;
@property (nonatomic, retain) IBOutlet UIView *hud_two;
@property (nonatomic, retain) IBOutlet UIView *camera_view;
@property (nonatomic, retain) IBOutlet UIButton *calibrateRedButton;
@property (nonatomic, retain) IBOutlet UIButton *calibrateGreenButton;
@property (nonatomic, retain) IBOutlet UIButton *calibrateBlueButton;
@property (nonatomic, retain) IBOutlet UIButton *calibrateYellowButton;
@property (nonatomic, retain) IBOutlet UIButton *calibrateWhiteButton;
@property (nonatomic, retain) IBOutlet UIButton *calibrateSmallButton;
@property (nonatomic, retain) IBOutlet UIButton *calibrateMediumButton;
@property (nonatomic, retain) IBOutlet UIButton *calibrateLargeButton;


- (IBAction)calibrate:(id)sender;
- (IBAction)calibRED:(id)sender;
- (IBAction)calibGREEN:(id)sender;
- (IBAction)calibBLUE:(id)sender;
- (IBAction)calibYELLOW:(id)sender;
- (IBAction)calibWHITE:(id)sender;

- (IBAction)calibSMALL:(id)sender;
- (IBAction)calibMEDIUM:(id)sender;
- (IBAction)calibLARGE:(id)sender;


@end
