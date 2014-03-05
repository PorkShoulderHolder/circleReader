//
//  CVDelegate.m
//  magnetReader
//
//  Created by Sam Royston on 2/27/14.
//  Copyright (c) 2014 Sam Royston. All rights reserved.
//

#import "CVDelegate.h"
#include "math.h"
#import "VoteAccumulator.h"
double time_counter = 0;


@implementation CVDelegate

cv::Scalar red(255,0,0);
cv::Scalar green(0,255,0);
cv::Scalar blue(0,0,255);
cv::Scalar yellow(0,255,255);
cv::Scalar white(255,255,255);
std::vector<cv::Scalar> colors = {red,green,blue,yellow,white};
std::vector<float> sizes = {50,100,150};
VoteAccumulator *voteAccumulator = [[VoteAccumulator alloc] initWithVoteThreshold:14];


- (id)init{
    self = [super init];
    if(self){
        cv::Vec3f top(0,0,0);
        cv::Vec3f bottom(0,0,0);
        std::vector<cv::Vec3f> avgCircles = {top, bottom};
        self.circlesArray = [NSMutableArray array];
        [self loadUserDefaults];
        //self.avgCircles = [self circlesVectorToMat:avgCircles];
    }
    return self;
}

- (void) processImage:(cv::Mat &)image{
    self.current_image = image.clone();
    cv::Mat slice = [self getMatSlice:image];
    self.circles = [self getCirclesFromImage:slice];
    
    for( size_t i = 0; i < MIN(2, self.circles.size()); i++ )
    {
        cv::Scalar color = [self getColorInCircle:self.circles[i] FromImage:image];
        int color_class = [self classifyColorNaive:color];
        int size_class = [self classifySizeNaive:self.circles[i][2]];
        UIView *hud;
        // single blyatt
        if( self.circles.size() == 1){
            hud = self.hud_one;
        }
        // most significant blyatt
        else if (self.circles[0][1] > self.circles[1][1]) {
            hud = self.hud_one;
            
        }
        // least significant blyatt
        else{
            hud = self.hud_two;
        }
        switch (color_class) {
            case RED:
                if(hud.backgroundColor != [UIColor redColor])
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        hud.backgroundColor =  [UIColor redColor];
                    });
                break;
            case GREEN:
                if(hud.backgroundColor != [UIColor greenColor])
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        hud.backgroundColor =  [UIColor greenColor];
                    });
                break;
            case BLUE:
                if(hud.backgroundColor != [UIColor blueColor])
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        hud.backgroundColor =  [UIColor blueColor];
                    });
                break;
            case YELLOW:
                if(hud.backgroundColor != [UIColor yellowColor])
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        hud.backgroundColor =  [UIColor yellowColor];
                    });
                break;
            case WHITE:
                if(hud.backgroundColor != [UIColor whiteColor])
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        hud.backgroundColor =  [UIColor whiteColor];
                    });
            default:
                break;
        }
        switch (size_class) {
            case SMALL:
                break;
            case MEDIUM:
                break;
            case LARGE:
                break;
            default:
                break;
        }
        

    }
    int percievedInt = [self convertCirclesToInt:self.circles];
    int decision = [voteAccumulator countVote:percievedInt];
    if(decision){
        time_counter = CACurrentMediaTime();
        self.perceived_integer_code = decision;
        if (self.integerLabel) {
            NSDictionary *eventInfo = @{@"perceived_integer": [NSNumber numberWithInt:self.perceived_integer_code], @"circles_visible": [NSNumber numberWithInteger:self.circles.size()]};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"INTEGER_UPDATE" object:self userInfo:eventInfo];
        }
    }
    else if(self.circles.size() == 0){
        double timeSinceUpdate = CACurrentMediaTime() - time_counter;
        if (self.integerLabel && timeSinceUpdate > 0.33) {
            NSDictionary *eventInfo = @{@"perceived_integer": [NSNumber numberWithInt:0], @"circles_visible": [NSNumber numberWithInteger:self.circles.size()]};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"INTEGER_UPDATE" object:self userInfo:eventInfo];
        }
    }
    
    [self paintCircles:self.circles FromSlice:slice on:image];
}

- (int) convertCirclesToInt:(std::vector<cv::Vec3f>) input{
    
    int output = 0;
    
    //sort by height
    std::sort(input.begin(), input.end(), circleHeightComparator);
    
    //how much data is stored in each circle?
    int blyattSize = (int)colors.size() * (int)sizes.size();
    for( int i = 0; i < input.size(); i++){
        cv::Scalar color = [self getColorInCircle:input[i] FromImage:self.current_image];
        int color_class = [self classifyColorNaive:color];
        int size_class = [self classifySizeNaive:input[i][2]];
        int digitValue = (color_class * (int)sizes.size()) + size_class;
        output += pow(blyattSize,(int)input.size() - (i + 1)) * digitValue;
        
    }
    
    return input.size() ? output : NO_CIRCLES_FOUND;
}

- (std::vector<cv::Vec3f>) circlesMatToVector :(cv::Mat)input{
    std::vector<cv::Vec3f> circles;
    for(int i = 0; i < input.rows; i++){
        float *r = input.ptr<float>(i);
        cv::Vec3f circle(*r, (*r + input.cols));
        circles.push_back(circle);
    }
    return circles;
}

- (cv::Mat) circlesVectorToMat :(std::vector<cv::Vec3f>) input{
    cv::Mat output((int)input.size(), 3, CV_32F);
    for(int i = 0; i < output.rows; i++)
        for(int j = 0; j < output.cols; j++)
            output.at<float>(i, j) = input.at(i)[j];
    return output;
}

- (std::vector<cv::Vec3f>) getCirclesFromImage: (cv::Mat) input{
    cv::Mat gray;
    cvtColor(input, gray, CV_BGR2GRAY);
    
    // smooth it
    cv::GaussianBlur( gray, gray, cv::Size(5, 5), 2, 2 );
    
    std::vector<cv::Vec3f> circles;
    
    //detect optimal circles using hough's algo
    cv::HoughCircles(gray, circles, CV_HOUGH_GRADIENT,2, gray.rows/4, 100, 60 );
    for( size_t i = 0; i < circles.size(); i++ )
    {
        circles[i][0] += input.cols;
    }

    return circles;
}

- (BOOL)calibrateColor:(int) color{
    
    if(self.circles.size() != 1){
        return NO;
    }
    else{
        cv::Scalar perceived_color = [self getColorInCircle:self.circles[0] FromImage:self.current_image];
        colors[color] = perceived_color;
        [self saveUserDefaults];
        return YES;
    }
}

- (BOOL)calibrateSize:(int) size{
    if(self.circles.size() != 1){
        return NO;
    }
    else{
        float perceived_size = self.circles[0][2];
        sizes[size] = perceived_size;
        [self saveUserDefaults];
        return YES;
    }
}

- (void) paintCircles:(std::vector<cv::Vec3f>)circles FromSlice:(cv::Mat)input on:(cv::Mat)output{
    
    for( size_t i = 0; i < circles.size(); i++ )
    {
        cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
        int radius = cvRound(circles[i][2]);
        // draw the circle center
        cv::circle( output, center, 3, Scalar(0,255,0), -1, 8, 0 );
        // draw the circle outline
        cv::circle( output, center, radius, Scalar(0,0,255), 3, 8, 0 );
    }
}

- (void) processCircles:(std::vector<cv::Vec3f>) circles{
    
}

- (cv::Scalar) getColorInCircle:(cv::Vec3f)circle FromImage:(cv::Mat)image{
    
    cv::Scalar color;
    cv::Rect inscribedSquare;
    inscribedSquare.x = MAX(0,MIN(circle[0] - (1.41421356237 / 2) * circle[2], image.cols));
    inscribedSquare.y = MIN(image.rows, MAX(circle[1] - (1.41421356237 / 2) * circle[2], 0));
    inscribedSquare.width = MIN(1.41421356237 * circle[2], image.cols - inscribedSquare.x);
    inscribedSquare.height = MIN(1.41421356237 * circle[2], image.rows - inscribedSquare.y);
    cv::Mat miniMat = image(inscribedSquare);
    color = cv::mean(miniMat);
    return color;
}


- (int)classifyColor:(cv::Scalar) color{
    cv::SVMParams params;
    params.svm_type = CvSVM::C_SVC;
    params.kernel_type = CvSVM::RBF;
    params.term_crit = cv::TermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
    
    CvSVM svm;
    return 1;
}

//color distance
float distance(cv::Scalar a, cv::Scalar b){
    return sqrt((a[0] - b[0])*(a[0] - b[0]) + (a[1] - b[1])*(a[1] - b[1]) + (a[2] - b[2]) * (a[2] - b[2]));
}


// circle distance
float distance(cv::Vec3f a, cv::Vec3f b){
    return sqrt((a[0] - b[0])*(a[0] - b[0]) + (a[1] - b[1])*(a[1] - b[1]));
}

float distance(float a, float b){
    return abs(a - b);
}

- (int)classifyColorNaive:(cv::Scalar) color{
    float d = 1000000;
    int k = 0;
    cv::Scalar colorDecision;
    for (int i = 0; i < colors.size(); i++) {
        if (d > distance(colors[i], color)) {
            d = distance(colors[i], color);
            colorDecision = colors[i];
            k = i;
        }
    }
    return k;
}

bool circleHeightComparator (cv::Vec3f a, cv::Vec3f b){
    return a[1] < b[1];
}

- (int)classifySizeNaive:(float) size{
    float d = 1000000;
    int k = 0;
    for (int i = 0; i < sizes.size(); i++) {
        if (d > distance(sizes[i], size)) {
            d = distance(sizes[i], size);
            k = i;
        }
    }
    return k;
}

-(void) saveUserDefaults{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    for (int i = 0; i < colors.size(); i++) {
        NSDictionary *colorInfo = [self NSDictionaryForCvScalar:colors[i]];
        [defaults setObject:colorInfo forKey:[NSString stringWithFormat:@"color_%i",i]];
    }
    for (int i = 0; i < sizes.size(); i++) {
        [defaults setObject:[NSNumber numberWithInt:sizes[i]] forKey:[NSString stringWithFormat:@"size_%i",i]];
    }

    [defaults synchronize];
}

-(void) loadUserDefaults{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    for (int i = 0; i < colors.size(); i++) {
        if ([defaults objectForKey:[NSString stringWithFormat:@"color_%i",i]]) {
            NSDictionary* colorInfo = [defaults objectForKey:[NSString stringWithFormat:@"color_%i",i]];
            colors[i] = [self cvScalarFromNSDictionary:colorInfo];
        }
    }
    for (int i = 0; i < sizes.size(); i++) {
        if ([defaults objectForKey:[NSString stringWithFormat:@"size_%i",i]]) {
            sizes[i] = [[defaults objectForKey:[NSString stringWithFormat:@"size_%i",i]] floatValue];
        }
    }
    NSLog(@"%f, %f", colors[0][0], red[0]);
    
    [defaults synchronize];
}

- (NSDictionary*) NSDictionaryForCvScalar:(cv::Scalar) scalar{
    NSDictionary *dictionary = @{@"red": [NSNumber numberWithInt:scalar[0]], @"green": [NSNumber numberWithInt:scalar[1]], @"blue": [NSNumber numberWithInt:scalar[2]]};
    return dictionary;
}

- (cv::Scalar) cvScalarFromNSDictionary:(NSDictionary*)dictionary{
    
    int r = [dictionary[@"red"] intValue];
    int g = [dictionary[@"green"] intValue];
    int b = [dictionary[@"blue"] intValue];
    cv::Scalar color = {r,g,b};
    return color;
}

- (cv::Mat) getMatSlice:(cv::Mat) input{
    
    // define slice
    cv::Rect rect;
    rect.x = input.cols / 3;
    rect.y = 0;
    rect.height = input.rows;
    rect.width = input.cols / 3;
    
    cv::Mat slice = input(rect);
    return slice;
}



@end
