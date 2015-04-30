//
//  MainVC.h
//  WhisperChallenge
//
//  Created by Jack on 4/30/15.
//  Copyright (c) 2015 Jackson Jessup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tbvResults;
@property (weak, nonatomic) IBOutlet UIView *viwTyping;
@property (weak, nonatomic) IBOutlet UILabel *lblDisplayType;
@property (weak, nonatomic) IBOutlet UILabel *lblNoData;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loadingCst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblToTopCST;

-(IBAction)btnSavedTweets:(id)sender;

@end
