//
//  AsciiEncoder.h
//  magnetReader
//
//  Created by Sam Royston on 3/1/14.
//  Copyright (c) 2014 Sam Royston. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AsciiDecoder : NSObject

@property (nonatomic,retain) NSString *stored_string;

- (NSString*)intArrayToStringAscii:(NSArray*) intArray;
- (NSString*)asciiCharForIntCode:(int) asciiCode;

@end
