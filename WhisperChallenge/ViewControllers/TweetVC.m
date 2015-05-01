//
//  TweetVC.m
//  WhisperChallenge
//
//  Created by Jack on 4/30/15.
//  Copyright (c) 2015 Jackson Jessup. All rights reserved.
//

#import "TweetVC.h"
#import "CoreDataHelper.h"
#import "SDWebImageManager.h"
#import "UIImage+Additions.h"

#define         GREEN_COLOR     [UIColor colorWithRed:90.0/255 green:1 blue:195.0/255 alpha:1.0]
@interface TweetVC ()

@end

@implementation TweetVC

// viewDidLoad
// Function : set up the view before it is displayed
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:[NSString stringWithFormat:@"Tweet by %@", [self.tweet getUserHandle]]];
    
    // set handle text and resize
    self.lblHandle.text = [self.tweet getUserHandle];
    [self.lblHandle sizeToFit];
    
    // set WHEN text and resize
    self.lblWhen.text = [self.tweet getWhenText];
    [self.lblWhen sizeToFit];
    
    // set content text and resize
    self.lblContent.text = [self.tweet getTweetText];
    self.lblContent.numberOfLines = 6;
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.lblContent.text
                                                                         attributes:@{ NSFontAttributeName: self.lblContent.font }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){[UIScreen mainScreen].bounds.size.width-40, 100}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    CGRect labelFrame = self.lblContent.frame;
    labelFrame.size.width = [UIScreen mainScreen].bounds.size.width-40;
    labelFrame.size.height = size.height;
    self.lblContent.frame = labelFrame;
    
    
    // if has image, load image
    NSString *urlStr = [self.tweet getImage];
    if( [urlStr isEqualToString:@"has_image"] ) {
        [self.imvTweetImage setHidden:NO];
        [self.imvTweetImage setImage:[self.tweet tweetImage]];
    } else if( urlStr != nil ) {
        [self.imvTweetImage setHidden:NO];
        NSURL *url = [NSURL URLWithString:urlStr];
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderContinueInBackground progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if(finished && error == nil) {
                [self.imvTweetImage setHidden:NO];
                [self.imvTweetImage setImage:image];
            } else {
                [self.imvTweetImage setHidden:YES];
            }
        }];
    }
    self.view.frame = self.view.frame;
    self.imvHeightCst.constant = [UIScreen mainScreen].bounds.size.height - self.imvTweetImage.frame.origin.y - 50;
    [self.imvTweetImage layoutIfNeeded];
    [self.view layoutIfNeeded];
    
    
    // customize the save button
    [self.btnSave setImage:[[UIImage imageNamed:@"Bookmark"] changeImageColor:[UIColor blackColor]] forState:UIControlStateNormal];
    [self.btnSave setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [self.btnSave setBackgroundImage:[UIImage imageWithColor:GREEN_COLOR] forState:UIControlStateHighlighted];
    [self.btnSave setBackgroundImage:[UIImage imageWithColor:GREEN_COLOR] forState:UIControlStateSelected];
    self.btnSave.selected = [[CoreDataHelper sharedHelper] tweetIsSaved:self.tweet];
    [self.btnSave.layer setCornerRadius:6];
    [self.btnSave setClipsToBounds:YES];
    
} // viewDidLoad



// btnBookmarkAction
// Function : user hits the bookmark button
-(IBAction)btnBookmarkAction:(id)sender {
    if( ![self.btnSave isSelected] )
        [[CoreDataHelper sharedHelper] saveTweet:self.tweet withImage:self.imvTweetImage.image];
    else
        [[CoreDataHelper sharedHelper] removeTweet:self.tweet];
    
    self.btnSave.selected = [[CoreDataHelper sharedHelper] tweetIsSaved:self.tweet];
}

@end
