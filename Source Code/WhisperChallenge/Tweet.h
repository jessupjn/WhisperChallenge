//
//  Tweet.h
//  WhisperChallenge
//
//  Created by Jack on 4/30/15.
//  Copyright (c) 2015 Jackson Jessup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface Tweet : NSObject

- (id)initWithDictionary:(NSDictionary *)dic;
- (id)initWithCoreObject:(NSManagedObject *)obj;

-(NSString *) getUserName;
-(NSString *) getUserHandle;
-(NSString *) getTweetText;
-(NSString *) getWhenText;
-(NSString *) getShortWhenText;
-(NSString *) getID;
-(NSString *) getImage;
-(NSDate *) getDate;
-(UIImage *) tweetImage;

@end
