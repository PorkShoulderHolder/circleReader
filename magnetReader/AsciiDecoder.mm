//
//  AsciiEncoder.m
//  magnetReader
//
//  Created by Sam Royston on 3/1/14.
//  Copyright (c) 2014 Sam Royston. All rights reserved.
//

#import "AsciiDecoder.h"


@implementation AsciiDecoder

- (NSString*)intArrayToStringAscii:(NSArray *)intArray{
    NSMutableString* output = [NSMutableString string];
    for (NSNumber *asciiCode in intArray){
        [output appendFormat:@"%c",[asciiCode intValue]];
    }
    return output;
}

- (NSString*)asciiCharForIntCode:(int) asciiCode{
    return [NSString stringWithFormat:@"%c",asciiCode];
}



@end
