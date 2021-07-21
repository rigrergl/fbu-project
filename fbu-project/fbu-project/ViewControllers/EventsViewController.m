//
//  EventsViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "EventsViewController.h"
#import "EventCollectionViewCell.h"

@interface EventsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *attendingCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *invitedCollectionView;

@end

@implementation EventsViewController

static NSString * const EVENT_CELL_IDENTIFIER = @"EventCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionViews];
}

- (void)setupCollectionViews {
    self.attendingCollectionView.delegate = self;
    self.attendingCollectionView.dataSource = self;
    self.invitedCollectionView.delegate = self;
    self.invitedCollectionView.dataSource = self;
}

# pragma mark  - CollectionView methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EVENT_CELL_IDENTIFIER forIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //TODO: use backing arrays instead
    return 20;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static const int EVENT_CELL_WIDTH = 200;
    
    if (collectionView == self.attendingCollectionView) {
        return CGSizeMake(EVENT_CELL_WIDTH, self.attendingCollectionView.frame.size.height);
    } else {
        return CGSizeMake(EVENT_CELL_WIDTH, self.invitedCollectionView.frame.size.height);
    }
}


@end
