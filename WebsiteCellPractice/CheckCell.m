//
//  CheckCell.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/28.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//
#define MARGIN 2
#import "CheckCell.h"
#import "Receipt.h"
#import <QuartzCore/QuartzCore.h>

static UIImage *deleteButtonImg;
@implementation CheckCell

@synthesize isQuivering,lineOne,lineTwo,lineThree,lineFour,deleteButton,cellNameLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"CheckCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
    }
    
    UIView *insetView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, self.bounds.size.width/12, self.bounds.size.height/12)];
    [self.contentView addSubview:insetView];
    self.cellNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, insetView.frame.size.width, insetView.frame.size.height)];
    self.cellNameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight;
    self.cellNameLabel.textAlignment = NSTextAlignmentCenter;
    self.cellNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    float dim = MIN(self.cellNameLabel.bounds.size.width, self.cellNameLabel.bounds.size.height);
    self.cellNameLabel.clipsToBounds = YES;
    self.cellNameLabel.layer.cornerRadius = dim/8;
    [insetView addSubview:self.cellNameLabel];
    
    //Setup the delete button
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/28, self.frame.size.width/28, self.frame.size.width/4, self.frame.size.width/4)];
    if (!deleteButtonImg)
    {
        CGRect buttonFrame = self.deleteButton.frame;
        UIGraphicsBeginImageContext(buttonFrame.size);
        CGFloat sz = MIN(buttonFrame.size.width, buttonFrame.size.height);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(buttonFrame.size.width/2, buttonFrame.size.height/2) radius:sz/2-MARGIN startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        [path moveToPoint:CGPointMake(MARGIN, MARGIN)];
        [path addLineToPoint:CGPointMake(sz-MARGIN, sz-MARGIN)];
        [path moveToPoint:CGPointMake(MARGIN, sz-MARGIN)];
        [path addLineToPoint:CGPointMake(sz-MARGIN, MARGIN)];
        [[UIColor redColor] setFill];
        [[UIColor whiteColor] setStroke];
        [path setLineWidth:3.0];
        [path fill];
        [path stroke];
        deleteButtonImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [self.deleteButton setImage:deleteButtonImg forState:UIControlStateNormal];
    [self.contentView addSubview:self.deleteButton];
    [self.deleteButton setHidden:YES];
    self.isQuivering = NO;
    return self;
}

- (void)startQuivering
{
    CABasicAnimation *quiverAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    float startAngle = (-2) * M_PI/180.0;
    float stopAngle = -startAngle;
    quiverAnim.fromValue = [NSNumber numberWithFloat:startAngle];
    quiverAnim.toValue = [NSNumber numberWithFloat:3 * stopAngle];
    quiverAnim.autoreverses = YES;
    quiverAnim.duration = 0.2;
    quiverAnim.repeatCount = HUGE_VALF;
    float timeOffset = (float)(arc4random() % 100)/100 - 0.50;
    quiverAnim.timeOffset = timeOffset;
    CALayer *layer = self.layer;
    [layer addAnimation:quiverAnim forKey:@"quivering"];
    isQuivering = YES;
    [self.deleteButton setHidden:NO];
    
}
- (void)stopQuivering
{
    CALayer *layer = self.layer;
    [layer removeAnimationForKey:@"quivering"];
    isQuivering = NO;
    for (UIView *subView in [self.contentView subviews]) {
        if ([subView isEqual:self.deleteButton]) {
            [self.deleteButton setHidden:YES];
        }
    }
}

- (void)setInitialDisplayForAddACheck{
    self.cellNameLabel.numberOfLines = 2;
    self.cellNameLabel.layer.opacity = 0.7;
    self.cellNameLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cellNameLabel.layer.borderWidth = 3.0f;
    self.cellNameLabel.backgroundColor = [UIColor lightGrayColor];
    self.cellNameLabel.text = @"Tap to add split check";
    self.cellNameLabel.textColor = [UIColor blackColor];
    self.cellNameLabel.font = [UIFont fontWithName:@"Helvetica-Light" size: 13.0];
}

- (void)setInitialDisplayForSplitCheckCellAtIndexRow:(int)indexRow{
    [self.deleteButton setHidden:YES];
    self.cellNameLabel.layer.opacity = 1.0;
    self.cellNameLabel.numberOfLines = 4;
    self.cellNameLabel.layer.borderColor = [UIColor grayColor].CGColor;
    self.cellNameLabel.layer.borderWidth = 3.0f;
    self.cellNameLabel.backgroundColor = [UIColor whiteColor];
    self.cellNameLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%i",@"#",indexRow+1]];
    self.cellNameLabel.textColor = [UIColor blackColor];
    self.cellNameLabel.font = [UIFont fontWithName:@"Helvetica-Light" size: 12.0];
}

- (void)updateDisplay:(Receipt *)receiptToBeUpdated atIndexPathRow:(int)indexPathRow{
    if (receiptToBeUpdated.grandTotalValue != 0) {
        self.lineOne = [NSString stringWithFormat:@"#%i",indexPathRow+1];
        self.lineTwo = [NSString stringWithFormat:@"%@%i",@"Items: ",[receiptToBeUpdated getNumberOfItemsInReceipt]];
        self.lineThree = [NSString stringWithFormat:@"S: $%.02f",receiptToBeUpdated.subTotalValue];
        self.lineFour =  [NSString stringWithFormat:@"T: $%.02f",
                          receiptToBeUpdated.grandTotalValue];
        NSMutableAttributedString *cellDisplayInfo = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@\n%@\n%@",self.lineOne,self.lineTwo,self.lineThree,self.lineFour]];
        [cellDisplayInfo setAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica-Light" size: 11.0] forKey:NSFontAttributeName] range:(NSRange){0,[cellDisplayInfo length]}];
        
        //[cellDisplayInfo setAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica-Bold" size: 11.0] forKey:NSFontAttributeName] range:(NSRange){2,7}];
        //[cellDisplayInfo setAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica-Bold" size: 11.0] forKey:NSFontAttributeName] range:(NSRange){9,10}];
        //[cellDisplayInfo setAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica-Bold" size: 11.0] forKey:NSFontAttributeName] range:(NSRange){16,18}];
        self.cellNameLabel.attributedText = cellDisplayInfo;
    }
}

- (void)clearCellatIndexPathRow:(int)indexPathRow{
    self.lineOne = [NSString stringWithFormat:@"#%i",indexPathRow+1];
    NSMutableAttributedString *cellDisplayInfo = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",self.lineOne]];
    [cellDisplayInfo setAttributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica-Light" size: 11.0] forKey:NSFontAttributeName] range:(NSRange){0,[cellDisplayInfo length]}];
    self.cellNameLabel.attributedText = cellDisplayInfo;
}

- (void)setCellToCyan{
    self.cellNameLabel.backgroundColor = [UIColor cyanColor];
}
- (void)setCellToWhite{
    self.cellNameLabel.backgroundColor = [UIColor whiteColor];
}

- (BOOL)isCellSetToCyan{
    if ([self.cellNameLabel.backgroundColor isEqual:[UIColor cyanColor]]) {
        return YES;
    }
    return NO;
}

- (void)turnBorderRed{
    self.cellNameLabel.layer.borderColor = [UIColor redColor].CGColor;
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.duration = .3;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    //transformAnimation.removedOnCompletion = NO;
    transformAnimation.fillMode = kCAFillModeForwards;
    
    CATransform3D xform = CATransform3DIdentity;
    xform = CATransform3DScale(xform, 1.1, 1.1, 1.1);
    xform = CATransform3DTranslate(xform, 5, 5, 5);
    transformAnimation.toValue = [NSValue valueWithCATransform3D:xform];
    [self.layer addAnimation:transformAnimation forKey:@"transformAnimation"];
}

- (void)turnBorderGray{
    self.cellNameLabel.layer.borderColor = [UIColor grayColor].CGColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
