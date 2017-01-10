//
//  EMMultiDataSource.m
//  EMStock
//
//  Created by Mac mini 2012 on 15-2-26.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import "MSMutableDataSource.h"

@implementation MSMutableDataSource

- (Class)sectionsClass
{
    return [NSMutableArray class];
}

- (Class)itemsClass
{
    return [NSMutableArray class];
}

- (void)addNewSection:(NSString *)section withItems:(NSArray *)items
{
    if (section==nil || items==nil) {
        return;
    }
    
    if (_sections==nil) {
        _sections = [[[self sectionsClass] alloc] init];
    }
    if (_items==nil) {
        _items = [[[self itemsClass] alloc] init];
    }
    [_sections addObject:section];
    [_items addObject:items];
}

- (void)insertSection:(NSString *)section
                items:(NSArray *)items
       atSectionIndex:(NSUInteger)index
{
    if (section==nil || items==nil || ([_sections count]>0 && index>=[_sections count])) {
        return;
    }
    
    if (_sections==nil) {
        _sections = [[[self sectionsClass] alloc] init];
    }
    if (_items==nil) {
        _items = [[[self itemsClass] alloc] init];
    }
    
    [_sections insertObject:section atIndex:index];
    [_items insertObject:items atIndex:index];
}


- (void)insertItem:(id<MSCellModel>)item
         indexPath:(NSIndexPath *)indexPath
{
    if (item==nil || indexPath.section>[_sections count]) {
        return;
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSMutableArray *items = [_items objectAtIndex:section];
    if (row>[items count]) {
        row = [items count];
    }
    
    if ([items isKindOfClass:[NSMutableArray class]]) {
        [items insertObject:item atIndex:row];
    }
    else if ([items isKindOfClass:[NSArray class]]){
        NSMutableArray *tmpItems = [NSMutableArray arrayWithArray:items];
        [tmpItems insertObject:item atIndex:row];
        [_items replaceObjectAtIndex:section withObject:tmpItems];
    }
}

- (void)removeItem:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section<0 || section>=[_sections count] || row<0) {
        return;
    }
    
    NSMutableArray *items = [_items objectAtIndex:section];
    if (row<[items count]) {
        if ([items isKindOfClass:[NSMutableArray class]]) {
            [items removeObjectAtIndex:row];
        }
        else if ([items isKindOfClass:[NSArray class]]) {
            NSMutableArray *tmpItems = [NSMutableArray arrayWithArray:items];
            [tmpItems removeObjectAtIndex:row];
            [_items replaceObjectAtIndex:section withObject:tmpItems];
        }
    }
}

- (void)removeSection:(NSUInteger)section
{
    if ([_items count]>section) {
        [_items removeObjectAtIndex:section];
        [_sections removeObjectAtIndex:section];
    }
}

- (void)appendItems:(NSArray *)items atSection:(NSUInteger)section
{
    if ([self.sections count]==0 && section==0) {
        [self addNewSection:@"" withItems:items];
    }
    else if ([items count]>0 && section <= [_sections count]-1) {
        id originItems = [_items objectAtIndex:section];
        if ([originItems isKindOfClass:[NSArray class]]) {
            NSMutableArray *tmpItems = [NSMutableArray array];
            [tmpItems addObjectsFromArray:originItems];
            [tmpItems addObjectsFromArray:items];
            [_items replaceObjectAtIndex:section withObject:tmpItems];
        }
    }
}

- (void)appendItems:(NSArray *)items atSectionTitle:(NSString *)title
{
    NSUInteger sectionIndex = [self sectionIndexWithTitle:title];
    sectionIndex = (sectionIndex==-1) ? 0 : sectionIndex;
    [self appendItems:items atSection:sectionIndex];
}

#pragma mark - UITableview datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section >=0 && section < [_items count])
    {
        NSArray *items = [_items objectAtIndex:section];
        
        NSUInteger count = [items count];
        
        return count;
    }
    
    return 0;
}

- (NSUInteger)numberOfItemsAtSection:(NSUInteger)section
{
    if (section<[_sections count]) {
        NSArray *items = [_items objectAtIndex:section];
        return [items count];
    }
    
    return 0;
}

@end


@implementation MSMutableDataSource (MSExtendedMutableDatasource)

- (void)addEntriesFromDatasrouce:(MSDataSource *)datasource
{
    [_items addObjectsFromArray:datasource.items];
    [_sections addObjectsFromArray:datasource.sections];
    
}

@end