//
//  TOTIPSummaryViewController.m
//  TOTIP
//
//  Created by Jeremy Foo on 20/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPOptionsSummaryViewController.h"

@interface TOTIPOptionsSummaryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, strong) NSArray *keys;
@end

@implementation TOTIPOptionsSummaryViewController

-(instancetype)initWithTitle:(NSString *)title optionsSummary:(NSDictionary *)optionsSummary {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _summaryTitle = title;
        _optionsSummaryMap = optionsSummary;
        _keys = [_optionsSummaryMap allKeys];
    }
    return self;
}

-(void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.allowsMultipleSelection = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return [self.optionsSummaryMap count];
    if (section == 1) return 2;
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return self.summaryTitle;
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *optionCellIdentifier = @"OptionCellIdentifier";
    static NSString *summaryCellIdentifier= @"SummaryCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(indexPath.section == 0) ? summaryCellIdentifier : optionCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(indexPath.section == 0) ? UITableViewCellStyleValue1 : UITableViewCellStyleDefault
                                      reuseIdentifier:(indexPath.section == 0) ? summaryCellIdentifier : optionCellIdentifier];
        cell.selectionStyle = (indexPath.section == 0) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        cell.textLabel.text = [self.keys objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self.optionsSummaryMap objectForKey:[self.keys objectAtIndex:indexPath.row]];
    }
    
    if (indexPath.section == 1)
        cell.textLabel.text = (indexPath.row == 0) ? @"Confirm" : @"Cancel";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if ([self.delegate respondsToSelector:@selector(didConfirmSummaryForOptionsSummary:)])
                [self.delegate didConfirmSummaryForOptionsSummary:self];
        } else {
            if ([self.delegate respondsToSelector:@selector(didCancelSummaryForOptionsSummary:)])
                [self.delegate didCancelSummaryForOptionsSummary:self];
        }
    }
}

@end
