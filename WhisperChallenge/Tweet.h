//
//  Tweet.h
//  WhisperChallenge
//
//  Created by Jack on 4/30/15.
//  Copyright (c) 2015 Jackson Jessup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tweet : NSObject

- (id)initWithDictionary:(NSDictionary *)dic;

-(NSString *) getUserName;
-(NSString *) getUserHandle;
-(NSString *) getTweetText;
-(NSString *) getWhenText;
-(NSString *) getID;
-(NSString *) getImage;

@end
