//
//  ChatViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "ChatViewController.h"
#import "MessageCollectionViewCell.h"
#import <LoremIpsum/LoremIpsum.h>

@interface ChatViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *messages;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.messages = [[NSArray alloc] initWithObjects:@"First Message", @"Second Message", @"Third Message", nil];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chatCell" forIndexPath:indexPath];
    
    if (cell) {
        cell.contentLabel.text = [LoremIpsum sentence];//self.messages[indexPath.item];
        cell.wrappingViewWidth.constant = self.view.frame.size.width;
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messages.count;
}


@end
