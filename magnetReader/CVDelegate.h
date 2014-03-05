//
//  CVDelegate.h
//  magnetReader
//
//  Created by Sam Royston on 2/27/14.
//  Copyright (c) 2014 Sam Royston. All rights reserved.
//
#define RED 0
#define GREEN 1
#define BLUE 2
#define YELLOW 3
#define WHITE 4
#define SMALL 0
#define MEDIUM 1
#define LARGE 2
#define NO_CIRCLES_FOUND 178423931
#define MAX_BLYATT_SET 170859375
#import <stdlib.h>
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/cap_ios.h>
using namespace cv;
#import "opencv2/highgui/highgui.hpp"
#import "opencv2/objdetect/objdetect.hpp"
#import "opencv2/core/core.hpp"
#import "opencv2/ml/ml.hpp"

@interface CVDelegate : NSObject<CvVideoCameraDelegate>

@property (nonatomic, retain)  UIView *hud_one;
@property (nonatomic, retain)  UIView *hud_two;
@property (nonatomic, assign)  cv::Mat current_image;
@property (nonatomic, assign)  std::vector<cv::Vec3f> circles;
@property (nonatomic, assign)  cv::Mat avgCircles;
@property (nonatomic, retain)  UILabel *integerLabel;
@property (nonatomic, assign)  int perceived_integer_code;
@property (nonatomic, retain) NSMutableArray *circlesArray;
@property (nonatomic, retain) NSUserDefaults *cvSettings;

- (BOOL) calibrateColor: (int) color;
- (BOOL) calibrateSize: (int) size;
- (void) executeOnNewIntegerValue: (void (^)(int))completionBlock;

@end

