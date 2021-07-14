//
//  MatchesViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/14/21.
//

#import "MatchesViewController.h"
#import "CommonQueries.h"


@interface MatchesViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *matchesCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *conversationsCollectionView;


@end

@implementation MatchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MatchingUsers(^(NSArray *_Nullable matchedUsers, NSError *_Nullable error){
        NSLog(@"%@", matchedUsers);
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

@end
