//
//  AddArtistViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/16/21.
//

#import "AddArtistViewController.h"
#import "APIManager.h"
#import "FavoriteArtist.h"

@interface AddArtistViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end

@implementation AddArtistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetInput];
}

- (void)resetInput {
    self.searchTextField.text = @"";
    self.addButton.enabled = NO;
}

- (IBAction)searchTextDidChange:(UITextField *)sender {
    NSString *searchText = self.searchTextField.text;
    NSString *artistId = [APIManager formatArtistName:searchText];
    
    APIManager *apiManager = [APIManager new];
    [apiManager fetchArtist:artistId withCompletion:^(NSDictionary *_Nullable responseData, NSError *_Nullable error){
        FavoriteArtist *artist = [[FavoriteArtist alloc] initWithDictionary:responseData andId:artistId];
        
        if (responseData && artist) {
            self.addButton.enabled = YES;
        } else {
            self.addButton.enabled = NO;
        }
    }];
}


@end
