//
//  Tweet.m
//  WhisperChallenge
//
//  Created by Jack on 4/30/15.
//  Copyright (c) 2015 Jackson Jessup. All rights reserved.
//

#import "Tweet.h"

#define         DATE_FORMAT         @"EEE MMM dd HH:mm:ss z yyyy"

@interface Tweet () {
    NSDictionary *data;
    UIImage *tweetImage;
}

@end

@implementation Tweet



// initWithDictionary
// Function : Initializes a Tweet object using a NSDictionary
- (id)initWithDictionary:(NSDictionary *)dic {
    
    if ((self = [super init])) {
        data = [NSDictionary dictionaryWithDictionary:dic];
    }
    return self;
} // initWithDictionary



// initWithCoreObject
// Function : initializes a Tweet object using an object from CoreData
- (id)initWithCoreObject:(NSManagedObject *)obj {
    
    if ((self = [super init])) {
        NSMutableDictionary *dicBuilder = [NSMutableDictionary new];
        
        // username
        NSString *helpStr = [obj valueForKey:@"user"];
        NSDictionary *user = [[NSDictionary alloc] initWithObjects:@[helpStr] forKeys:@[@"screen_name"]];
        [dicBuilder setValue:user forKey:@"user"];
        
        // tweet text
        helpStr = [obj valueForKey:@"text"];
        [dicBuilder setValue:helpStr forKey:@"text"];
        
        // tweet date
        NSDate *date = (NSDate*)[obj valueForKey:@"date"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:DATE_FORMAT];
        helpStr = [dateFormatter stringFromDate:date];
        [dicBuilder setValue:helpStr forKey:@"created_at"];
        
        // tweet id
        helpStr = [obj valueForKey:@"id"];
        [dicBuilder setValue:helpStr forKey:@"id_str"];
        
        // tweet image (if there is one)
        NSData *imgData = (NSData*)[obj valueForKey:@"image"];
        if( imgData )
            tweetImage = [[UIImage alloc] initWithData:imgData];
        
        data = [[NSDictionary alloc] initWithDictionary:dicBuilder];
    }
    return self;
} // initWithCoreObject



// getUserName
// Function : returns the username of the tweeter
-(NSString *) getUserName {
    NSDictionary *user = (NSDictionary*)[data objectForKey:@"user"];
    return (NSString*)[user objectForKey:@"screen_name"];
}



// getUserHandle
// Function : returns the handle of the tweeter
-(NSString *) getUserHandle {
    return [NSString stringWithFormat:@"@%@", [self getUserName]];
}



// getTweetText
// Function : returns the text from the tweet
-(NSString *) getTweetText {
    return (NSString*)[data objectForKey:@"text"];
}



// getDate
// Function : returns the date object from the tweet as an NSDate
-(NSDate *) getDate {
    NSString *DateString = (NSString*)[data objectForKey:@"created_at"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_FORMAT];
    return [dateFormatter dateFromString: DateString];
}



// getWhenText
// Function : returns text detailing how long ago the tweet was posted
-(NSString *) getWhenText {
    NSDate *tweetDate = [self getDate];
    NSDate *date = [[NSDate alloc] init];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [gregorianCalendar components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:tweetDate toDate:date options:0];
    NSString *returned = @"";
    if( [components day] < 1 ) {
        if( [components hour] < 1) {
            if( [components minute] < 1 ) {
                if( components.second < 2 )
                    returned = [NSString stringWithFormat:@"%lu second ago", [components second]];
                else
                    returned = [NSString stringWithFormat:@"%lu seconds ago", [components second]];
            } else if( components.minute < 2 )
                returned = [NSString stringWithFormat:@"%lu minute ago", [components minute]];
            else
                returned = [NSString stringWithFormat:@"%lu minutes ago", [components minute]];
        } else if( components.hour < 2 )
            returned = [NSString stringWithFormat:@"%lu hour ago", [components hour]];
        else
            returned = [NSString stringWithFormat:@"%lu hours ago", [components hour]];
    } else if( components.day < 2 )
        returned = [NSString stringWithFormat:@"%lu day ago", [components day]];
    else
        returned = [NSString stringWithFormat:@"%lu days ago", [components day]];
    
    return returned;
} // getWhenText



// getShortWhenText
// Function : returns (shortened) text detailing how long ago the tweet was posted
-(NSString *) getShortWhenText {
    NSDate *tweetDate = [self getDate];
    NSDate *date = [[NSDate alloc] init];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [gregorianCalendar components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:tweetDate toDate:date options:0];
    NSString *returned = @"";
    if( [components day] < 1 ) {
        if( [components hour] < 1) {
            if( [components minute] < 1 )
                returned = [NSString stringWithFormat:@"%lus", [components second]];
            else
                returned = [NSString stringWithFormat:@"%lum", [components minute]];
        } else
            returned = [NSString stringWithFormat:@"%luh", [components hour]];
    } else
        returned = [NSString stringWithFormat:@"%lud", [components day]];
    
    return returned;
} // getShortWhenText



// getImage
// Function : returns url of the tweets image media if it has one.
-(NSString *) getImage {
    if( tweetImage != nil )
        return @"has_image";
    
    NSDictionary *entities = (NSDictionary*)[data objectForKey:@"entities"];
    NSArray *urls = (NSArray*)[entities objectForKey:@"media"];
    if( urls != nil && urls.count ) {
        NSDictionary *mediaObj = (NSDictionary *)[urls objectAtIndex:0];
        return (NSString*)[mediaObj objectForKey:@"media_url"];
    }
    return nil;
}



// tweetImage
// Function : returns tweetImage property
-(UIImage *) tweetImage {
    return tweetImage;
}



// getID
// Function : returns the ID value of the tweet
-(NSString *) getID {
    return (NSString*)[data objectForKey:@"id_str"];
}



// isEqual
// Function : checks equality with other Tweet object.
-(BOOL)isEqual:(Tweet*)object {
    if( [[self getID] isEqualToString:[object getID]] ) return YES;
    return NO;
}
@end
