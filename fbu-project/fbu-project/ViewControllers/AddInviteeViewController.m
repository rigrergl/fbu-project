//
//  AddInviteeViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "AddInviteeViewController.h"
#import "AddInviteeCollectionViewCell.h"
#import "CommonQueries.h"

@interface AddInviteeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *matchesCollectionView;
@property (strong, nonatomic) NSArray<PFUser *> *_Nonnull potentialInvitees;
@property (strong, nonatomic) NSArray<PFUser *> *_Nonnull filteredPotentialInvitees;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation AddInviteeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    [self fetchPotentialInvitees];
    self.searchBar.delegate = self;
}

- (void)fetchPotentialInvitees {
    MatchingUsers(^(NSArray *_Nullable matchedUsers, NSArray *_Nullable matches, NSError *_Nullable error){
        self.potentialInvitees = self.filteredPotentialInvitees = matchedUsers;
        [self.matchesCollectionView reloadData];
    });
}

- (IBAction)didTapCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CollectionView method

- (void)setupCollectionView {
    self.matchesCollectionView.delegate = self;
    self.matchesCollectionView.dataSource = self;
}

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString * const ADD_INVITEE_CELL_IDENTIFIER = @"AddInviteeCollectionViewCell";
    
    AddInviteeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ADD_INVITEE_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (cell) {
        [cell setCell:self.filteredPotentialInvitees[indexPath.item]];
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredPotentialInvitees.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static const int ADD_INVITEE_CELL_HEIGHT = 76;
    
    return CGSizeMake(self.view.frame.size.width, ADD_INVITEE_CELL_HEIGHT);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *selectedUser = self.filteredPotentialInvitees[indexPath.item];
    if (self.addInvitee) {
        self.addInvitee(selectedUser);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *_Nonnull user, NSDictionary *bindings) {
            return [user.username localizedCaseInsensitiveContainsString:searchText];
        }];
        self.filteredPotentialInvitees = [self.potentialInvitees filteredArrayUsingPredicate:predicate];
    }
    else {
        self.filteredPotentialInvitees = self.potentialInvitees;
    }
    
    [self.matchesCollectionView reloadData];
}



@end
