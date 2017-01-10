//
//  MSDataSource.m
//  EMSpeed
//
//  Created by Mac mini 2012 on 15-2-13.
//  Copyright (c) 2015年 flora. All rights reserved.
//

#import "MSDataSource.h"
#import <objc/runtime.h>

@implementation MSDataSource

@synthesize sections = _sections;
@synthesize items = _items;

- (instancetype)initWithItems:(NSArray *)aItems sections:(NSArray *)aSections
{
    NSAssert((aItems && aSections && [aItems count]==[aSections count]), nil);
    
    self = [super init];
    if (self) {
        _items = [[[self itemsClass] alloc] initWithArray:aItems];
        _sections = [[[self sectionsClass] alloc] initWithArray:aSections];
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sections count] ? [_sections count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *cells = [_items objectAtIndex:section];
    return [cells count];
}


/**创建indexpath对应的cell
 *获取对应的cellClass （由子类复写cellClass方法，返回对应生成cell的类型）
 *子类复写此方法时，需要调用配置cell的数据，并且根据cell配置
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MSCellModel> cm = [self itemAtIndexPath:indexPath];
    
    //生成cell
    id cell = (id)[MSCellFactory tableView:tableView cellForRowAtIndexPath:indexPath withCellModel:cm];
    
    //默认配置，todo 后期要去掉，不应该在这里做配置
    if ([cell isKindOfClass:[UITableViewCell class]])
    {
        UITableViewCell *aCell = cell;
        if ([aCell respondsToSelector:@selector(setLayoutMargins:)])
        {
            aCell.layoutMargins = UIEdgeInsetsZero;
            aCell.preservesSuperviewLayoutMargins = NO;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([_sections count] > section)
    {
        NSObject *object = [_sections objectAtIndex:section];
        
        if ([object isKindOfClass:[NSString class]])
        {
            return (NSString *)object;
        }
    }
    return nil;
}

# pragma mark - Setter & Getter
- (NSIndexPath *)indexPathOfItem:(id<MSCellModel>)cellModel {
    NSInteger section = -1;
    NSInteger row = -1;
    
    for(int s = 0 ; s < [_items count]; s++) {
        NSArray *arr = [_items objectAtIndex:s];
        for(int r = 0 ; r < [arr count]; r++) {
            id<MSCellModel>item = arr[r];
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

- (id<MSCellModel>)itemAtIndexPath:(NSIndexPath *)indexPath
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

- (id<MSCellModel>)itemAtIndex:(NSUInteger)index
{
    return [self itemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (NSString *)titleAtSection:(NSUInteger)section
{
    if ((int)section>=0 && section<[_sections count])
    {
        return [_sections objectAtIndex:section];
    }
    else
    {
        return nil;
    }
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
    if ((int)section>=0 && section<[_sections count])
    {
        return [_items objectAtIndex:section];
    }
    else
    {
        return nil;
    }
}

- (NSArray *)itemsAtSectionWithTitle:(NSString *)title
{
    NSUInteger section = [self sectionIndexWithTitle:title];
    if (section!=NSNotFound) {
        return [self itemsAtSection:section];
    }
    
    return nil;
}

- (NSUInteger)numberOfItemsAtSection:(NSUInteger)section
{
    if (section<[_sections count]) {
        NSArray *items = [_items objectAtIndex:section];
        return [items count];
    }
    
    return 0;
}


- (BOOL)isEmpty
{
    NSUInteger numberOfItems = 0;
    for (int i = 0; i<[self.items count]; i++) {
        NSArray *items = [self.items objectAtIndex:i];
        numberOfItems += [items count];
    }
    
    NSUInteger numberOfSections = [self.sections count];
    return numberOfItems == 0 || numberOfSections == 0;
}

@end



@implementation MSDataSource(creation)

- (instancetype)initWithDatasource:(MSDataSource *)datasource
{
    self = [super init];
    if (self) {
        _items = [[self itemsClass] arrayWithArray:datasource.items];
        _sections = [[self sectionsClass] arrayWithArray:datasource.sections];
    }
    return self;
    
}

@end