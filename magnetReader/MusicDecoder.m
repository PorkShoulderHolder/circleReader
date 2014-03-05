//
//  MusicDecoder.m
//  magnetReader
//
//  Created by Sam Royston on 3/1/14.
//  Copyright (c) 2014 Sam Royston. All rights reserved.
//

#import "MusicDecoder.h"

@implementation MusicDecoder

- (id)init{
    self = [super init];
    if (self){
        self.player = [[SoundBankPlayer alloc] init];
        [self.player setSoundBank:@"piano"];
        audioSession = [AVAudioSession sharedInstance];
        NSError *err = nil;
        self.midiHandler = [[NAMIDI alloc] init];
        [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        
    }
    
    return self;
}

- (void)handleInteger:(int)code{
    if(code < 15){
        [self.player noteOn:(52 + code) gain:0.4f];
    }
    else if (code < 225){
        [self handleInteger15:code];
    }
    else if(code < 225 * 15){
        [self handleInteger225:code];
    }
}

- (void)handleInteger15:(int)code{
    [self.player queueNote:(52 + code/15) gain:0.4f];
    [self.player queueNote:(40 + code%15) gain:0.4f];
    [self.player playQueuedNotes];
}

- (void)handleInteger225:(int)code{
    [self.player queueNote:(40 + code/225) gain:0.4f];
    [self.player queueNote:(52 + (code%225) / 15) gain:0.4f];
    [self.player queueNote:(40 + code%15) gain:0.4f];
    [self.player playQueuedNotes];
}

@end
