//
//  VoteAccumulator.h
//  magnetReader
//
//  Created by Sam Royston on 3/2/14.
//  Copyright (c) 2014 Sam Royston. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoteAccumulator : NSObject

@property (nonatomic,assign) int votesToWin;
/** use this property to define the minimum speed by which a candidate is chosen, with respect to the votesToWin property **/
@property (nonatomic,assign) float stringenceMultiplier;

- (id) initWithVoteThreshold:(int)thresh;
- (int) countVote:(int) interpretedIndex;
- (unsigned long) getNumberOfCandidates;

@end
