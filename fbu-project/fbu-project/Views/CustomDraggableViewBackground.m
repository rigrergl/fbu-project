//
//  CustomDraggableViewBackground.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/13/21.
//

#import "CustomDraggableViewBackground.h"
#import "CustomDraggableView.h"

@implementation CustomDraggableViewBackground

static const int BUTTON_SECTION_HEIGHT = 120;
static const int MAX_BUFFER_SIZE = 5;

static NSString * const X_BUTTON_IMAGE_NAME = @"xButton";
static NSString * const CHECK_BUTTON_IMAGE_NAME = @"checkButton";

- (id)initWithFrame:(CGRect)frame
           andUsers:(NSArray *)users {
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        [self setupView];
        self.users = users;
        super.loadedCards = [[NSMutableArray alloc] init];
        super.allCards = [[NSMutableArray alloc] init];
        super.cardsLoadedIndex = 0;
        [self loadCards];
    }
    return self;
}

- (void)setupView {
    CGFloat buttonWidth = BUTTON_SECTION_HEIGHT - 15;
    
    self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1]; //the gray background colors
    super.xButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - buttonWidth - 15, self.frame.size.height - BUTTON_SECTION_HEIGHT - 10, buttonWidth, buttonWidth)];
    [super.xButton setImage:[UIImage imageNamed:X_BUTTON_IMAGE_NAME] forState:UIControlStateNormal];
    [super.xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    super.checkButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width/2 + 15, self.frame.size.height - BUTTON_SECTION_HEIGHT - 10, buttonWidth, buttonWidth)];
    [super.checkButton setImage:[UIImage imageNamed:CHECK_BUTTON_IMAGE_NAME] forState:UIControlStateNormal];
    [super.checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:super.xButton];
    [self addSubview:super.checkButton];
}

- (CustomDraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index {
    CGFloat cardMargins = 50;
    CGFloat cardWidth = self.frame.size.width - cardMargins;
    CGFloat cardHeight = self.frame.size.height - cardMargins - BUTTON_SECTION_HEIGHT;
    
    CustomDraggableView *draggableView = [[CustomDraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - cardWidth)/2, (self.frame.size.height - cardHeight - BUTTON_SECTION_HEIGHT + 20)/2,  cardWidth, cardHeight) andUser:self.users[index]];
    draggableView.delegate = self;
    return draggableView;
}

- (void)loadCards {
    if([self.users count] > 0) {
        NSInteger numLoadedCardsCap =(([self.users count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[self.users count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[self.users count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [super.allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [super.loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[super.loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[super.loadedCards objectAtIndex:i] belowSubview:[super.loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[super.loadedCards objectAtIndex:i]];
            }
            super.cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}

@end
