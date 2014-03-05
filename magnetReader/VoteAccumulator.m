//
//  VoteAccumulator.m
//  magnetReader
//
//  Created by Sam Royston on 3/2/14.
//  Copyright (c) 2014 Sam Royston. All rights reserved.
//

#import "VoteAccumulator.h"
#define MAX_BLYATT_SET 170859375

int _totalVotes = 0;
NSMutableDictionary *_ballot_box;

@implementation VoteAccumulator

- (id)initWithVoteThreshold:(int)thresh{
    self = [super init];
    if (self) {
        _ballot_box = [NSMutableDictionary dictionary];
        self.votesToWin = thresh;
        self.stringenceMultiplier = 2.0;
        _totalVotes = 0;
    }
    return self;
}

- (int) countVote:(int) interpretedIndex{
    NSString *key = [NSString stringWithFormat:@"%i",interpretedIndex];
    
    if ([_ballot_box objectForKey:key] && interpretedIndex < MAX_BLYATT_SET) {
        
        int currentVotes = [[_ballot_box objectForKey:key] intValue];
        currentVotes++;
        _totalVotes++;
        [_ballot_box setObject:[NSNumber numberWithInt:currentVotes] forKey:key];
        
        if (currentVotes >= self.votesToWin) {
            _totalVotes = 0;
            _ballot_box = [NSMutableDictionary dictionary];
            return interpretedIndex;
        }
        
        else if(_totalVotes > ( self.stringenceMultiplier * self.votesToWin ) || interpretedIndex >= MAX_BLYATT_SET){
            _totalVotes = 0;
            
            if([_ballot_box count] > 0)_ballot_box = [NSMutableDictionary dictionary];
        }
        
    }
    else{
        _totalVotes++;
        [_ballot_box setObject:[NSNumber numberWithInt:1] forKey:key];
    }
    return FALSE;
}

- (unsigned long) getNumberOfCandidates{
    return [_ballot_box count];
}

@end
