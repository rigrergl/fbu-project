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
#import "EventsSectionHeader.h"
#import <Parse/Parse.h>

@interface EventsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *_Nonnull collectionView;
@property (strong, atomic) NSMutableArray<Event *> *_Nonnull attendingEvents;
@property (strong, nonatomic) NSMutableArray<Event *> *_Nonnull invitedEvents;

@end

@implementation EventsViewController

static const int ATTENDING_SECTION_NUMBER = 0;
static const int INVITED_SECTION_NUMBER = 1;
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
            [self.collectionView reloadData];
        }
        
        PFQuery *acceptedQuery = [PFQuery queryWithClassName:[Event parseClassName]];
        [organizerQuery includeKey:EVENT_INVITED_KEY];
        [organizerQuery includeKey:EVENT_ACCEPTED_KEY];
        [acceptedQuery whereKey:EVENT_ACCEPTED_KEY containsAllObjectsInArray:@[[PFUser currentUser]]];
        [acceptedQuery findObjectsInBackgroundWithBlock:^(NSArray<Event *> *_Nullable acceptedEvents, NSError *_Nullable error){
            if (acceptedEvents) {
                [self.attendingEvents addObjectsFromArray:acceptedEvents];
                [self.collectionView reloadData];
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
            [self.collectionView reloadData];
        }
    }];
}

# pragma mark  - CollectionView methods

static NSString * const SECTION_HEADER_ELEMENT_KIND = @"section-header-element-kind";
static NSString * ATTENDING_SECTION_TITLE = @"Attending";
static NSString * INVITED_SECTION_TITLE = @"Invited";

- (void)setupCollectionViews {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:EVENTS_SECTION_HEADER_REUSE_IDENTIFIER bundle:nil] forSupplementaryViewOfKind:SECTION_HEADER_ELEMENT_KIND withReuseIdentifier:EVENTS_SECTION_HEADER_REUSE_IDENTIFIER];
    
    self.collectionView.collectionViewLayout = [self generateLayout];
}

- (UICollectionViewLayout *) generateLayout {
    static int EVENT_GROUP_DIMENSIONS = 250;
    static int EVENT_EDGE_INSETS = 5;
    static int SECTION_HEADER_HEIGHT = 44;
    
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
        if (indexPath.section == ATTENDING_SECTION_NUMBER) {
            [cell setCellForAttending:self.attendingEvents[indexPath.item] segueToChat:^(EventCollectionViewCell *cell){
                [self performSegueWithIdentifier:SEGUE_TO_CHAT_IDENTIFIER sender:cell.event];
            }];
        } else {
            [cell setCellForInvited:self.invitedEvents[indexPath.item] acceptInvite:^(EventCollectionViewCell *cell){
                [self acceptInvite:cell];
            }];
        }
        cell.segueToInfo = ^(EventCollectionViewCell *_Nonnull cell){
            [self performSegueWithIdentifier:SEGUE_TO_EVENT_INFO_IDENTIFIER sender:cell.event];
        };
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    EventsSectionHeader *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:EVENTS_SECTION_HEADER_REUSE_IDENTIFIER forIndexPath:indexPath];
    
    if (indexPath.section == ATTENDING_SECTION_NUMBER) {
        [sectionHeader setTitle:ATTENDING_SECTION_TITLE];
    } else {
        [sectionHeader setTitle:INVITED_SECTION_TITLE];
    }
    
    return sectionHeader;
}

- (void)acceptInvite:(EventCollectionViewCell *_Nonnull)cell {
    Event *acceptedEvent = cell.event;
    long indexOfAcceptedEvent = [self.collectionView indexPathForCell:cell].item;
    [self.invitedEvents removeObjectAtIndex:indexOfAcceptedEvent];
    [self.attendingEvents insertObject:acceptedEvent atIndex:0];
    
    [self.collectionView reloadData];
    [self.collectionView reloadData];
    
    [acceptedEvent moveUserToAccepted:[PFUser currentUser]];
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (section == ATTENDING_SECTION_NUMBER) {
        return self.attendingEvents.count;
    }
    
    return self.invitedEvents.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
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
