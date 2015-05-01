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

@interface TweetVC ()

@end

@implementation TweetVC

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
//    [self.view layoutIfNeeded];
    
    // if has image, load image
    NSString *urlStr = [self.tweet getImage];
    if( urlStr != nil ) {
        [self.imvTweetImage setHidden:NO];
//        self.imvTweetImage.image = image;
        NSURL *url = [NSURL URLWithString:urlStr];
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderContinueInBackground progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if(finished && error == nil) {
                [self.imvTweetImage setHidden:NO];
                [self.imvTweetImage setImage:image];
                self.imvHeightCst.constant = [UIScreen mainScreen].bounds.size.height - self.imvTweetImage.frame.origin.y - 10;
                [self.view layoutIfNeeded];
                [[CoreDataHelper sharedHelper] saveTweet:self.tweet withImage:image];
            } else {
                [self.imvTweetImage setHidden:YES];
            }
        }];
    }

}

-(IBAction)btnBookmarkAction:(id)sender {
//    if( [self.btnSave isSelected] )
//        [[CoreDataHelper sharedHelper] saveTweet:self.tweet];
//    else
//        [[CoreDataHelper sharedHelper] removeTweet:self.tweet];
    
    self.btnSave.selected = ![[CoreDataHelper sharedHelper] tweetIsSaved:self.tweet];
        
}

@end
