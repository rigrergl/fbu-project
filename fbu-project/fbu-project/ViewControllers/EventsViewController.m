//
//  EventsViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "EventsViewController.h"
#import "EventCollectionViewCell.h"
#import "Event.h"
#import "DictionaryConstants.h"
#import "ChatViewController.h"
#import "NewEventViewController.h"
#import <Parse/Parse.h>

@interface EventsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *_Nonnull attendingCollectionView;
@property (strong, nonatomic) IBOutlet UICollectionView *_Nonnull invitedCollectionView;
@property (strong, atomic) NSMutableArray<Event *> *_Nonnull attendingEvents;
@property (strong, nonatomic) NSMutableArray<Event *> *_Nonnull invitedEvents;

@end

@implementation EventsViewController

static NSString * const EVENT_CELL_IDENTIFIER = @"EventCollectionViewCell";
static NSString * const SEGUE_TO_CHAT_IDENTIFIER = @"eventsToChat";
static NSString * const SEGUE_TO_EVENT_INFO_IDENTIFIER = @"eventInfoSegue";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchAttendingEvents];
    [self fetchInvitedEvents];
}

- (void)setupCollectionViews {
    self.attendingCollectionView.delegate = self;
    self.attendingCollectionView.dataSource = self;
    self.invitedCollectionView.delegate = self;
    self.invitedCollectionView.dataSource = self;
}

- (void)fetchAttendingEvents {
    //TODO: test that accepted events query works (event acceptance implementation required first)
    
    self.attendingEvents = [[NSMutableArray alloc] init];
    
    PFQuery *organizerQuery = [PFQuery queryWithClassName:[Event parseClassName]];
    [organizerQuery whereKey:EVENT_ORGANIZER_KEY equalTo:[PFUser currentUser]];
    [organizerQuery includeKey:EVENT_INVITED_KEY];
    [organizerQuery includeKey:EVENT_ACCEPTED_KEY];
    
    [organizerQuery findObjectsInBackgroundWithBlock:^(NSArray<Event *> *_Nullable organizedEvents, NSError *_Nullable error){
        if (organizedEvents) {
            [self.attendingEvents addObjectsFromArray:organizedEvents];
            [self.attendingCollectionView reloadData];
        }
        
        PFQuery *acceptedQuery = [PFQuery queryWithClassName:[Event parseClassName]];
        [organizerQuery includeKey:EVENT_INVITED_KEY];
        [organizerQuery includeKey:EVENT_ACCEPTED_KEY];
        [acceptedQuery whereKey:EVENT_ACCEPTED_KEY containsAllObjectsInArray:@[[PFUser currentUser]]];
        [acceptedQuery findObjectsInBackgroundWithBlock:^(NSArray<Event *> *_Nullable acceptedEvents, NSError *_Nullable error){
            if (acceptedEvents) {
                [self.attendingEvents addObjectsFromArray:acceptedEvents];
                [self.attendingCollectionView reloadData];
            }
        }];
    }];
}

- (void)fetchInvitedEvents {
    //events that have the current user inside their invited array
    PFQuery *query = [PFQuery queryWithClassName:[Event parseClassName]];
    [query whereKey:EVENT_INVITED_KEY containsAllObjectsInArray:@[[PFUser currentUser]]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray<Event *> *_Nullable invitedEvents, NSError *_Nullable error){
        if (invitedEvents) {
            self.invitedEvents = invitedEvents;
            [self.invitedCollectionView reloadData];
        }
    }];
}

# pragma mark  - CollectionView methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EVENT_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (cell) {
        if (collectionView == self.attendingCollectionView) {
            [cell setCell:self.attendingEvents[indexPath.item]];
            cell.segueToChat = ^(EventCollectionViewCell *_Nonnull cell){
                [self performSegueWithIdentifier:SEGUE_TO_CHAT_IDENTIFIER sender:cell.event];
            };
        } else {
            [cell setCell:self.invitedEvents[indexPath.item]];
            cell.acceptInvite = ^(EventCollectionViewCell *_Nonnull cell){
                [self acceptInvite:cell];
            };
        }
        cell.segueToInfo = ^(EventCollectionViewCell *_Nonnull cell){
            [self performSegueWithIdentifier:SEGUE_TO_EVENT_INFO_IDENTIFIER sender:cell.event];
        };
    }
    
    return cell;
}

- (void)acceptInvite:(EventCollectionViewCell *_Nonnull)cell {
    Event *acceptedEvent = cell.event;
    long indexOfAcceptedEvent = [self.invitedCollectionView indexPathForCell:cell].item;
    [self.invitedEvents removeObjectAtIndex:indexOfAcceptedEvent];
    [self.attendingEvents insertObject:acceptedEvent atIndex:0];
    
    [self.attendingCollectionView reloadData];
    [self.invitedCollectionView reloadData];
    
    [acceptedEvent moveUserToAccepted:[PFUser currentUser]];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.attendingCollectionView) {
        return self.attendingEvents.count;
    } else {
        return self.invitedEvents.count;
    }
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_TO_CHAT_IDENTIFIER]) {
        
        Event *event = (Event *) sender;
        ChatViewController *destinationController = [segue destinationViewController];
        destinationController.event = event;
    } else if ([segue.identifier isEqualToString:SEGUE_TO_EVENT_INFO_IDENTIFIER] && [sender isKindOfClass: [Event class]]) {
        Event *event = (Event *)sender;
        NewEventViewController *destinationController = [segue destinationViewController];
        [destinationController setEvent:event];
    }
}

@end
