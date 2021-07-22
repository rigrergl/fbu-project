//
//  NewEventViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "NewEventViewController.h"
#import "InviteeCollectionViewCell.h"
#import "DictionaryConstants.h"
#import "AddInviteeViewController.h"
#import "CommonFunctions.h"
#import <Parse/Parse.h>

@interface NewEventViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *addInviteeButton;
@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *eventPictureView;
@property (weak, nonatomic) IBOutlet UICollectionView *inviteesCollectionView;
@property (strong, nonatomic) NSMutableArray<PFUser *> *_Nonnull invitees;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *closeIndicator;
@property (assign, nonatomic) BOOL canEdit;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation NewEventViewController

static NSString * const NEW_EVENT_TO_ADD_INVITEE_SEGUE_TITLE = @"newEventToAddInvitee";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleScreen];
    [self setupCollectionView];
    
    if (self.event) {
        [self setEvent:self.event];
    } else {
        self.invitees = [[NSMutableArray alloc] init];
    }
}

- (void)setEvent:(Event *)event {
    _event = event;
    self.canEdit = [event.organizer.objectId isEqualToString:[PFUser currentUser].objectId];
    self.invitees = event.invited;
    self.titleField.text = event.title;
    self.locationField.text = event.location;
    self.datePicker.date = event.date;
    [self fetchInvitees];

    [self setEditingRights];
}

- (void)fetchInvitees {
    NSMutableArray<NSString *> *userIds = [[NSMutableArray alloc] initWithCapacity:self.invitees.count];
    
    for (PFUser *user in self.invitees) {
        [userIds addObject:user.objectId];
    }
    
    PFQuery *inviteesQuery = [PFQuery queryWithClassName:[PFUser parseClassName]];
    [inviteesQuery whereKey:OBJECT_ID_KEY containedIn:userIds];
    [inviteesQuery includeKey:PROFILE_IMAGE_KEY];
    
    [inviteesQuery findObjectsInBackgroundWithBlock:^(NSArray *_Nullable invitees, NSError *_Nullable error){
        if (invitees) {
            self.invitees = invitees;
            [self.inviteesCollectionView reloadData];
        }
    }];
}

- (void)setEditingRights {
    if (!self.canEdit) {
        self.saveButton.enabled = NO;
        self.saveButton.alpha = 0;
        self.addInviteeButton.enabled = NO;
        self.addInviteeButton.alpha = 0;
        self.changeImageButton.enabled = NO;
        self.changeImageButton.alpha = 0;
        
        self.titleField.enabled = NO;
        self.locationField.enabled = NO;
        self.datePicker.enabled = NO;
    }
}

- (void)styleScreen {
    static const float EVENT_PICTURE_CORNER_RADIUS = 14;
    static const float CLOSE_INDICATOR_CORNER_RADIUS = 4;
    
    self.eventPictureView.layer.cornerRadius = EVENT_PICTURE_CORNER_RADIUS;
    self.eventPictureView.layer.masksToBounds = YES;
    
    self.closeIndicator.layer.cornerRadius = CLOSE_INDICATOR_CORNER_RADIUS;
    self.closeIndicator.layer.masksToBounds = YES;
}

- (IBAction)didTapCancel:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSave:(UIButton *)sender {
    static NSString * const EMPTY_FIELDS_ALERT_TITLE = @"Error";
    static NSString * const EMPTY_FIELDS_ALERT_MESSAGE = @"Empty Fields";
    PFFileObject *imageObject = getFileFromImage(self.eventPictureView.image);
    
    if ([self isFormValid]) {
        //update existing event
        if (self.event) {
            self.event.date = self.datePicker.date;
            self.event.location = self.locationField.text;
            self.event.title = self.titleField.text;
            self.event.image = imageObject;
            self.event.invited = self.invitees;

            
            [self.event saveInBackground];
        } else {
            //upload new event to Parse database
            [Event postEvent:[PFUser currentUser]
                        date:self.datePicker.date
                    location:self.locationField.text
                       title:self.titleField.text
                       image:imageObject
                     invited:self.invitees
                    accepted:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        UIAlertController *alertController = createOkAlert(EMPTY_FIELDS_ALERT_TITLE, EMPTY_FIELDS_ALERT_MESSAGE);
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (BOOL)isFormValid {
    return self.titleField.text.length > 0 && self.locationField.text.length > 0;
}

#pragma mark - CollectionView method

- (void)setupCollectionView {
    self.inviteesCollectionView.delegate = self;
    self.inviteesCollectionView.dataSource = self;
}

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString * const INVITEE_CELL_IDENTIFIER = @"InviteeCollectionViewCell";
    
    InviteeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:INVITEE_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (cell) {
        [cell setCell:self.invitees[indexPath.item] canRemove:self.canEdit];
        cell.removeInvitee = ^(InviteeCollectionViewCell *_Nonnull cell){
            [self removeInvitee:cell];
        };
    }
    
    return cell;
}

- (void)removeInvitee:(InviteeCollectionViewCell *_Nonnull)cell {
    long indexToRemove = [self.inviteesCollectionView indexPathForCell:cell].item;

    [self.invitees removeObjectAtIndex:indexToRemove];
    [self.inviteesCollectionView reloadData];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.invitees.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    static const int INVITEE_CELL_WIDTH = 60;
    return CGSizeMake(INVITEE_CELL_WIDTH, self.inviteesCollectionView.frame.size.height);
}

- (void)addInvitee:(PFUser *_Nonnull)newInvitee {
    //init set with twice capvity to avoid hashing conflicts (better time performance)
    NSMutableSet<NSString *> *setOfCurrentInviteeIds = [[NSMutableSet alloc] initWithCapacity:self.invitees.count * 2];
    
    for (PFUser *user in self.invitees) {
        [setOfCurrentInviteeIds addObject:user.username];
    }
    
    if (newInvitee && ![setOfCurrentInviteeIds containsObject:newInvitee.username]) {
        [self.invitees addObject:newInvitee];
        [self.inviteesCollectionView reloadData];
    }
}

#pragma mark - Changing Image

static NSString * const CHOOSE_ACTION_TITLE = @"Choose From Photos";
static NSString * const TAKE_ACTION_TITLE = @"Take Photo";
static NSString * const CANCEL_ACTION_TITLE = @"Cancel";

static int IMAGE_STANDARD_DIMENSIONS = 500;

- (IBAction)didTapChangeImage:(UIButton *)sender {
    UIAlertController *photoAlert = [UIAlertController alertControllerWithTitle:nil
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *chooseAction = [UIAlertAction actionWithTitle:CHOOSE_ACTION_TITLE style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        //choose from photos
        [self launchImagePicker:NO];
    }];
    
    UIAlertAction *takeAction = [UIAlertAction actionWithTitle:TAKE_ACTION_TITLE style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
        //take a photo
        [self launchImagePicker:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(CANCEL_ACTION_TITLE, nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [photoAlert addAction:chooseAction];
    [photoAlert addAction:takeAction];
    [photoAlert addAction:cancelAction];
    [self presentViewController:photoAlert animated:YES completion:nil];
}

- (void)launchImagePicker:(BOOL)take {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if (take && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    editedImage = resizeImage(editedImage,
                              CGSizeMake(IMAGE_STANDARD_DIMENSIONS,
                                         IMAGE_STANDARD_DIMENSIONS));
    
    self.eventPictureView.image = editedImage;
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:NEW_EVENT_TO_ADD_INVITEE_SEGUE_TITLE]) {
        AddInviteeViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.addInvitee = ^(PFUser *_Nonnull user) {
            if (user) {
                [self addInvitee:user];
            }
        };
    }
}

@end
