//
//  EMLocalSocketManaget.h
//  EmomeyIM
//
//  Created by 尤荣荣 on 16/8/16.
//  Copyright © 2016年 frank. All rights reserved.
//


#import "ChattingMessageCell.h"

@implementation ChattingMessageCell

static NSArray *g_chatting_cell_actions;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentFrameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [self.bodyView addSubview:_contentFrameView];
        _contentFrameView.backgroundColor = [UIColor clearColor];
        
        _bubbleImageView = [[UIImageView alloc] initWithFrame:_contentFrameView.bounds];
        [_contentFrameView addSubview:_bubbleImageView];
        _bubbleImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _contentContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_contentFrameView addSubview:_contentContainerView];
        _contentContainerView.backgroundColor = [UIColor clearColor];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionLongPress:)];
        [_contentFrameView addGestureRecognizer:longPress];
    }
    return self;
}

- (void)actionLongPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        ChattingCollectionView *chattingCollectionView = self.cellContext.chattingCollectionView;
        if ([chattingCollectionView.delegate respondsToSelector:@selector(collectionView:menuItemsOnLongPressingBubbleViewInCell:)]) {
            NSArray *items = [chattingCollectionView.delegate collectionView:chattingCollectionView menuItemsOnLongPressingBubbleViewInCell:self];
            if ([items count] > 0){
                if ([self.cellContext.delegate respondsToSelector:@selector(chattingCellisAbleSupportChangeResponder)]) {
                    if ([self.cellContext.delegate chattingCellisAbleSupportChangeResponder]) {
                        [self.cellContext willShowMenuInCell:self];
                    }
                    
                }else{
                   [self becomeFirstResponder];
                }
            }
                CGRect r = [self.contentFrameView convertRect:self.contentFrameView.bounds toView:chattingCollectionView];
                r = CGRectIntersection(r, chattingCollectionView.bounds);
                UIMenuController *menu = [UIMenuController sharedMenuController];
                [menu setTargetRect:r inView:chattingCollectionView];
                
                NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:[items count]];
                for (int i = 0; i < [items count]; i++) {
                    ChattingCellAction *action = items[i];
                    NSString *selString = [NSString stringWithFormat:@"loocha_cell_bubble_menu__%d", i];
                    SEL selector = NSSelectorFromString(selString);
                    [menuItems addObject:[[UIMenuItem alloc] initWithTitle:action.title action:selector]];
                }
                menu.menuItems = menuItems;
                [menu setMenuVisible:YES animated:YES];
                
                g_chatting_cell_actions = items;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerWillHideMenu:) name:UIMenuControllerWillHideMenuNotification object:nil];
           // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerDidHideMenu:) name:UIMenuControllerDidHideMenuNotification object:nil];
        }
    }
}

- (void)loocha_cell_bubble_menu {
    // do nothing
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSString *selString = NSStringFromSelector(aSelector);
    if ([selString hasPrefix:@"loocha_cell_bubble_menu__"]) {
        return [super methodSignatureForSelector:@selector(loocha_cell_bubble_menu)];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSString *selString = NSStringFromSelector(anInvocation.selector);
    if ([selString hasPrefix:@"loocha_cell_bubble_menu__"]) {
        int index = [[[selString componentsSeparatedByString:@"__"] lastObject] intValue];
        if (index >= 0 && index < [g_chatting_cell_actions count]) {
            ChattingCellAction *action = g_chatting_cell_actions[index];
            [action excute];
        }
        return;
    }
    return[super forwardInvocation:anInvocation];
}

- (void)menuControllerWillHideMenu:(NSNotification *)noti {
    g_chatting_cell_actions = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    if ([self.cellContext.delegate respondsToSelector:@selector(chattingCellisAbleSupportChangeResponder)]) {
        [self.cellContext willHideMenuInCell:self];
    }
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    NSString *selString = NSStringFromSelector(action);
    return [selString hasPrefix:@"loocha_cell_bubble_menu__"];
}

- (void)prepareChattingContentViewForReuse {
    if (_chattingContentView) {
        [_chattingContentView removeFromSuperview];
        [self.cellContext enqueueReusableView:_chattingContentView];
        _chattingContentView = nil;
    }
}

- (void)prepareChattingBottomContentViewForReuse {
    if (_chattingBottomContentView) {
        [_chattingBottomContentView removeFromSuperview];
        [self.cellContext enqueueReusableView:_chattingBottomContentView];
        _chattingBottomContentView = nil;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self prepareChattingContentViewForReuse];
    [self prepareChattingBottomContentViewForReuse];
}

- (void)setChattingContentView:(UIView<ReusableViewProtocol> *)chattingContentView {
    if (_chattingContentView != chattingContentView) {
        [self prepareChattingContentViewForReuse];
        
        _chattingContentView = chattingContentView;
        [_contentContainerView addSubview:_chattingContentView];
    }
}

- (void)setChattingBottomContentView:(UIView<ReusableViewProtocol> *)chattingBottomContentView {
    if (_chattingBottomContentView != chattingBottomContentView) {
        [self prepareChattingBottomContentViewForReuse];
        
        _chattingBottomContentView = chattingBottomContentView;
        [self.bottomView addSubview:_chattingBottomContentView];
    }
}

@end
