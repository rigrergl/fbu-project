//
//  MatchesViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "MatchesViewController.h"
#import "CommonQueries.h"
#import "MatchCollectionViewCell.h"
#import "ConversationCollectionViewCell.h"
#import "ChatViewController.h"
#import <Parse/Parse.h>

@interface MatchesViewController () <UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *matchesCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *conversationsCollectionView;
@property (strong, nonatomic) NSArray *_Nullable matchedUsers;
@property (strong, nonatomic) NSArray *_Nullable matches;

//keep track of indexes that contain conversed versus unconversed matches (in matches array)
@property (strong, nonatomic) NSMutableArray *_Nullable conversedMatchIndexes;
@property (strong, nonatomic) NSMutableArray *_Nullable unconversedMatchesIndexes;

@end

static NSString * const MATCH_TO_CHAT_SEGUE_IDENTIFIER = @"matchToChat";
static NSString * const MATCH_CELL_IDENTIFIER = @"MatchCollectionViewCell";
static NSString * const CONVERSATION_CELL_IDENTIFIER = @"ConversationCollectionViewCell";
static const NSInteger MATCHES_COLLECTION_VIEW_CELL_DIMENSIONS = 60;
static const NSInteger CONVERSATIONS_COLLECTION_CELL_HEIGHT = 76;

@implementation MatchesViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadMatches];
}

- (void)loadMatches {
    UICollectionViewFlowLayout *flowLayout = self.matchesCollectionView.collectionViewLayout;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    self.matchesCollectionView.delegate = self;
    self.matchesCollectionView.dataSource = self;
    self.conversationsCollectionView.dataSource = self;
    self.conversationsCollectionView.delegate = self;
    
    MatchingUsers(^(NSArray *_Nullable matchedUsers,NSArray *_Nullable matches, NSError *_Nullable error){
        self.matchedUsers = matchedUsers;
        self.matches  = matches;
        
        [self fillInIndexArrays];
        
        [self.matchesCollectionView reloadData];
        [self.conversationsCollectionView reloadData];
    });
}

- (void)fillInIndexArrays {
    self.unconversedMatchesIndexes = [[NSMutableArray alloc] init];
    self.conversedMatchIndexes = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < self.matches.count; i++) {
        Match *match = self.matches[i];
        if (match.hasConversationStarted) {
            [self.conversedMatchIndexes addObject: @(i)];
        } else {
            [self.unconversedMatchesIndexes addObject:@(i)];
        }
    }
}

#pragma mark - CollectionView methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
                          cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (collectionView == self.matchesCollectionView) {
        MatchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MATCH_CELL_IDENTIFIER forIndexPath:indexPath];
        
        NSInteger indexInFullArray = [self.unconversedMatchesIndexes[indexPath.item] intValue];
        [cell setCellWithUser:self.matchedUsers[indexInFullArray]];
        
        return cell;
    } else {
        ConversationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CONVERSATION_CELL_IDENTIFIER forIndexPath:indexPath];
        
        NSInteger indexInFullArray = [self.conversedMatchIndexes[indexPath.item] intValue];
        Match *match = self.matches[indexInFullArray];
        PFUser *user = self.matchedUsers[indexInFullArray];
        
        [cell setCellWithUser:user andMatch:match];
        
        return cell;
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.matchesCollectionView) {
        return self.unconversedMatchesIndexes.count;
    } else {
        return self.conversedMatchIndexes.count;
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger indexOfMatch;
    if (collectionView == self.conversationsCollectionView) {
        indexOfMatch = [self.conversedMatchIndexes[indexPath.item] intValue];
    } else {
        indexOfMatch = [self.unconversedMatchesIndexes[indexPath.item] intValue];
    }
    
    [self performSegueWithIdentifier:MATCH_TO_CHAT_SEGUE_IDENTIFIER sender:self.matches[indexOfMatch]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.matchesCollectionView) {
        return CGSizeMake(MATCHES_COLLECTION_VIEW_CELL_DIMENSIONS, MATCHES_COLLECTION_VIEW_CELL_DIMENSIONS);
    } else {
        return CGSizeMake(self.view.frame.size.width, CONVERSATIONS_COLLECTION_CELL_HEIGHT);
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:MATCH_TO_CHAT_SEGUE_IDENTIFIER]) {
        
        Match *user = (Match *) sender;
        ChatViewController *destinationController = [segue destinationViewController];
        destinationController.match = user;
        
    }
}

@end
