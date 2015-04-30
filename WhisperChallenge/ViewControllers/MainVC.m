//
//  MainVC.m
//  WhisperChallenge
//
//  Created by Jack on 4/30/15.
//  Copyright (c) 2015 Jackson Jessup. All rights reserved.
//

#import "MainVC.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import "TweetVC.h"
#import "Tweet.h"
#import "CoreDataHelper.h"

#define     TEXT_HOME_FEED          @"Home Feed:"
#define     TEXT_SEARCH_RESULTS     @"Search Results:"
#define     TEXT_SAVED_TWEETS     @"Bookmarked Tweets:"

@interface MainVC () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSString *prevSearch;
    NSMutableArray *tweets;
}

@end

@implementation MainVC

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Whisper Challenge"];

    // navbar stuff
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    // touch gesture added to "searching view"
    [self.viwTyping addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)]];
    
    tweets = [NSMutableArray new];
    [self.lblNoData setHidden:YES];
    
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if(!granted) {
            [self showError:@"Please allow Twitter access in:\nSettings -> Privacy -> Twitter."];
        } else {
            self.lblDisplayType.text = TEXT_HOME_FEED;
            [self loadTweets:self.searchBar.text];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.viwTyping setAlpha:0];
    [self.viwTyping setHidden:YES];
    [self setTitle:@"Whisper Challenge"];
    self.tblToTopCST.constant = -64;
    [self.view layoutIfNeeded];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self setTitle:@".."];
}

#pragma mark - Custom methods

-(IBAction)btnSavedTweets:(id)sender {
    prevSearch = nil;
    tweets = [[[CoreDataHelper sharedHelper] getSavedTweets] mutableCopy];
    [self.tbvResults reloadData];
    [self.lblNoData setHidden: tweets.count ];
    self.lblDisplayType.text = TEXT_SAVED_TWEETS;
}

// Loads tweets to be displayed.
-(void) loadTweets:(NSString *)searchQuery {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.lblNoData setHidden:YES];
    });
    [self displayLoadingView:YES];
    prevSearch = searchQuery;

    // Request twitter access via Accounts.framework
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            // Check if user has setup at least one Twitter account
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                NSString *urlString = @"";

                // if empty search, load ______ tweets
                // else, load for searched query
                if( searchQuery.length )
                    urlString = @"https://api.twitter.com/1.1/search/tweets.json";
                else
                    urlString = @"https://api.twitter.com/1.1/statuses/home_timeline.json";
                NSURL *url = [NSURL URLWithString:urlString];
                
                [self twitterMakeRequestWithAccount:twitterAccount Url:url Search:searchQuery.length];
            } else {
                [self showError:@"Please sign into Twitter via:\nSettings -> Twitter."];
            }
        } else {
            [self showError:@"Please allow Twitter access in:\nSettings -> Privacy -> Twitter."];
        }
    }];
}

-(void) twitterMakeRequestWithAccount:(ACAccount*)account Url:(NSURL*)url Search:(BOOL)isQuery {
    // Creating a request to get the info about a user on Twitter
    NSMutableDictionary *params = [NSMutableDictionary new];
    if( isQuery ) {
        [params setObject:self.searchBar.text forKey:@"q"];
    } else {
        
    }
    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                       requestMethod:SLRequestMethodGET
                                                                 URL:url
                                                          parameters:params];
    [twitterInfoRequest setAccount:account];
    
    // Making the request
    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        // Handle any errors
        if (error) {
            [self showError:error.localizedDescription];
            return;
        } else if( [urlResponse statusCode] > 500 ) {
            [self showError:@"Twitter was unable to be accessed..."];
            return;
        } else if( [urlResponse statusCode] > 400 ) {
            [self showError:@"Error when making request. Please try again..."];
            return;
        }
        
        [self displayLoadingView:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update display type
            self.lblDisplayType.text = isQuery ? TEXT_SEARCH_RESULTS : TEXT_HOME_FEED;
            
            // Handle response data
            if( responseData ) {
                NSError *error = nil;
                tweets = [NSMutableArray new];
                if(isQuery) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:kNilOptions
                                                                           error:&error];
                    if (error != nil) {
                        [self showError:@"Something went wrong!"];
                    }
                    else {
                        NSArray *tweetArray = [json objectForKey:@"statuses"];
                        for (NSDictionary *d in tweetArray)
                            [tweets addObject: [[Tweet alloc] initWithDictionary:d] ];
                    }
                } else {
                    NSArray *tweetArray = [NSJSONSerialization JSONObjectWithData:responseData
                                                                          options:kNilOptions
                                                                            error:&error];
                    for (NSDictionary *d in tweetArray)
                        [tweets addObject: [[Tweet alloc] initWithDictionary:d] ];
                }
                
                [self.lblNoData setHidden:(tweets.count > 0)];
                if( [self.tbvResults numberOfRowsInSection:0] > 0 )
                    [self.tbvResults scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                           atScrollPosition:UITableViewScrollPositionTop
                                                   animated:YES];
                [self.tbvResults reloadData];
            }
        });
    }];
}

// Shows/Hides the loading view.
-(void) displayLoadingView:(BOOL)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            self.loadingCst.constant = show ? 44 : 0;
            [self.view layoutIfNeeded];
        }];
    });
}

// Ends all editing in the view controller.
-(void) endEditing {
    [self.view endEditing:YES];
}

// Shows an error message with an "Okay" button.
-(void) showError:(NSString*)message {
    // Show an error message.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayLoadingView:NO];
        [[[UIAlertView alloc] initWithTitle:@"Whoops!"
                                    message:message
                                   delegate:self
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil]
         show];
        
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.destinationViewController isKindOfClass:[TweetVC class]] ) {
        TweetVC *vc = segue.destinationViewController;
        vc.tweet = (Tweet *)sender;
    }
}

#pragma mark - UISearchBar delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self endEditing];
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // show "typing" view
    [self.viwTyping setHidden:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [self.viwTyping setAlpha:0.3];
    }];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    // hide "typing" view
    [UIView animateWithDuration:0.25 animations:^{
        [self.viwTyping setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.viwTyping setHidden:YES];
    }];
    
    // Make sure search isn't the same as before.
    if( prevSearch == nil || ![self.searchBar.text isEqualToString:prevSearch] ) {
        [self loadTweets:self.searchBar.text];
    }
}

#pragma mark - UITableView delegate and datasource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tweets.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tweetCell"];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 0, 0)];
        [lbl setFont:[UIFont systemFontOfSize:12]];
        [lbl setTextColor:[UIColor lightGrayColor]];
        [lbl setTag:100];
        [cell.contentView addSubview:lbl];
        
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 22, cell.contentView.frame.size.width - 40, 55)];
        [lbl setFont:[UIFont systemFontOfSize:13]];
        [lbl setTextColor:[UIColor darkGrayColor]];
        [lbl setTag:101];
        [lbl setNumberOfLines:3];
        [cell.contentView addSubview:lbl];
        
        UIView *viw = [[UIView alloc] initWithFrame:CGRectMake(20, 79, [UIScreen mainScreen].bounds.size.width, 1)];
        [viw setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:viw];
    }
    
    Tweet *tweet = [tweets objectAtIndex:indexPath.row];

    UILabel *lbl = (UILabel*)[cell.contentView viewWithTag:100];
    lbl.text = [tweet getUserHandle];
    [lbl sizeToFit];
    
    lbl = (UILabel*)[cell.contentView viewWithTag:101];
    lbl.text = [tweet getTweetText];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:lbl.text
                                                                         attributes:@{ NSFontAttributeName: lbl.font }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){[UIScreen mainScreen].bounds.size.width-40, 55}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    CGRect labelFrame = lbl.frame;
    labelFrame.size.width = [UIScreen mainScreen].bounds.size.width-40;
    labelFrame.size.height = size.height;
    lbl.frame = labelFrame;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"SEGUE_SHOW_TWEET" sender:[tweets objectAtIndex:indexPath.row]];
}

@end
