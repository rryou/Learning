//
//  MSCellModel.m
//  EMSpeed
//
//  Created by ryan on 15/7/31.
//
//

#import "MSCellFactory.h"
#import <UIKit/UIKit.h>

@implementation MSCellModel

@synthesize Class;
@synthesize reuseIdentify;
@synthesize height;
@synthesize isRegisterByClass;

- (instancetype)init {
    if (self = [super init]) {
        self.Class             = [UITableViewCell class];
        self.height            = 44;
        self.isRegisterByClass = YES;
    }
    return self;
}
//
//- (CGFloat)calculateHeightForTableView:(UITableView *)tableView
//{
//    static UITableViewCell *cell = nil;
//    if (cell == nil) {
//        cell = [tableView dequeueReusableCellWithCellModel:self];
//    }
//    return [self getCellHeight:cell];
//}
//
//
//- (CGFloat)getCellHeight:(UITableViewCell*)cell
//{
//    [cell layoutIfNeeded];
//    [cell updateConstraintsIfNeeded];
//    
//    CGFloat cheight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//    return cheight;
//}

@end


@implementation MSCellFactory

/**
 *
 *
 *  @param tableView
 *  @param indexPath
 *  @param model
 *
 *  @return
 */
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath cellModel:(MSCellModel *)model
{
    CGFloat height = tableView.rowHeight;
    Class cellClass = nil;
    
    if ([model respondsToSelector:@selector(cellClass)])
    {
        cellClass = [model cellClass];
    }
    else if ([model respondsToSelector:@selector(Class)]) {
        cellClass = [model Class];
    }
    
    if ([cellClass respondsToSelector:@selector(heightForObject:atIndexPath:tableView:)]) {
        CGFloat cellHeight = [cellClass heightForObject:model
                                            atIndexPath:indexPath tableView:tableView];
        if (cellHeight > 0) {
            height = cellHeight;
        }
    }
    return height;
}

+ (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withCellModel:(MSCellModel *)cellModel
{
    UINib *nib = nil;
    if ([cellModel respondsToSelector:@selector(cellNib)])
    {
        nib = [cellModel cellNib];
    }
    
    if (nib)
    {
        return [self cellWithNib:nib tableView:tableView indexPath:indexPath object:cellModel];
    }
    else if ([cellModel respondsToSelector:@selector(cellClass)])
    {
        Class cellClass = cellModel.cellClass;
        if (cellClass == NULL) {
            cellClass = [UITableViewCell class];
        }
        return [self cellWithClass:cellClass tableView:tableView indexPath:indexPath object:cellModel];
    }
    else
    {
        return [self oldversion_tableView:tableView cellForRowAtIndexPath:indexPath withCellModel:cellModel];
    }
}

+ (UITableViewCell *)cellWithClass:(Class)cellClass
                         tableView:(UITableView *)tableView
                         indexPath:(NSIndexPath *)indexPath
                            object:(id)cellModel {
    UITableViewCell* cell = nil;
    
    NSString* identifier = NSStringFromClass(cellClass);
    [tableView registerClass:cellClass forCellReuseIdentifier:identifier];
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (nil == cell) {
        UITableViewCellStyle style = UITableViewCellStyleDefault;
        cell = [[cellClass alloc] initWithStyle:style reuseIdentifier:identifier];
    }
    
   // Allow the cell to configure itself with the object's information.
    //更新cell的数据
    if ([cell respondsToSelector:@selector(update:indexPath:)]) {
        [(UITableViewCell<MSCellUpdating> *)cell update:cellModel indexPath:indexPath];
    }
    else if ([cell respondsToSelector:@selector(update:)]) {
        [(UITableViewCell<MSCellUpdating> *)cell update:cellModel];
    }
    
    return cell;
}

+ (UITableViewCell *)cellWithNib:(UINib *)cellNib
                       tableView:(UITableView *)tableView
                       indexPath:(NSIndexPath *)indexPath
                          object:(id)cellModel {
    UITableViewCell* cell = nil;
    
    NSString* identifier = NSStringFromClass([cellModel class]);
    [tableView registerNib:cellNib forCellReuseIdentifier:identifier];
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    //Allow the cell to configure itself with the object's information.
    //更新cell的数据
    if ([cell respondsToSelector:@selector(update:indexPath:)]) {
        [(UITableViewCell<MSCellUpdating> *)cell update:cellModel indexPath:indexPath];
    }
    else if ([cell respondsToSelector:@selector(update:)]) {
        [(UITableViewCell<MSCellUpdating> *)cell update:cellModel];
    }
    
    return cell;
}

+ (UITableViewCell *)oldversion_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withCellModel:(MSCellModel *)cellModel
{
    Class cellClass = NULL;
    if ([cellModel respondsToSelector:@selector(Class)])
    {//兼容旧版本
        cellClass = cellModel.Class;
    }
    
    UINib *nib = nil;
    
    if (cellClass && cellModel.isRegisterByClass == NO)
    {
        nib = [UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil];
    }
    
    if (nib)
    {
        UITableViewCell* cell = nil;
        
        NSString* identifier = NSStringFromClass([cellModel Class]);
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        //Allow the cell to configure itself with the object's information.
        //更新cell的数据
        if ([cell respondsToSelector:@selector(update:indexPath:)]) {
            [(UITableViewCell<MSCellUpdating> *)cell update:cellModel indexPath:indexPath];
        }
        else if ([cell respondsToSelector:@selector(update:)]) {
            [(UITableViewCell<MSCellUpdating> *)cell update:cellModel];
        }
        
        return cell;
    }
    else
    {
        if (cellClass == NULL) {
            cellClass = [UITableViewCell class];
        }
        return [self cellWithClass:cellClass tableView:tableView indexPath:indexPath object:cellModel];
    }
}

@end


