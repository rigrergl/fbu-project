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

@property (weak, nonatomic) IBOutlet UITextView *inputTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.messages = [[NSArray alloc] initWithObjects:@"First Message", @"Second Message", @"Third Message", nil];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
    
    [self setupGestures];
    [self styleInputTextView];
    
    [self setupBottomConstraint];
}

- (void)setupBottomConstraint {
    CGFloat bottomBarHeight = self.tabBarController.tabBar.frame.size.height;
    self.bottomConstraint.constant = bottomBarHeight + 8;
}

- (void)styleInputTextView {
    self.inputTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.inputTextView.layer.borderWidth = 1;
    self.inputTextView.layer.cornerRadius = 10.0f;
}

- (void)setupGestures {
    UITapGestureRecognizer *screenTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScreen:)];
    [self.view addGestureRecognizer:screenTapGestureRecognizer];
    [self.view setUserInteractionEnabled:YES];
}

- (void)didTapScreen:(UIGestureRecognizer *)sender {
    [self endTyping];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Collection View methods

- (nonnull UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chatCell" forIndexPath:indexPath];
    
    if (cell) {
        cell.contentLabel.text = [LoremIpsum sentence];
        cell.wrappingViewWidth.constant = self.view.frame.size.width;
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

#pragma mark - keyboard movements

- (void)endTyping {
    [self.inputTextView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{

    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

@end
