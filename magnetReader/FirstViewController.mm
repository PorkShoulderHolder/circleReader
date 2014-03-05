//
//  FirstViewController.m
//  magnetReader
//
//  Created by Sam Royston on 2/27/14.
//  Copyright (c) 2014 Sam Royston. All rights reserved.
//

#define SQRT2 = 1.41421356237
#import "FirstViewController.h"


@interface FirstViewController ()

@end

@implementation FirstViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.colorCalibrateButtons = [NSArray arrayWithObjects:self.calibrateRedButton, self.calibrateGreenButton, self.calibrateBlueButton, self.calibrateYellowButton, self.calibrateWhiteButton, nil];
    
    self.hud_one.backgroundColor = [UIColor clearColor];
    self.hud_two.backgroundColor = [UIColor clearColor];
    self.cv_handler = [[CVDelegate alloc] init];
    self.cv_handler.hud_one = self.hud_one;
    self.cv_handler.hud_two = self.hud_two;
    self.cv_handler.integerLabel = self.label;
    [self initCamera];
    
    for(UIButton *button in self.colorCalibrateButtons){
        button.frame = self.calibrateRedButton.frame;
        button.hidden = YES;
        button.userInteractionEnabled = NO;
        button.opaque = NO;
    }
    
    self.musicDecoder = [[MusicDecoder alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewIntegerInfo:) name:@"INTEGER_UPDATE" object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)handleNewIntegerInfo:(NSNotification*)notification{
    int value = [[notification userInfo][@"perceived_integer"] intValue];
    int circlesCount =[[notification userInfo][@"circles_visible"] intValue];
    if (circlesCount > 0 ) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.label.text = [NSString stringWithFormat:@"%i", value];
        });
    }
    else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.label.text = [NSString stringWithFormat:@"None"];
        });
    }
    if (value != self.integerFromCircles && circlesCount != 0) {
        [self.musicDecoder handleInteger:value];
    }
    self.integerFromCircles = value;

    
    
}

- (IBAction)calibrate:(id)sender{
    UIButton *calbutton = (UIButton*) sender;
    calbutton.selected = !calbutton.selected;
    if (calbutton.selected) {
        [UIView animateWithDuration:0.4 animations:^{
            for(UIButton *button in self.colorCalibrateButtons){
                NSUInteger index = [self.colorCalibrateButtons indexOfObject:button];
                button.userInteractionEnabled = YES;
                
                button.frame = CGRectMake(self.calibrateRedButton.frame.origin.x, self.calibrateRedButton.frame.origin.y + (self.calibrateRedButton.frame.size.height * 1 * index), self.calibrateRedButton.frame.size.width, self.calibrateRedButton.frame.size.height);
                button.hidden = NO;
                button.opaque = YES;
            }
        }];
    }
    else{
        [UIView animateWithDuration:0.4 animations:^{
            for(UIButton *button in self.colorCalibrateButtons){
                button.frame = self.calibrateRedButton.frame;
                button.userInteractionEnabled = NO;
                button.opaque = NO;
            }
        } completion:^(BOOL finished){
            for(UIButton *button in self.colorCalibrateButtons){
                button.hidden = YES;
            }
        }];
    }
}

- (IBAction)calibBLUE:(id)sender{
    [self.cv_handler calibrateColor:BLUE];
}

- (IBAction)calibGREEN:(id)sender{
    [self.cv_handler calibrateColor:GREEN];

}

- (IBAction)calibRED:(id)sender{
    [self.cv_handler calibrateColor:RED];

}

- (IBAction)calibYELLOW:(id)sender{
    [self.cv_handler calibrateColor:YELLOW];
}

- (IBAction)calibWHITE:(id)sender{
    [self.cv_handler calibrateColor:WHITE];
}
- (IBAction)calibSMALL:(id)sender{
    [self.cv_handler calibrateSize:SMALL];
}

- (IBAction)calibMEDIUM:(id)sender{
    [self.cv_handler calibrateSize:MEDIUM];
}

- (IBAction)calibLARGE:(id)sender{
    [self.cv_handler calibrateSize:LARGE];
}

- (void) viewWillAppear:(BOOL)animated{
    if(!self.camera.running){
        [self.camera start];
    }
}

- (void) viewDidDisappear:(BOOL)animated{
    [self.camera stop];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initCamera

{
    self.camera = [[CvVideoCamera alloc] initWithParentView:self.camera_view];
    self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.camera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.camera.defaultFPS = 30;
    self.camera.grayscaleMode = NO;
    self.camera.delegate = self.cv_handler;
}

@end