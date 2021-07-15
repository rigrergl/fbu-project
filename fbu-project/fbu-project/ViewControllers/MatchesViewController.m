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
@property (strong, nonatomic) NSArray *matchedUsers;
@property (strong, nonatomic) NSArray *matches;

//keep track of indexes that contain conversed versus unconversed matches (in matches array)
@property (strong, nonatomic) NSMutableArray *conversedMatchIndexes;
@property (strong, nonatomic) NSMutableArray *unconversedMatchesIndexes;

@end

@implementation MatchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    for (int i = 0; i < self.matches.count; i++) {
        Match *match = self.matches[i];
        if (match.hasConversationStarted) {
            [self.conversedMatchIndexes addObject: [NSNumber numberWithInt:i]];
        } else {
            [self.unconversedMatchesIndexes addObject:[NSNumber numberWithInt:i]];
        }
    }
}

#pragma mark - CollectionView methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
                          cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (collectionView == self.matchesCollectionView) {
        MatchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MatchCollectionViewCell" forIndexPath:indexPath];
        
        return cell;
    } else {
        ConversationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ConversationCollectionViewCell" forIndexPath:indexPath];
        
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int indexOfMatch;
    if (collectionView == self.conversationsCollectionView) {
        indexOfMatch = [self.conversedMatchIndexes[indexPath.item] intValue];
    } else {
        indexOfMatch = [self.unconversedMatchesIndexes[indexPath.item] intValue];
    }
    
    [self performSegueWithIdentifier:@"matchToChat" sender:self.matches[indexOfMatch]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.matchesCollectionView) {
        return CGSizeMake(60, 60);
    } else {
        return CGSizeMake(self.view.frame.size.width, 76);
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"matchToChat"]) {
        
        Match *user = (Match *) sender;
        ChatViewController *destinationController = [segue destinationViewController];
        destinationController.match = user;
        
    }
}

@end
