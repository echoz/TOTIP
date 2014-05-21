//
//  TOTIPOptionsViewController.m
//  TOTIP
//
//  Created by Jeremy Foo on 19/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPOptionsViewController.h"

@interface TOTIPOptionsViewController ()
@property (nonatomic, copy) NSIndexPath *selectedIndexPath;
@end

@implementation TOTIPOptionsViewController

-(instancetype)initWithKeyValueMap:(NSDictionary *)keyValue {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _keyValueMap = keyValue;
        _keys = [[_keyValueMap allKeys] sortedArrayUsingSelector:@selector(compare:)];
    }
    return self;
}

-(void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.allowsMultipleSelection = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.initialIndexPath)
        [self.tableView scrollToRowAtIndexPath:self.initialIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
}

#pragma mark - UITableView

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return self.sectionTitle;
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) return self.helpText;
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return [self.keys count];
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *optionCellIdentifier = @"OptionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:optionCellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:optionCellIdentifier];

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = ((self.selectedIndexPath) && ([indexPath isEqual:self.selectedIndexPath])) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    if (indexPath.section == 0) {
        id key = [self.keys objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", key];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        self.selectedIndexPath = indexPath;
        
        for (UITableViewCell *visibleCell in self.tableView.visibleCells)
            visibleCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        if (![self.delegate respondsToSelector:@selector(optionsViewController:didSelectKey:value:)]) return;
        
        NSString *key = [self.keys objectAtIndex:indexPath.row];
        [self.delegate optionsViewController:self didSelectKey:key value:[self.keyValueMap objectForKey:key]];
    }
}


@end
