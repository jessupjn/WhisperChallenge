//
//  Tweet.m
//  WhisperChallenge
//
//  Created by Jack on 4/30/15.
//  Copyright (c) 2015 Jackson Jessup. All rights reserved.
//

#import "Tweet.h"

@interface Tweet () {
    NSDictionary *data;
}

@end

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dic {
    
    if ((self = [super init])) {
        data = [NSDictionary dictionaryWithDictionary:dic];
    }
    return self;
}

- (id)initWithCoreObject:(NSDictionary *)dic {
    
    if ((self = [super init])) {
        data = [NSDictionary dictionaryWithDictionary:dic];
    }
    return self;
}

-(NSString *) getUserName {
    NSDictionary *user = (NSDictionary*)[data objectForKey:@"user"];
    return (NSString*)[user objectForKey:@"screen_name"];
}

-(NSString *) getUserHandle {
    return [NSString stringWithFormat:@"@%@", [self getUserName]];
}

-(NSString *) getTweetText {
    return (NSString*)[data objectForKey:@"text"];
}

-(NSDate *) getDate {
    NSString *DateString = (NSString*)[data objectForKey:@"created_at"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss z yyyy"];
    return [dateFormatter dateFromString: DateString];
}

-(NSString *) getWhenText {
    NSDate *capturedStartDate = [self getDate];
    
    NSDate *date = [[NSDate alloc] init];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSString *returned = @"";
//    if( [components day] < 1 ) {
//        if( [components hour] < 1) {
//            if( [components minute] < 1 ) {
//                if( components.second < 2 )
//                    returned = [NSString stringWithFormat:@"%lu second ago", [components second]];
//                else
//                    returned = [NSString stringWithFormat:@"%lu seconds ago", [components second]];
//            } else if( components.minute < 2 )
//                returned = [NSString stringWithFormat:@"%lu minute ago", [components minute]];
//            else
//                returned = [NSString stringWithFormat:@"%lu minutes ago", [components minute]];
//        } else if( components.hour < 2 )
//            returned = [NSString stringWithFormat:@"%lu hour ago", [components hour]];
//        else
//            returned = [NSString stringWithFormat:@"%lu hours ago", [components hour]];
//    } else if( components.day < 2 )
//        returned = [NSString stringWithFormat:@"%lu day ago", [components day]];
//    else
//        returned = [NSString stringWithFormat:@"%lu days ago", [components day]];
    
    return returned;
}

-(NSString *) getImage {
    NSDictionary *entities = (NSDictionary*)[data objectForKey:@"entities"];
    NSArray *urls = (NSArray*)[entities objectForKey:@"media"];
    if( urls != nil && urls.count ) {
        NSDictionary *mediaObj = (NSDictionary *)[urls objectAtIndex:0];
        return (NSString*)[mediaObj objectForKey:@"media_url"];
    }
    return nil;
}

-(NSString *) getID {
    return (NSString*)[data objectForKey:@"id_str"];
}

-(BOOL)isEqual:(Tweet*)object {
    if( [[self getID] isEqualToString:[object getID]] ) return YES;
    return NO;
}
@end
