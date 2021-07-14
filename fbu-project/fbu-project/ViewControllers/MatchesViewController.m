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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MatchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MatchCollectionViewCell" forIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.matchedUsers.count;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(CGRectGetWidth(collectionView.frame), (CGRectGetHeight(collectionView.frame)));
//}

@end
