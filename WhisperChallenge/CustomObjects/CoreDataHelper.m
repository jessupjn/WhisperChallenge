//
//  CoreDataHelper.m
//  WhisperChallenge
//
//  Created by Jack on 4/30/15.
//  Copyright (c) 2015 Jackson Jessup. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

+ (instancetype)sharedHelper {
    static CoreDataHelper *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

#warning TODO:
-(NSArray*) getSavedTweets {
    return [NSArray new];
}

#warning TODO:
-(void) saveTweet:(Tweet*)tweet{
}

#warning TODO:
-(void) removeTweet:(Tweet*)tweet{
}

-(BOOL) tweetIsSaved:(Tweet*)tweet{
    return [[self getSavedTweets] containsObject:tweet];
}

@end
