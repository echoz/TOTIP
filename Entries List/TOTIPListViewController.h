//
//  TOTIPListViewController.h
//  TOTIP
//
//  Created by Jeremy Foo on 20/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TOTIPQuery.h"

@interface TOTIPListViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak, readonly) UICollectionView *collectionView;
@property (nonatomic, copy, readonly) NSDictionary *localizationMap;
@property (nonatomic, strong) TOTIPQuery *currentQuery;

@end
