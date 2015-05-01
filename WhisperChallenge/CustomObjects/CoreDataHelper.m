//
//  CoreDataHelper.m
//  WhisperChallenge
//
//  Created by Jack on 4/30/15.
//  Copyright (c) 2015 Jackson Jessup. All rights reserved.
//
#import <CoreData/CoreData.h>
#import "CoreDataHelper.h"

@interface CoreDataHelper ()
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@end

@implementation CoreDataHelper

//http://www.raywenderlich.com/934/core-data-tutorial-for-ios-getting-started

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
-(void) saveTweet:(Tweet*)tweet withImage:(UIImage*)image{
    
    // create object to be saved
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *tweetInfo = [NSEntityDescription insertNewObjectForEntityForName:@"SavedTweetInfo" inManagedObjectContext:context];
    
    // set object's data
    [tweetInfo setValue:[tweet getUserName] forKey:@"user"];
    [tweetInfo setValue:[tweet getTweetText] forKey:@"text"];
    [tweetInfo setValue:[tweet getID] forKey:@"id"];
    [tweetInfo setValue:[tweet getDate] forKey:@"date"];
    if(image)
        [tweetInfo setValue:UIImagePNGRepresentation(image) forKey:@"image"];
    
    // save the object
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
}

#warning TODO:
-(void) removeTweet:(Tweet*)tweet{
}

-(BOOL) tweetIsSaved:(Tweet*)tweet{
    return [[self getSavedTweets] containsObject:tweet];
}

@end
