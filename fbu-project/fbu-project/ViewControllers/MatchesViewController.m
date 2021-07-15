//
//  MatchesViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "MatchesViewController.h"
#import "CommonQueries.h"
#import "MatchCollectionViewCell.h"


@interface MatchesViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *matchesCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *conversationsCollectionView;
@property (strong, nonatomic) NSArray *matchedUsers;

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
    
    MatchingUsers(^(NSArray *_Nullable matchedUsers, NSError *_Nullable error){
        self.matchedUsers = matchedUsers;
        [self.matchesCollectionView reloadData];
    });
}

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MatchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MatchCollectionViewCell" forIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.matchedUsers.count;
}

@end
