//
//  CoreDataHelper.m
//  WhisperChallenge
//
//  Created by Jack on 4/30/15.
//  Copyright (c) 2015 Jackson Jessup. All rights reserved.
//
#import <CoreData/CoreData.h>
#import "CoreDataHelper.h"
#import "AppDelegate.h"

@implementation CoreDataHelper


// sharedHelper
// Function : creates static CoreDataHelper object (if needed) and returns it.
+ (instancetype)sharedHelper {
    static CoreDataHelper *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
} // sharedHelper



// getSavedTweets
// Function : gets a list of saved objects from CoreData
-(NSArray*) getSavedTweets {
    NSMutableArray *savedTweets = [NSMutableArray new];
    NSManagedObjectContext *context = [((AppDelegate*)[UIApplication sharedApplication].delegate) managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SavedTweetInfo" inManagedObjectContext:context];

    // build fetch request
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    [fetchRequest setEntity:entity];
    
    // make fetch request
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *info in fetchedObjects) {
        Tweet *t = [[Tweet alloc] initWithCoreObject:info];
        [savedTweets addObject:t];
    }
    
    return [NSArray arrayWithArray:savedTweets];
} // getSavedTweets



// saveTweet
// Function : saves the tweet object if it is not already in CoreData.
-(void) saveTweet:(Tweet*)tweet withImage:(UIImage*)image {
    
    if( ![self tweetIsSaved:tweet] ) {
        // create object to be saved
        NSManagedObjectContext *context = [((AppDelegate*)[UIApplication sharedApplication].delegate) managedObjectContext];
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
    } else
        NSLog(@"Whoops, tweet is already saved");
} // saveTweet



// removeTweet
// Function : if tweet object is in CoreData, remove it.
-(void) removeTweet:(Tweet*)tweet {
    
    if( [self tweetIsSaved:tweet] ) {
        NSManagedObjectContext *context = [((AppDelegate*)[UIApplication sharedApplication].delegate) managedObjectContext];

        // get object to be removed
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        fetch.entity = [NSEntityDescription entityForName:@"SavedTweetInfo" inManagedObjectContext:context];
        fetch.predicate = [NSPredicate predicateWithFormat:@"id == %@", [tweet getID]];
        
        // delete the object
        NSArray *array = [context executeFetchRequest:fetch error:nil];
        if( array.count )
            [context deleteObject:[array objectAtIndex:0]];
    }
    else
        NSLog(@"Whoops, tweet isnt saved");
} // removeTweet



// tweetIsSaved
// Function : returns if the tweet object is in CoreData.
-(BOOL) tweetIsSaved:(Tweet*)tweet{
    return [[self getSavedTweets] containsObject:tweet];
}

@end
