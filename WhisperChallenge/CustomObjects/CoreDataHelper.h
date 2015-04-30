//
//  CoreDataHelper.h
//  WhisperChallenge
//
//  Created by Jack on 4/30/15.
//  Copyright (c) 2015 Jackson Jessup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet.h"

@interface CoreDataHelper : NSObject

+ (instancetype)sharedHelper;

-(NSArray*) getSavedTweets;
-(void) saveTweet:(Tweet*)tweet;
-(void) removeTweet:(Tweet*)tweet;
-(BOOL) tweetIsSaved:(Tweet*)tweet;
@end
