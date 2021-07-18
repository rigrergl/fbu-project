//
//  AddLikedGenreViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/18/21.
//

#import "AddLikedGenreViewController.h"
#import "AddLikedGenreCollectionViewCell.h"
#import "APIManager.h"

@interface AddLikedGenreViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *_Nonnull collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *_Nonnull genreTitles;
@property (strong, nonatomic) NSArray *_Nonnull filteredGenreTitles;

@end

@implementation AddLikedGenreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchGenres];
    [self setupCollectionView];
    self.searchBar.delegate = self;
}

- (void)setupCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)fetchGenres {
    [APIManager fetchGenres:^(NSArray *_Nullable genres, NSError *_Nullable error){
        if (genres) {
            self.genreTitles = self.filteredGenreTitles = genres;
            [self.collectionView reloadData];
        }
    }];
}

- (IBAction)didTapCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CollectionView methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AddLikedGenreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddLikedGenreCollectionViewCell" forIndexPath:indexPath];
    
    if (cell) {
        cell.titleLabel.text = self.filteredGenreTitles[indexPath.item];    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredGenreTitles.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width, 50);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *genreTitle = self.filteredGenreTitles[indexPath.item];
    [LikedGenre postLikedGenre:genreTitle forUser:[PFUser currentUser] withCompletion:^(LikedGenre *newLikedGenre, NSError *error){
        if (self.didAddLikedGenre) {
            self.didAddLikedGenre(newLikedGenre);
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *genreTitle, NSDictionary *bindings) {
            return [genreTitle localizedCaseInsensitiveContainsString:searchText];
        }];
        self.filteredGenreTitles = [self.genreTitles filteredArrayUsingPredicate:predicate];
    }
    else {
        self.filteredGenreTitles = self.genreTitles;
    }
    
    [self.collectionView reloadData];
    
}

@end
