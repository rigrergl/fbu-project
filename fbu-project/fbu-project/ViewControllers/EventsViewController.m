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
#import "EventViewController.h"
#import "EventsSectionHeader.h"
#import <Parse/Parse.h>

@interface EventsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, atomic) NSMutableArray<Event *> *_Nonnull attendingEvents;
@property (strong, nonatomic) NSMutableArray<Event *> *_Nonnull invitedEvents;
@property (strong, nonatomic) NSMutableArray<Event *> *_Nonnull expiredEvents;

@end

static const NSInteger NUMBER_OF_SECTIONS_IN_COLLECTION_VIEW = 3;
static const NSInteger ATTENDING_SECTION_NUMBER = 0;
static const NSInteger INVITED_SECTION_NUMBER = 1;
static const NSInteger EXPIRED_SECTION_NUMBER = 2;
static NSInteger EVENT_GROUP_DIMENSIONS = 250;
static NSInteger EVENT_EDGE_INSETS = 5;
static NSInteger SECTION_HEADER_HEIGHT = 60;
static NSString * const SECTION_HEADER_ELEMENT_KIND = @"section-header-element-kind";
static NSString * ATTENDING_SECTION_TITLE = @"Attending";
static NSString * INVITED_SECTION_TITLE = @"Invited";
static NSString * EXPIRED_SECTION_TITLE = @"Past Events";
static NSString * const EVENT_CELL_IDENTIFIER = @"EventCollectionViewCell";
static NSString * const SEGUE_TO_CHAT_IDENTIFIER = @"eventsToChat";
static NSString * const SEGUE_TO_EVENT_INFO_IDENTIFIER = @"eventInfoSegue";

@implementation EventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchAttendingEvents];
    [self fetchInvitedEvents];
}

- (void)fetchAttendingEvents {
    self.attendingEvents = [[NSMutableArray alloc] init];
    
    PFQuery *organizerQuery = [PFQuery queryWithClassName:[Event parseClassName]];
    [organizerQuery whereKey:EVENT_ORGANIZER_KEY equalTo:[PFUser currentUser]];
    [organizerQuery includeKey:EVENT_INVITED_KEY];
    [organizerQuery includeKey:EVENT_ACCEPTED_KEY];
    
    [organizerQuery findObjectsInBackgroundWithBlock:^(NSArray<Event *> *_Nullable organizedEvents, NSError *_Nullable error){
        if (organizedEvents) {
            [self.attendingEvents addObjectsFromArray:organizedEvents];
            [self.collectionView reloadData];
        }
        
        PFQuery *acceptedQuery = [PFQuery queryWithClassName:[Event parseClassName]];
        [acceptedQuery includeKey:EVENT_IMAGE_KEY];
        [acceptedQuery includeKey:EVENT_INVITED_KEY];
        [acceptedQuery includeKey:EVENT_ACCEPTED_KEY];
        [acceptedQuery whereKey:EVENT_ACCEPTED_KEY containsAllObjectsInArray:@[[PFUser currentUser]]];
        [acceptedQuery findObjectsInBackgroundWithBlock:^(NSArray<Event *> *_Nullable acceptedEvents, NSError *_Nullable error){
            if (acceptedEvents) {
                [self.attendingEvents addObjectsFromArray:acceptedEvents];
            }
            [self filterOutExpiredEventsFromAttending];
            [self sortEventsByDate:self.attendingEvents ascending:YES];
            [self sortEventsByDate:self.expiredEvents ascending:NO];
            [self.collectionView reloadData];
        }];
    }];
}

- (void)filterOutExpiredEventsFromAttending {
    NSMutableArray *allEvents = self.attendingEvents;
    self.attendingEvents = [[NSMutableArray alloc] init];
    self.expiredEvents = [[NSMutableArray alloc] init];
    
    for (Event *event in allEvents) {
        if ([event.date compare:[NSDate now]] == NSOrderedDescending) {
            [self.attendingEvents addObject:event];
        } else {
            [self.expiredEvents addObject:event];
        }
    }
}

- (void)fetchInvitedEvents {
    //events that have the current user inside their invited array
    PFQuery *query = [PFQuery queryWithClassName:[Event parseClassName]];
    [query includeKey:EVENT_IMAGE_KEY];
    [query whereKey:EVENT_INVITED_KEY containsAllObjectsInArray:@[[PFUser currentUser]]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray<Event *> *_Nullable invitedEvents, NSError *_Nullable error){
        if (invitedEvents) {
            self.invitedEvents = invitedEvents;
            [self.collectionView reloadData];
        }
        [self sortEventsByDate:self.invitedEvents ascending:YES];
    }];
}

- (void)sortEventsByDate:(NSMutableArray<Event *> *_Nonnull)events ascending:(BOOL)ascending {
    [events sortUsingComparator:^NSComparisonResult(Event *_Nonnull event1, Event *_Nonnull event2){
        if (![event1 isKindOfClass:[Event class]] || ![event1 isKindOfClass:[Event class]]) {
            return NSOrderedSame;
        }
        if (ascending) {
            return [event1.date compare:event2.date];
        }
        return [event2.date compare:event1.date];
    }];
}

# pragma mark  - CollectionView methods

- (void)setupCollectionViews {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:EVENTS_SECTION_HEADER_REUSE_IDENTIFIER bundle:nil] forSupplementaryViewOfKind:SECTION_HEADER_ELEMENT_KIND withReuseIdentifier:EVENTS_SECTION_HEADER_REUSE_IDENTIFIER];
    
    self.collectionView.collectionViewLayout = [self generateLayout];
}

- (UICollectionViewLayout *) generateLayout {
    UICollectionViewLayout *layout = [[UICollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection *_Nullable(NSInteger section, id<NSCollectionLayoutEnvironment> sectionProvider) {
        
        //item
        NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1] heightDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]];
        
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];
        
        //group
        NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension absoluteDimension:EVENT_GROUP_DIMENSIONS] heightDimension:[NSCollectionLayoutDimension absoluteDimension:EVENT_GROUP_DIMENSIONS]];
        
        NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize subitem:item count:1];
        group.contentInsets = NSDirectionalEdgeInsetsMake(EVENT_EDGE_INSETS, EVENT_EDGE_INSETS, EVENT_EDGE_INSETS, EVENT_EDGE_INSETS);
        
        //section
        NSCollectionLayoutSection *sectionLayout = [NSCollectionLayoutSection sectionWithGroup:group];
        
        NSCollectionLayoutSize *headerSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1] heightDimension:[NSCollectionLayoutDimension estimatedDimension:SECTION_HEADER_HEIGHT]];
        
        NSCollectionLayoutBoundarySupplementaryItem *sectionHeader = [NSCollectionLayoutBoundarySupplementaryItem boundarySupplementaryItemWithLayoutSize:headerSize elementKind:SECTION_HEADER_ELEMENT_KIND alignment:NSRectAlignmentTop];
        
        sectionLayout.boundarySupplementaryItems = @[sectionHeader];
        sectionLayout.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorContinuous;
        
        return sectionLayout;
    }];
    
    return layout;
}



- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EventCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:EVENT_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (cell) {
        if (indexPath.section == ATTENDING_SECTION_NUMBER && self.attendingEvents && self.attendingEvents.count > 0) {
            [cell setCellForAttending:self.attendingEvents[indexPath.item] segueToChat:^(EventCollectionViewCell *cell){
                [self performSegueWithIdentifier:SEGUE_TO_CHAT_IDENTIFIER sender:cell.event];
            }];
        } else if (indexPath.section == INVITED_SECTION_NUMBER && self.invitedEvents && self.invitedEvents.count > 0) {
            [cell setCellForInvited:self.invitedEvents[indexPath.item] acceptInvite:^(EventCollectionViewCell *cell){
                [self acceptInvite:cell];
            }];
        } else if (indexPath.section == EXPIRED_SECTION_NUMBER && self.expiredEvents && self.expiredEvents.count > 0) {
            [cell setCellForAttending:self.expiredEvents[indexPath.item] segueToChat:^(EventCollectionViewCell *cell){
                [self performSegueWithIdentifier:SEGUE_TO_CHAT_IDENTIFIER sender:cell.event];
            }];
        }
        
        cell.segueToInfo = ^(EventCollectionViewCell *_Nonnull cell){
            [self performSegueWithIdentifier:SEGUE_TO_EVENT_INFO_IDENTIFIER sender:cell.event];
        };
        cell.presentAlert = ^(UIAlertController *_Nonnull alert){
            [self presentViewController:alert animated:YES completion:nil];
        };
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    EventsSectionHeader *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EVENTS_SECTION_HEADER_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    if (indexPath.section == ATTENDING_SECTION_NUMBER) {
        [sectionHeader setTitle:ATTENDING_SECTION_TITLE color:nil displaySeparator:NO];
    } else if (indexPath.section == INVITED_SECTION_NUMBER) {
        [sectionHeader setTitle:INVITED_SECTION_TITLE color:nil displaySeparator:YES];
    } else if (indexPath.section == EXPIRED_SECTION_NUMBER) {
        [sectionHeader setTitle:EXPIRED_SECTION_TITLE color:[UIColor redColor] displaySeparator:YES];
    }
    
    return sectionHeader;
}

- (void)acceptInvite:(EventCollectionViewCell *_Nonnull)cell {
    Event *acceptedEvent = cell.event;
    NSInteger indexOfAcceptedEvent = [self.collectionView indexPathForCell:cell].item;
    [self.invitedEvents removeObjectAtIndex:indexOfAcceptedEvent];
    [self.attendingEvents insertObject:acceptedEvent atIndex:0];
    
    [self.collectionView reloadData];
    
    [acceptedEvent moveUserToAccepted:[PFUser currentUser]];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (section == ATTENDING_SECTION_NUMBER) {
        return self.attendingEvents.count;
    } else if (section == INVITED_SECTION_NUMBER) {
        return self.invitedEvents.count;
    } else if (section == EXPIRED_SECTION_NUMBER) {
        return self.expiredEvents.count;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return NUMBER_OF_SECTIONS_IN_COLLECTION_VIEW;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_TO_CHAT_IDENTIFIER]) {
        Event *event = (Event *) sender;
        ChatViewController *destinationController = [segue destinationViewController];
        destinationController.event = event;
    } else if ([segue.identifier isEqualToString:SEGUE_TO_EVENT_INFO_IDENTIFIER]) {
        Event *event = (Event *)sender;
        EventViewController *destinationController = [segue destinationViewController];
        if (event) {
            [destinationController setEvent:event];
        }
        destinationController.didSave = ^(Event *_Nullable event){
            [self updateEvents:event];
        };
    }
}

- (void)updateEvents:(Event *_Nullable)event {
    if (!event) {
        return;
    }
    
    if (![self.attendingEvents containsObject:event]) {
        [self.attendingEvents addObject:event];
    }
    
    [self.collectionView reloadData];
}

- (IBAction)didTapAddEvent:(UIButton *)sender {
    [self performSegueWithIdentifier:SEGUE_TO_EVENT_INFO_IDENTIFIER sender:nil];
}

@end
