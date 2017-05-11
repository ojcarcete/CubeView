//
//  CubeView.m
//
//  Created by Jesse Boyes on 2/20/12.
//  Copyright (c) 2012 Jesse. All rights reserved.
//

#import "CubeView.h"
#import <QuartzCore/QuartzCore.h>

#define kPullActionThreshold 80

@interface CubeView (Private)

- (void)performInitialLayout;
- (void)layoutPanes;
- (void)setupContentSize;
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;

@end

@interface CubeView ()

@property (nonatomic) NSUInteger initialPage;

@end

@implementation CubeView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame delegate:(id<CubeViewDelegate>)del orientation:(CubeOrientation)co initialPage:(NSInteger)initialPage
{
    self = [self initWithFrame:frame delegate:del orientation:co];

    if (self)
    {
        self.initialPage = initialPage;
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<CubeViewDelegate>)del orientation:(CubeOrientation)co
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = del;
        self.orientation = co;
        self.initialPage = 0;
        self.scrollEnabled = YES;
        [self performSelectorOnMainThread:@selector(performInitialLayout) withObject:nil waitUntilDone:NO];
    }
    return self;
}

- (void)performInitialLayout
{
    // Initialization code
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.scrollEnabled = self.scrollEnabled;
    self.scrollView.delegate = self;
    [self setupContentSize];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    self.frontPane = [self.delegate viewForPage:0 cubeView:self];

    if ([self.delegate numPagesForCubeView:self] > 1) {
        self.bottomPane = [self.delegate viewForPage:1 cubeView:self];
    }

    self.scrollView.layer.contentsScale = [[UIScreen mainScreen] scale];
    [self layoutPanes];

    [self setCurrentPage:self.initialPage];
}

- (void)reload
{
    [self setupContentSize];
    [self.frontPane removeFromSuperview];
    [self.topPane removeFromSuperview];
    [self.bottomPane removeFromSuperview];
    [self.frontPaneShade removeFromSuperview];
    [self.topPaneShade removeFromSuperview];
    [self.bottomPaneShade removeFromSuperview];
    self.bottomPane = nil;
    self.topPane = nil;
    self.frontPaneShade = nil;
    self.bottomPaneShade = nil;
    self.topPaneShade = nil;

    self.frontPane = [self.delegate viewForPage:self.currentPage cubeView:self];
    if (self.currentPage > 0) {
        self.topPane = [self.delegate viewForPage:self.currentPage-1 cubeView:self];
    }
    if (self.currentPage < [self.delegate numPagesForCubeView:self]-1) {
        self.bottomPane = [self.delegate viewForPage:self.currentPage+1 cubeView:self];
    }

    [self.topEdgePane removeFromSuperview];
    self.topEdgePane = nil;
    [self.bottomEdgePane removeFromSuperview];
    self.bottomEdgePane = nil;
    [self layoutPanes];
}

- (void)setupContentSize
{
    if (self.orientation == CubeOrientationVertical) {
        if ([self.delegate numPagesForCubeView:self] > 2) {
            self.scrollView.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height * 3);
        } else {
            self.scrollView.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height * 2);
        }
    } else {
        if ([self.delegate numPagesForCubeView:self] > 2) {
            self.scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        } else {
            self.scrollView.contentSize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height);
        }
    }
    
}

- (void)layoutPanes
{
    NSUInteger max = [self.delegate numPagesForCubeView:self];
    // only one of startX or startY will be used, based on orientation.
    CGFloat startX = 0.0, startY = 0.0;

    if (self.orientation == CubeOrientationHorizontal) {
        if (self.currentPage >= max-1) {
            startX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
        } else if (self.currentPage > 0) {
            startX = self.scrollView.bounds.size.width;
        }
    } else {
        if (self.currentPage >= max-1) {
            startY = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
        } else if (self.currentPage > 0) {
            startY = self.scrollView.bounds.size.height;
        }
    }

    if (self.topPane) {
        if (self.orientation == CubeOrientationHorizontal) {
            self.topPane.layer.anchorPoint = CGPointMake(1.0, 0.5);
            self.topPane.frame = CGRectMake(startX - self.topPane.bounds.size.width, 0.0, self.topPane.bounds.size.width, self.topPane.bounds.size.height);
        } else {
            self.topPane.layer.anchorPoint = CGPointMake(0.5, 1.0);
            self.topPane.frame = CGRectMake(0.0, startY - self.topPane.bounds.size.height, self.topPane.bounds.size.width, self.topPane.bounds.size.height);
        }
        [self.scrollView addSubview:self.topPane];
        if (!self.topPaneShade || !self.topPaneShade.superview) {
            self.topPaneShade = [[UIView alloc] initWithFrame:self.topPane.bounds];
            self.topPaneShade.backgroundColor = [UIColor blackColor];
            [self.topPane addSubview:self.topPaneShade];
        }
    }

    if (self.orientation == CubeOrientationHorizontal) {
        self.frontPane.layer.anchorPoint = CGPointMake(1.0, 0.5);
        self.frontPane.frame = CGRectMake(startX, 0.0, self.frontPane.bounds.size.width, self.frontPane.bounds.size.height);
    } else {
        self.frontPane.layer.anchorPoint = CGPointMake(0.5, 1.0);
        self.frontPane.frame = CGRectMake(0.0, startY, self.frontPane.bounds.size.width, self.frontPane.bounds.size.height);
    }
    [self.scrollView addSubview:self.frontPane];

    if (self.bottomPane) {
        if (self.orientation == CubeOrientationHorizontal) {
            self.bottomPane.layer.anchorPoint = CGPointMake(0.0, 0.5);
            self.bottomPane.frame = CGRectMake(startX + self.bottomPane.bounds.size.width, 0.0, self.bottomPane.bounds.size.width, self.bottomPane.bounds.size.height);
        } else {
            self.bottomPane.layer.anchorPoint = CGPointMake(0.5, 0.0);
            self.bottomPane.frame = CGRectMake(0.0, startY + self.bottomPane.bounds.size.height, self.bottomPane.bounds.size.width, self.bottomPane.bounds.size.height);
        }
        [self.scrollView addSubview:self.bottomPane];
        if (!self.bottomPaneShade || !self.bottomPaneShade.superview) {
            self.bottomPaneShade = [[UIView alloc] initWithFrame:self.bottomPane.bounds];
            self.bottomPaneShade.backgroundColor = [UIColor blackColor];
            [self.bottomPane addSubview:self.bottomPaneShade];
        }
    }

    if (!self.frontPaneShade || !self.frontPaneShade.superview) {
        self.frontPaneShade = [[UIView alloc] initWithFrame:self.frontPane.bounds];
        self.frontPaneShade.backgroundColor = [UIColor blackColor];
    }

    if (self.currentPage == 0 && !self.topEdgePane && [self.delegate respondsToSelector:@selector(topEdgePaneForCubeView:)]) {
        self.topEdgePane = [self.delegate topEdgePaneForCubeView:self];
        if (self.orientation == CubeOrientationHorizontal) {
            self.topEdgePane.layer.anchorPoint = CGPointMake(1.0, 0.5);
            self.topEdgePane.frame = CGRectMake(-self.topEdgePane.bounds.size.width, 0, self.topEdgePane.bounds.size.width, self.topEdgePane.bounds.size.height);
        } else {
            self.topEdgePane.layer.anchorPoint = CGPointMake(0.5, 1.0);
            self.topEdgePane.frame = CGRectMake(0, -self.topEdgePane.bounds.size.height, self.topEdgePane.bounds.size.width, self.topEdgePane.bounds.size.height);
        }
        [self.scrollView addSubview:self.topEdgePane];
    } else if (self.currentPage == max-1 && !self.bottomEdgePane && [self.delegate respondsToSelector:@selector(bottomEdgePaneForCubeView:)]) {
        self.bottomEdgePane = [self.delegate bottomEdgePaneForCubeView:self];
        if (self.orientation == CubeOrientationHorizontal) {
            self.bottomEdgePane.layer.anchorPoint = CGPointMake(0.0, 0.5);
            self.bottomEdgePane.frame = CGRectMake(self.scrollView.contentSize.width, 0, self.bottomEdgePane.bounds.size.width, self.bottomEdgePane.bounds.size.height);
        } else {
            self.bottomEdgePane.layer.anchorPoint = CGPointMake(0.5, 0.0);
            self.bottomEdgePane.frame = CGRectMake(0, self.scrollView.contentSize.height, self.bottomEdgePane.bounds.size.width, self.bottomEdgePane.bounds.size.height);
        }
        [self.scrollView addSubview:self.bottomEdgePane];
    }

    self.scrollView.contentOffset = CGPointMake(startX, startY);
}

- (void)setTopEdgePaneHidden:(BOOL)hidden
{
    self.topEdgePane.hidden = hidden;
}

- (void)setCurrentPage:(NSUInteger)page
{
    _currentPage = page;
    [self reload];
}

- (void)scrollCubeViewToPreviousPage
{
    if (self.currentPage <= 0)
    {
        return;
    }

    CGPoint previousContentPageOffset = CGPointZero;

    [self.scrollView setContentOffset:previousContentPageOffset animated:YES];
}

- (void)scrollCubeViewToNextPage
{
    if (self.currentPage >= ([self.delegate numPagesForCubeView:self] - 1))
    {
        return;
    }

    CGPoint nextPageContentOffset = CGPointZero;

    if (self.orientation == CubeOrientationHorizontal)
    {
        nextPageContentOffset = CGPointMake(self.scrollView.bounds.size.width, 0);
    }
    else if (self.orientation == CubeOrientationVertical)
    {
        nextPageContentOffset = CGPointMake(0, self.scrollView.bounds.size.height);
    }

    [self.scrollView setContentOffset:nextPageContentOffset animated:YES];
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

#pragma mark - Scroll Configuration

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    _scrollEnabled = scrollEnabled;

    self.scrollView.scrollEnabled = _scrollEnabled;
}

#pragma mark - ScrollViewDelegate methods

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)sv
{
    // TODO: Set up to arrive at the top of the content here.
    return YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)sv
{
    if (self.orientation == CubeOrientationHorizontal) {
        CALayer *layer;
        CATransform3D xRotationTransform;

        CGFloat frontPaneOffset = 0;
        if (self.currentPage == 0) {
            frontPaneOffset = 0;
        } else {
            if (self.currentPage >= [self.delegate numPagesForCubeView:self]-1) {
                frontPaneOffset = sv.contentSize.width - sv.bounds.size.width;
            } else {
                frontPaneOffset = sv.bounds.size.width;
            }
        }
        
        // Set up appropriate anchors for front pane.
        // n.b. Changing the anchorPoint will move the view, so save and restore the frame.
        if (frontPaneOffset - sv.contentOffset.x > 0 && self.frontPane.layer.anchorPoint.x != 0.0) {
            [self setAnchorPoint:CGPointMake(0.0, 0.5) forView:self.frontPane];
        } else if (frontPaneOffset - sv.contentOffset.x < 0 && self.frontPane.layer.anchorPoint.x != 1.0) {
            [self setAnchorPoint:CGPointMake(1.0, 0.5) forView:self.frontPane];
        }
        
        // Top panel rotation
        if (self.topPane != nil) {
            CGFloat topAngle = (((sv.contentOffset.x - (frontPaneOffset - sv.bounds.size.width))/sv.bounds.size.width) * 90.0);
            layer = self.topPane.layer;
            xRotationTransform = sv.layer.transform;
            xRotationTransform.m34 = 1.0 / -500;
            xRotationTransform = CATransform3DRotate(xRotationTransform, topAngle * M_PI / 180.0f, 0.0f, -1.0f, 0.0f);
            layer.transform = xRotationTransform;
        }

        // Scrolling down
        // Front panel rotation
        CGFloat frontAngle = -(((sv.bounds.size.width-(sv.contentOffset.x - frontPaneOffset))/sv.bounds.size.width) * 90.0) + 90.0;
        layer = self.frontPane.layer;
        xRotationTransform = sv.layer.transform;
        xRotationTransform.m34 = 1.0 / -500;
        xRotationTransform = CATransform3DRotate(xRotationTransform, frontAngle * M_PI / 180.0f, 0.0f, -1.0f, 0.0f);
        layer.transform = xRotationTransform;
        
        // Bottom panel rotation
        if (self.bottomPane != nil) {
            CGFloat bottomAngle = -(((sv.bounds.size.width-(sv.contentOffset.x - frontPaneOffset))/sv.bounds.size.width) * 90.0);
            layer = self.bottomPane.layer;
            xRotationTransform = sv.layer.transform;
            xRotationTransform.m34 = 1.0 / -500;
            xRotationTransform = CATransform3DRotate(xRotationTransform, bottomAngle * M_PI / 180.0f, 0.0f, -1.0f, 0.0f);
            layer.transform = xRotationTransform;
        }

        // Edges
        if (self.topEdgePane != nil) {
            CGFloat edgeAngle = 180.0-(((sv.bounds.size.width-(sv.contentOffset.x - frontPaneOffset))/sv.bounds.size.width) * 90.0);
            layer = self.topEdgePane.layer;
            xRotationTransform = sv.layer.transform;
            xRotationTransform.m34 = 1.0 / -500;
            xRotationTransform = CATransform3DRotate(xRotationTransform, edgeAngle * M_PI / 180.0f, 0.0f, -1.0f, 0.0f);
            layer.transform = xRotationTransform;
        } else if (self.bottomEdgePane != nil) {
            CGFloat edgeAngle = -(((sv.bounds.size.width-(sv.contentOffset.x - frontPaneOffset))/sv.bounds.size.width) * 90.0);
            layer = self.bottomEdgePane.layer;
            xRotationTransform = sv.layer.transform;
            xRotationTransform.m34 = 1.0 / -500;
            xRotationTransform = CATransform3DRotate(xRotationTransform, edgeAngle * M_PI / 180.0f, 0.0f, -1.0f, 0.0f);
            layer.transform = xRotationTransform;
        }

        // Adjust shading
        if (!self.frontPaneShade.superview) {
            [self.frontPaneShade removeFromSuperview];
            [self.frontPane addSubview:self.frontPaneShade];
        }
        self.bottomPaneShade.alpha = (self.bottomPane.frame.origin.x - sv.contentOffset.x)/sv.bounds.size.width;
        self.topPaneShade.alpha = (sv.contentOffset.x - (frontPaneOffset - sv.bounds.size.height))/sv.bounds.size.width;
        self.frontPaneShade.alpha = ABS(sv.contentOffset.x - frontPaneOffset)/sv.bounds.size.width;
    } else { // Vertically-oriented rotation
        CALayer *layer;
        CATransform3D yRotationTransform;
        
        CGFloat frontPaneOffset = 0;
        if (self.currentPage == 0) {
            frontPaneOffset = 0;
        } else if (self.currentPage >= [self.delegate numPagesForCubeView:self]-1) {
            frontPaneOffset = sv.contentSize.height - sv.bounds.size.height;
        } else {
            frontPaneOffset = sv.bounds.size.height;
        }
        
        // Set up appropriate anchors for front pane.
        // n.b. Changing the anchorPoint will move the view, so save and restore the frame.
        if (frontPaneOffset - sv.contentOffset.y > 0 && self.frontPane.layer.anchorPoint.y != 0.0) {
            [self setAnchorPoint:CGPointMake(0.5, 0.0) forView:self.frontPane];
        } else if (frontPaneOffset - sv.contentOffset.y < 0 && self.frontPane.layer.anchorPoint.y != 1.0) {
            [self setAnchorPoint:CGPointMake(0.5, 1.0) forView:self.frontPane];
        }
        
        // Top panel rotation
        if (self.topPane != nil) {
            CGFloat topAngle = (((sv.contentOffset.y - (frontPaneOffset - sv.bounds.size.height))/sv.bounds.size.height) * 90.0);
            layer = self.topPane.layer;
            yRotationTransform = sv.layer.transform;
            yRotationTransform.m34 = 1.0 / -500;
            yRotationTransform = CATransform3DRotate(yRotationTransform, topAngle * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
            layer.transform = yRotationTransform;
        }
        
        // Scrolling down
        // Front panel rotation
        CGFloat frontAngle = -(((sv.bounds.size.height-(sv.contentOffset.y - frontPaneOffset))/sv.bounds.size.height) * 90.0) + 90.0;
        layer = self.frontPane.layer;
        yRotationTransform = sv.layer.transform;
        yRotationTransform.m34 = 1.0 / -500;
        yRotationTransform = CATransform3DRotate(yRotationTransform, frontAngle * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
        layer.transform = yRotationTransform;

        // Bottom panel rotation
        if (self.bottomPane != nil) {
            CGFloat bottomAngle = -(((sv.bounds.size.height-(sv.contentOffset.y - frontPaneOffset))/sv.bounds.size.height) * 90.0);
            layer = self.bottomPane.layer;
            yRotationTransform = sv.layer.transform;
            yRotationTransform.m34 = 1.0 / -500;
            yRotationTransform = CATransform3DRotate(yRotationTransform, bottomAngle * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
            layer.transform = yRotationTransform;
        }

        // Edges
        if (self.topEdgePane != nil) {
            layer = self.topEdgePane.layer;
            // Check pull-action threshold and unfold the view if we're past it.
            if ([self.delegate respondsToSelector:@selector(supportsPullActionTop:)] && [self.delegate supportsPullActionTop:self] && sv.contentOffset.y < -kPullActionThreshold) {
                if (!self.topEdgeExtended) {
                    [UIView animateWithDuration:0.2 animations:^(void) {
                        layer.transform = sv.layer.transform;
                    }];
                    self.topEdgeExtended = YES;
                }
            } else {
                if (self.topEdgeExtended) {
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:0.2];
                }
                CGFloat edgeAngle = 180.0-(((sv.bounds.size.height-(sv.contentOffset.y - frontPaneOffset))/sv.bounds.size.height) * 90.0);
                yRotationTransform = sv.layer.transform;
                yRotationTransform.m34 = 1.0 / -500;
                yRotationTransform = CATransform3DRotate(yRotationTransform, edgeAngle * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
                layer.transform = yRotationTransform;
                if (self.topEdgeExtended) {
                    [UIView commitAnimations];
                    self.topEdgeExtended = NO;
                }
            }
        } else if (self.bottomEdgePane != nil) {
            layer = self.bottomEdgePane.layer;
            // Check pull-action threshold and unfold the view if we're past it.
            if ([self.delegate respondsToSelector:@selector(supportsPullActionTop:)] && [self.delegate supportsPullActionTop:self] &&
                sv.contentOffset.y > (sv.contentSize.height - sv.bounds.size.height + kPullActionThreshold)) {
                if (!self.bottomEdgeExtended) {
                    [UIView animateWithDuration:0.2 animations:^(void) {
                        layer.transform = sv.layer.transform;
                    }];
                    self.bottomEdgeExtended = YES;
                }
            } else {
                if (self.bottomEdgeExtended) {
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:0.2];
                }
                CGFloat edgeAngle = -(((sv.bounds.size.height-(sv.contentOffset.y - frontPaneOffset))/sv.bounds.size.height) * 90.0);
                yRotationTransform = sv.layer.transform;
                yRotationTransform.m34 = 1.0 / -500;
                yRotationTransform = CATransform3DRotate(yRotationTransform, edgeAngle * M_PI / 180.0f, 1.0f, 0.0f, 0.0f);
                layer.transform = yRotationTransform;
                if (self.bottomEdgeExtended) {
                    [UIView commitAnimations];
                    self.bottomEdgeExtended = NO;
                }
            }
        }

        
        
        // Adjust shading
        if (!self.frontPaneShade.superview) {
            [self.frontPaneShade removeFromSuperview];
            [self.frontPane addSubview:self.frontPaneShade];
        }
        self.bottomPaneShade.alpha = (self.bottomPane.frame.origin.y - sv.contentOffset.y)/sv.bounds.size.height;
        self.topPaneShade.alpha = (sv.contentOffset.y - (frontPaneOffset - sv.bounds.size.height))/sv.bounds.size.height;
        self.frontPaneShade.alpha = ABS(sv.contentOffset.y - frontPaneOffset)/sv.bounds.size.height;
    }

    // Check for page crossovers
    NSUInteger max = [self.delegate numPagesForCubeView:self];
    // Up a page
    if ((self.orientation == CubeOrientationVertical && ((self.scrollView.contentOffset.y <= 0.0 && self.currentPage > 0) ||
                                                     (self.scrollView.contentOffset.y <= self.scrollView.bounds.size.height && self.self.currentPage == max-1 && max > 2))) ||
        (self.orientation == CubeOrientationHorizontal && ((self.scrollView.contentOffset.x <= 0.0 && self.currentPage > 0) ||
                                                       (self.scrollView.contentOffset.x <= self.scrollView.bounds.size.width && self.currentPage == max-1 && max > 2))))
    {
        [self pageUp];
    } 
    // Down a page
    else if ((self.orientation == CubeOrientationVertical && ((self.scrollView.contentOffset.y >= self.scrollView.bounds.size.height*2) ||
                                                          (self.scrollView.contentOffset.y >= self.scrollView.bounds.size.height && self.currentPage == 0))) ||
             (self.orientation == CubeOrientationHorizontal && ((self.scrollView.contentOffset.x >= self.scrollView.bounds.size.width*2) ||
                                                            (self.scrollView.contentOffset.x >= self.scrollView.bounds.size.width && self.currentPage == 0))))
    {
        [self pageDown];
    }
}

- (void)resetTransforms
{
    // Weird.  But resetting the transforms after a successful scroll seems to fix a lot of quirky geometry issues.
    self.frontPane.layer.transform = self.scrollView.layer.transform;
    self.topPane.layer.transform = self.scrollView.layer.transform;
    self.bottomPane.layer.transform = self.scrollView.layer.transform;
}

- (void)pageUp
{
    // Get out of the way of touch interactions
    [self.frontPaneShade removeFromSuperview];
    
    [self.frontPane removeFromSuperview];
    [self.topPane removeFromSuperview];
    [self.bottomPane removeFromSuperview];
    [self.frontPaneShade removeFromSuperview];
    [self.topPaneShade removeFromSuperview];
    [self.bottomPaneShade removeFromSuperview];
    [self.bottomEdgePane removeFromSuperview];
    self.bottomEdgePane = nil;
    
    _currentPage--;
    self.bottomPane = self.frontPane;
    self.frontPane = self.topPane;

    if (self.currentPage > 0) {
        self.topPane = [self.delegate viewForPage:self.currentPage-1 cubeView:self];
    } else {
        self.topPane = nil;
    }
    [self layoutPanes];

    [self resetTransforms];
}

- (void)pageDown
{
    NSUInteger max = [self.delegate numPagesForCubeView:self];

    // Get out of the way of touch interactions
    [self.frontPaneShade removeFromSuperview];
    
    if (self.currentPage < max-1) {
        [self.frontPane removeFromSuperview];
        [self.topPane removeFromSuperview];
        [self.bottomPane removeFromSuperview];
        [self.frontPaneShade removeFromSuperview];
        [self.topPaneShade removeFromSuperview];
        [self.bottomPaneShade removeFromSuperview];
        [self.topEdgePane removeFromSuperview];
        self.topEdgePane = nil;
        
        _currentPage++;
        self.topPane = self.frontPane;
        self.frontPane = self.bottomPane;
        if (self.currentPage < max-1) {
            self.bottomPane = [self.delegate viewForPage:self.currentPage+1 cubeView:self];
        } else {
            self.bottomPane = nil;
        }
        [self layoutPanes];
    }

    [self resetTransforms];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.topEdgeExtended) {
        self.topEdgeExtended = NO;
        [self.delegate pullTopActionTriggered:self topActionFrame:[self.topEdgePane convertRect:self.topEdgePane.frame toView:self.superview]];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self isOnCurrentPageOffset])
    {
        [self resetTransforms];
    }
    else
    {
        [self adjustContentOffsetForCurrentPage];
    }
}

- (BOOL)isOnCurrentPageOffset
{
    CGPoint currentPageContentOffset = [self getCurrentPageContentOffset];

    return CGPointEqualToPoint(self.scrollView.contentOffset, currentPageContentOffset);
}

- (void)adjustContentOffsetForCurrentPage
{
    CGPoint currentPageContentOffset = [self getCurrentPageContentOffset];

    [self.scrollView setContentOffset:currentPageContentOffset animated:YES];
}

- (CGPoint)getCurrentPageContentOffset
{
    CGPoint currentPageContentOffset = CGPointZero;

    if (self.orientation == CubeOrientationHorizontal)
    {
        currentPageContentOffset = CGPointMake(self.currentPage * self.scrollView.bounds.size.width, 0);
    }
    else if (self.orientation == CubeOrientationVertical)
    {
        currentPageContentOffset = CGPointMake(0, self.currentPage * self.scrollView.bounds.size.height);
    }

    return currentPageContentOffset;
}

@end
