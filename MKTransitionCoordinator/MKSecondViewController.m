//
//  MKSecondViewController.m
//  Test
//
//  Created by Mayank Kumar on 3/13/14.
//  Copyright (c) 2014 Mayank. All rights reserved.
//

#import "MKSecondViewController.h"

@interface MKSecondViewController ()
@property (nonatomic, strong) NSArray *data;
@end

@implementation MKSecondViewController

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
    
    self.title = @"Second View Controller";
    self.data = @[@"First Cell Data -2", @"Second Cell Data -2", @"Third Cell Data -2", @"Fourth Cell Data -2"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
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
