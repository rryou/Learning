//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "ChattingCellContext.h"
#import "ChattingMessageCell.h"

@interface ChattingCellContext ()
{
    NSMutableDictionary *_classDict;
    NSMutableDictionary *_viewDict;
}
@end

@implementation ChattingCellContext

- (instancetype)init {
    self = [super init];
    if (self) {
        _classDict = [[NSMutableDictionary alloc] init];
        _viewDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerClass:(Class)viewClass forViewWithReuseIdentifier:(NSString *)identifier {
    if (viewClass && identifier) {
        [_classDict setObject:viewClass forKey:identifier];
    }
}

- (void)enqueueReusableView:(UIView<ReusableViewProtocol> *)reusableView {
    NSMutableArray *arr = [_viewDict objectForKey:reusableView.reuseIdentifier];
    if (arr == nil) {
        arr = [[NSMutableArray alloc] init];
        [_viewDict setObject:arr forKey:reusableView.reuseIdentifier];
    }
    [arr addObject:reusableView];
}

- (UIView<ReusableViewProtocol> *)dequeueReusableViewWithIdentifier:(NSString *)identifier {
    NSMutableArray *arr = [_viewDict objectForKey:identifier];
    UIView<ReusableViewProtocol> *view = [arr lastObject];
    CGSize sz = CGSizeMake(self.maxWidth, 60);
    if ([_delegate respondsToSelector:@selector(chattingCellContext:defaultSizeForViewWithIdentifier:)]) {
        sz = [_delegate chattingCellContext:self defaultSizeForViewWithIdentifier:identifier];
    }
    if (view) {
        [arr removeLastObject];
        [view prepareForReuse];
        view.frame = CGRectMake(0, 0, sz.width, sz.height);
    }
    else {
        Class clazz = [_classDict objectForKey:identifier];
        if (clazz) {
            view = [[clazz alloc] initWithFrame:CGRectMake(0, 0, sz.width, sz.height)];
            view.reuseIdentifier = identifier;
        }
    }
    return view;
}

- (void)willShowMenuInCell:(ChattingMessageCell *)cell {
    if (self.customResponderTextView &&[self.customResponderTextView isFirstResponder]) {
        self.customResponderTextView.overrideNextReponser = (id)cell;
    }else{
        [cell becomeFirstResponder];
    }
}

- (void)willHideMenuInCell:(ChattingMessageCell *)cell {
    if (self.customResponderTextView) {
        self.customResponderTextView.overrideNextReponser = nil;
    }
}

@end
