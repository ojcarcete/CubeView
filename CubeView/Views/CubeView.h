//
//  CubeView.h
//
//  Created by Jesse Boyes on 2/20/12.
//  Copyright (c) 2012 Jesse. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CubeOrientationVertical,
    CubeOrientationHorizontal
} CubeOrientation;

@class CubeView;
@protocol CubeViewDelegate <NSObject>

- (NSUInteger)numPagesForCubeView:(CubeView *)cubeView;
- (UIView *)viewForPage:(NSUInteger)page cubeView:(CubeView *)cubeView;

@optional

- (UIView *)topEdgePaneForCubeView:(CubeView *)cubeView;
- (UIView *)bottomEdgePaneForCubeView:(CubeView *)cubeView;

- (BOOL)supportsPullActionTop:(CubeView *)cubeView;
- (BOOL)supportsPullActionBottom:(CubeView *)cubeView;

- (void)pullTopActionTriggered:(CubeView *)cubeView topActionFrame:(CGRect)frame;

@end

@interface CubeView : UIView <UIScrollViewDelegate> {

}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *frontPane;
@property (nonatomic, strong) UIView *bottomPane;
@property (nonatomic, strong) UIView *topPane;
@property (nonatomic, strong) UIView *topEdgePane;
@property (nonatomic, strong) UIView *bottomEdgePane;

@property (nonatomic, strong) UIView *frontPaneShade;
@property (nonatomic, strong) UIView *bottomPaneShade;
@property (nonatomic, strong) UIView *topPaneShade;
@property (nonatomic, strong) UIView *topEdgePaneShade;
@property (nonatomic, strong) UIView *bottomEdgePaneShade;

@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) CubeOrientation orientation;
@property (nonatomic) BOOL scrollEnabled;

@property (nonatomic) BOOL topEdgeExtended;    //
@property (nonatomic) BOOL bottomEdgeExtended; // Whether the current edge has been extended for a pull-to-refresh action

@property (nonatomic, weak) id<CubeViewDelegate> delegate;


- (id)initWithFrame:(CGRect)frame delegate:(id<CubeViewDelegate>)del orientation:(CubeOrientation)co initialPage:(NSInteger)initialPage;

- (id)initWithFrame:(CGRect)frame delegate:(id<CubeViewDelegate>)del orientation:(CubeOrientation)co;

- (void)setTopEdgePaneHidden:(BOOL)hidden;

- (void)setCurrentPage:(NSUInteger)page;

- (void)scrollCubeViewToPreviousPage;

- (void)scrollCubeViewToNextPage;

- (void)reload;

@end
