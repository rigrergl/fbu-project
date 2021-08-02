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

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray<NSString *> *_Nonnull entryTitles;
@property (strong, nonatomic) NSArray<NSString *> *_Nonnull filteredEntryTitles;

@end

static NSString * const ADD_LIKED_GENRE_CELL_IDENTIFIER = @"AddLikedGenreCollectionViewCell";
static NSInteger CELL_HEIGHT = 50;

@implementation AddLikedGenreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.didAddLikedGenre) {
        [self fetchGenres];
    } else {
        [self fetchInstrumentIdentifiers];
    }
    
    [self setupCollectionView];
    self.searchBar.delegate = self;
}

- (void)setupCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)fetchInstrumentIdentifiers {
    self.entryTitles = self.filteredEntryTitles = [LikedInstrument InstrumentNames];
    [self.collectionView reloadData];
}

- (void)fetchGenres {
    [APIManager fetchGenres:^(NSArray *_Nullable genres, NSError *_Nullable error){
        if (genres) {
            self.entryTitles = self.filteredEntryTitles = genres;
            [self.collectionView reloadData];
        }
    }];
}

- (IBAction)didTapCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CollectionView methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AddLikedGenreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ADD_LIKED_GENRE_CELL_IDENTIFIER
                                                                                      forIndexPath:indexPath];
    if (cell) {
        if (self.didAddLikedInstrument) {
            cell.titleLabel.text = self.filteredEntryTitles[indexPath.item];
        } else if (self.didAddLikedGenre) {
            cell.titleLabel.text = self.filteredEntryTitles[indexPath.item];
        }
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredEntryTitles.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width, CELL_HEIGHT);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedEntryTitle = self.filteredEntryTitles[indexPath.item];
    
    if (self.didAddLikedGenre) {
        [LikedGenre postLikedGenre:selectedEntryTitle
                           forUser:[PFUser currentUser]
                        completion:^(LikedGenre *_Nullable newLikedGenre, NSError *_Nullable error){
            self.didAddLikedGenre(newLikedGenre);
        }];
    } else if (self.didAddLikedInstrument) {
        [LikedInstrument postLikedInstrument:selectedEntryTitle
                                     forUser:[PFUser currentUser]
                                  completion:^(LikedInstrument *_Nullable newLikedInstrument, NSError *_Nullable error) {
            self.didAddLikedInstrument(newLikedInstrument);
        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *genreTitle, NSDictionary *bindings) {
            return [genreTitle localizedCaseInsensitiveContainsString:searchText];
        }];
        self.filteredEntryTitles = [self.entryTitles filteredArrayUsingPredicate:predicate];
    }
    else {
        self.filteredEntryTitles = self.entryTitles;
    }
    
    [self.collectionView reloadData];
}

@end
