//
//  ProfileViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/12/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "AuthenticationViewController.h"
#import "MediaPlayBackView.h"
#import "LikedGenreCollectionViewCell.h"
#import "LikedGenre.h"
#import "AddLikedGenreViewController.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *_Nonnull playbackContainerView;
@property (strong, nonatomic) MediaPlayBackView *_Nullable playbackView;
@property (strong, nonatomic) IBOutlet UICollectionView *_Nonnull likedGenresCollectionView;
@property (assign, nonatomic) BOOL canEditProfile;
@property (strong, nonatomic) NSMutableArray *_Nullable likedGenres;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchRecording];
    
    if(self.targetUser == nil) {
        self.targetUser = [PFUser currentUser];
        self.canEditProfile = YES;
    }
    
    [self setupCollectionView];
    [self fetchLikedGenres];
}

- (void)setupCollectionView {
    self.likedGenresCollectionView.delegate = self;
    self.likedGenresCollectionView.dataSource = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.playbackView) {
        [self.playbackView stopPlaying];
    }
}

- (void)fetchLikedGenres {
    PFQuery *likedGenreQuery = [PFQuery queryWithClassName:[LikedGenre parseClassName]];
    [likedGenreQuery whereKey:@"user" equalTo:self.targetUser];
    
    [likedGenreQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable likedGenres, NSError *error){
        if (!error && likedGenres) {
            self.likedGenres = likedGenres;
            [self.likedGenresCollectionView reloadData];
        }
    }];
}

- (void)fetchRecording {
    PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
    [userQuery includeKey:@"recording"];
    
    [userQuery getObjectInBackgroundWithId:[PFUser currentUser].objectId block:^(PFObject *_Nullable object, NSError *_Nullable error){

        if (object) {
            self.targetUser = (PFUser *)object;

            PFFileObject *recordingFile = self.targetUser[@"recording"];
            if(recordingFile == nil) {
                return;
            }

            
            [self addPlaybackView];
        }
    }];
}

- (void)addPlaybackView {
    PFFileObject *recordingFile = self.targetUser[@"recording"];
    if(recordingFile == nil) {
        return;
    }
    
    [recordingFile getDataInBackgroundWithBlock:^(NSData *_Nullable data, NSError *_Nullable error){
        if (data) {
            MediaPlayBackView *playbackView = [[MediaPlayBackView alloc]
                                               initWithFrame:CGRectMake(0, 0, self.playbackContainerView.frame.size.width, self.playbackContainerView.frame.size.height)
                                               andData:data];
            
            self.playbackView = playbackView;
            [self.playbackContainerView addSubview:playbackView];
        }
    }];
}

- (IBAction)didTapLogout:(UIBarButtonItem *)sender {
    SceneDelegate *sceneDelegate = (SceneDelegate *)[UIApplication sharedApplication].connectedScenes.allObjects[0].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthenticationViewController *userAuthenticationViewController = [storyboard instantiateViewControllerWithIdentifier:@"AuthenticationViewController"];
    sceneDelegate.window.rootViewController = userAuthenticationViewController;
    
    [PFUser logOutInBackground];
}

#pragma mark - CollectionView methods

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LikedGenreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LikedGenreCollectionViewCell" forIndexPath:indexPath];
    
    if (cell) {
        LikedGenre *genre = self.likedGenres[indexPath.item];
        [cell setCellWithTitle:genre.title canRemove:self.canEditProfile];
        cell.removeLikedGenre = ^(LikedGenreCollectionViewCell *_Nonnull cell){
            [self removeLikedGenre:cell];
        };
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.likedGenresCollectionView.frame.size.width, 50);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.likedGenres.count;
}

- (IBAction)addLikedGenre:(UIButton *)sender {
    [self performSegueWithIdentifier:@"profileToAddLikedGenre" sender:nil];
}

- (void)removeLikedGenre:(LikedGenreCollectionViewCell *_Nonnull)cell {
    long indexToRemove = [self.likedGenresCollectionView indexPathForCell:cell].item;
    LikedGenre *genreToRemove = self.likedGenres[indexToRemove];
    
    //remove corresponding genre from the database
    [LikedGenre deleteLikedGenre:genreToRemove withCompletion:^(BOOL succeeded, NSError *_Nullable error){}];
    
    //remove the cell from the local collection view
    [self.likedGenres removeObjectAtIndex:indexToRemove];
    [self.likedGenresCollectionView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"profileToAddLikedGenre"]) {
        AddLikedGenreViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.didAddLikedGenre = ^(LikedGenre *newLikedGenre){
            if (newLikedGenre != nil) {
                [self.likedGenres insertObject:newLikedGenre atIndex:0];
                [self.likedGenresCollectionView reloadData];
            }
        };
    }
}

@end
