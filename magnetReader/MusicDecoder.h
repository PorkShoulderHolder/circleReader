//
//  MusicDecoder.h
//  magnetReader
//
//  Created by Sam Royston on 3/1/14.
//  Copyright (c) 2014 Sam Royston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SoundBankPlayer.h"
#import "NAMIDI.h"
#import "OpenALSupport.h"

@interface MusicDecoder : NSObject{
    AVAudioSession  *audioSession;
}
@property (nonatomic, strong) NAMIDI* midiHandler;
@property (nonatomic,retain)SoundBankPlayer *player;
- (void) handleInteger:(int)code;

@end
