//
//  MSCollectionDataSource.m
//  EMSpeed
//
//  Created by Mac mini 2012 on 15-2-13.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import "MSCollectionDataSource.h"

@implementation MSCollectionDataSource

- (instancetype)initWithItems:(NSArray *)aItems sections:(NSArray *)aSections
{
    NSAssert((aItems && aSections && [aItems count]==[aSections count]), @"Sections and items shouldn't be null");
    
    self = [super init];
    if (self) {
        if (aItems) {
            _items = [[[self itemsClass] alloc] initWithArray:aItems];
        }
        else {
            _items = [[[self itemsClass] alloc] init];
        }
        
        
        if (aSections) {
            _sections = [[[self sectionsClass] alloc] initWithArray:aSections];
        }
        else {
            _sections = [[[self sectionsClass] alloc] init];
        }
    }
    return self;
}

- (Class)sectionsClass
{
    return [NSArray class];
}

- (Class)itemsClass
{
    return [NSArray class];
}


#pragma mark -
#pragma mark Data Source methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [_sections count] ? [_sections count] : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *cells = [_items objectAtIndex:section];
    return [cells count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<MSCollectionCellModel> item = [self itemAtIndexPath:indexPath];
    Class class = item.Class;

//    id<MSCellModel> item = [self itemAtIndexPath:indexPath];
//    Class class = item.Class;
    if (!class) {
        class = [UICollectionViewCell class];
    }
    
    NSString *reuseIdentifier = NSStringFromClass(class);
    
    if ([item respondsToSelector:@selector(shouldAppendCellModelToReuseIdentifier)] &&
        [item shouldAppendCellModelToReuseIdentifier]) {
        reuseIdentifier = [NSString stringWithFormat:@"%@.%@",reuseIdentifier,NSStringFromClass(item.class)];
    }
    
    if (![item isRegisterByClass]) {
        [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(class) bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    } else {
        [collectionView registerClass:class forCellWithReuseIdentifier:reuseIdentifier];
    }
    
    NSLog(@"==========================================");
    NSLog(@"item:            %@", item);
    NSLog(@"reuseIdentifier: %@", reuseIdentifier);
    NSLog(@"cellClass:       %@", class);
    NSLog(@"Load from Nib? : %d", ![item isRegisterByClass]);
    NSLog(@"==========================================");

    
    
    if (class != NULL)
    {
        NSString* identifier = NSStringFromClass(class);
        id cell = (id)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        
        if (cell == nil)
        {
            cell = [[UICollectionViewCell alloc] init];
        }
        
        if ([cell respondsToSelector:@selector(update:indexPath:)]) {
            [cell update:item indexPath:indexPath];
        }
        else if ([cell respondsToSelector:@selector(update:)]) {
            [cell update:item];
        }
        
        if ([cell isKindOfClass:[UICollectionViewCell class]]) {
            UICollectionViewCell *aCell = cell;
            if ([aCell respondsToSelector:@selector(setLayoutMargins:)]) {
                aCell.layoutMargins = UIEdgeInsetsZero;
                aCell.preservesSuperviewLayoutMargins = NO;
            }
        }
        
        return cell;
    }
    else
    {
        return [[UICollectionViewCell alloc] initWithFrame:CGRectZero];
    }
}


# pragma mark - Setter & Getter
- (NSIndexPath *)indexPathOfItem:(id<MSCollectionCellModel>)cellModel {
    NSInteger section = -1;
    NSInteger row = -1;

    for(int s = 0 ; s < [_items count]; s++) {
        NSArray *arr = [_items objectAtIndex:s];
        for(int r = 0 ; r < [arr count]; r++) {
            id<MSCollectionCellModel>item = arr[r];
            if (item == cellModel) {
                section = s;
                row  = r;
                break;
            }
        }
    }
    
    if (section != -1 && row != -1) {
        return [NSIndexPath indexPathForRow:row inSection:section];
    } else {
        return nil;
    }
}

- (id<MSCollectionCellModel>)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if([_items count] > indexPath.section)
    {
        NSArray *arr = [_items objectAtIndex:indexPath.section];
        if ([arr count] > indexPath.row)
        {
            return [arr objectAtIndex:indexPath.row];
        }
    }
    return nil;
}

- (id<MSCollectionCellModel>)itemAtIndex:(NSUInteger)index
{
    return [self itemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (NSString *)titleAtSection:(NSUInteger)section
{
    assert(section>=0 && section<[_sections count]);
    return [_sections objectAtIndex:section];
}

- (NSUInteger)sectionIndexWithTitle:(NSString *)title
{
    for (int i=0; i<[_sections count]; i++) {
        NSString *str = [self titleAtSection:i];
        if ([str isEqualToString:title]) {
            return i;
        }
    }
    
    return NSNotFound;
}

- (NSArray *)itemsAtSection:(NSUInteger)section
{
    NSAssert((section>=0 && section<[_sections count]), nil);
    
    return [_items objectAtIndex:section];
}

- (NSArray *)itemsAtSectionWithTitle:(NSString *)title
{
    NSUInteger section = [self sectionIndexWithTitle:title];
    if (section != NSNotFound) {
        return [self itemsAtSection:section];
    }
    
    return nil;
}


#if 0
- (void)registerCellForView:(UIView *)view
{
    if ([view isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)view;
        
        NSMutableDictionary *mdict = [NSMutableDictionary dictionary];// 用作去重复
        
        for (int i=0; i<[_items count]; i++) {
            NSArray *array = [_items objectAtIndex:i];
            for (int j=0; j<[array count]; j++) {
                id<MSCellModel> model = [array objectAtIndex:j];
                NSString *reuseIdentify = model.reuseIdentify;
                Class cls = NSClassFromString(reuseIdentify);
                
                if (![mdict objectForKey:reuseIdentify]) {
                    if (model.isRegisterByClass) {
                        [collectionView registerClass:cls forCellWithReuseIdentifier:reuseIdentify];
                    }
                    else{
                        [collectionView registerNib:[UINib nibWithNibName:reuseIdentify bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:reuseIdentify];
                    }
                    
                    [mdict setObject:[NSNumber numberWithBool:YES] forKey:reuseIdentify];
                }
            }
        }
    }
}
#endif

@end

