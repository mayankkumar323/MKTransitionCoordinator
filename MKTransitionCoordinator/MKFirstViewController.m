//
//  MKFirstViewController.m
//  Test
//
//  Created by Mayank Kumar on 3/13/14.
//  Copyright (c) 2014 Mayank. All rights reserved.
//

#import "MKFirstViewController.h"
#import "MKSecondViewController.h"
#import "MKTransitionCoordinator.h"


@interface MKFirstViewController () <MKTransitionCoordinatorDelegate>
@property (nonatomic) NSArray *data;
@property (nonatomic, strong) MKTransitionCoordinator *menuInteractor;
@end

@implementation MKFirstViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"First View Controller";
    self.data = @[@"First Cell Data -1", @"Second Cell Data - 1", @"Third Cell Data -1"];
    
    self.menuInteractor = [[MKTransitionCoordinator alloc] initWithParentViewController:self];
    self.menuInteractor.delegate = self;
}

#pragma mark - MKTransitionCoordinatorDelegate Methods
- (UIViewController*) toViewControllerForInteractivePushFromPoint:(CGPoint)locationInWindow {
    //In this example we don't care where the user is pushing from
    return [MKSecondViewController new];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = (NSString*)[self.data objectAtIndex:indexPath.row];
    return cell;
}

@end
