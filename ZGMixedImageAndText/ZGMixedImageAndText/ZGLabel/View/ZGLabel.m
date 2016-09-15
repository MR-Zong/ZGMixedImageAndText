//
//  ZGLabel.m
//  ZGTestFontLabel
//
//  Created by Zong on 16/9/6.
//  Copyright © 2016年 Zong. All rights reserved.
//

#import "ZGLabel.h"
#import <CoreText/CoreText.h>


NSString * const ZGTapAttributeName = @"NSTapAttributeName";
NSString * const ZGTapColorAttributeStateNormal = @"ZGTapColorAttributeStateNormal";
NSString * const ZGTapColorAttributeStateHighLighted = @"ZGTapColorAttributeStateHighLighted";


@implementation ZGAttributeModel
+ (instancetype)attributeModelWithValue:(id)value range:(NSRange)range
{
    ZGAttributeModel *attrModel = [[self alloc] init];
    attrModel.value = value;
    attrModel.range = range;
    return attrModel;
}
@end

@interface ZGLabel () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableDictionary *attributeDic;
@property(nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGestureRecognizer;
@property (nonatomic, assign) NSRange highlightedRange;


@end

@implementation ZGLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.highLightedColorEnable = YES;
    self.userInteractionEnabled = YES;
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_tapGestureRecognizer];
    
    _longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _longGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_longGestureRecognizer];
    
    
    [_tapGestureRecognizer requireGestureRecognizerToFail:_longGestureRecognizer];
    
    _attributeDic = [[NSMutableDictionary alloc] init];
    
    self.backgroundColor = [UIColor redColor];

}

#pragma mark - setter
- (void)setAttributedText:(NSAttributedString *)attributedText
{
    __block NSMutableAttributedString *mAttributeString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    [attributedText enumerateAttribute:ZGTapAttributeName inRange:NSMakeRange(0, attributedText.string.length - 1) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value) {
            
            NSMutableArray *tapAttributeNameArray = [_attributeDic valueForKey:ZGTapAttributeName];
            if (!tapAttributeNameArray) {
                tapAttributeNameArray = [NSMutableArray array];
            }
            [tapAttributeNameArray addObject:[ZGAttributeModel attributeModelWithValue:value range:range]];
            [_attributeDic setObject:tapAttributeNameArray forKey:ZGTapAttributeName];
            
            
            if (self.tapAttribute) {
                for (NSString *key in self.tapAttribute.allKeys) {
                    id value = self.tapAttribute[key];
                    if ([key isEqualToString:ZGTapColorAttributeStateNormal]) {
                        [mAttributeString addAttribute:NSForegroundColorAttributeName value:value range:range];
                    }else if ([key isEqualToString:ZGTapColorAttributeStateHighLighted]){
                        ;;
                    }
                }
            }
            
            
        }
    }];
    
    [super setAttributedText:mAttributeString.copy];
}

- (void)setTapAttribute:(NSDictionary *)tapAttribute
{
    _tapAttribute = tapAttribute;
    
    
    NSMutableAttributedString *mAttributeString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    if (_attributeDic) {
        for (NSString *key in _attributeDic.allKeys) {
            NSArray *tapAttributeNameArray = _attributeDic[key];
            for (ZGAttributeModel *attributeModel in tapAttributeNameArray) {
                
                if (self.tapAttribute) {
                    for (NSString *key in self.tapAttribute.allKeys) {
                        id value = self.tapAttribute[key];
                        if ([key isEqualToString:ZGTapColorAttributeStateNormal]) {
                            [mAttributeString addAttribute:NSForegroundColorAttributeName value:value  range:attributeModel.range];
                        }else if ([key isEqualToString:ZGTapColorAttributeStateHighLighted]){
                            ;;
                        }
                    }
                }
            }
        }
        
        [super setAttributedText:mAttributeString.copy];
    }
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    ZGAttributeModel *model = [self urlAtPoint:[touch locationInView:self]];
    return model.range.location != NSNotFound;
}

- (void)handleTap:(UITapGestureRecognizer*) tap
{
    if(tap.state != UIGestureRecognizerStateEnded)
    {
        return;
    }
    
    ZGAttributeModel *selectedModel = [self urlAtPoint:[tap locationInView:self]];
    
    if ( selectedModel && selectedModel.range.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(label:didTapWithModel:)]) {
            [self.delegate label:self didTapWithModel:selectedModel];
        }
    }
    
}



#pragma mark- handleLongPress
- (void)handleLongPress:(UILongPressGestureRecognizer*) longPress
{
    CGPoint point = [longPress locationInView:self];
    switch (longPress.state)
    {
        case UIGestureRecognizerStateBegan :
        {
            ZGAttributeModel *model = [self urlAtPoint:point];
            self.highlightedRange = model.range;
            break;
        }
        case UIGestureRecognizerStateEnded :
        {
            ZGAttributeModel *model = [self urlAtPoint:point];
            self.highlightedRange = NSMakeRange(NSNotFound, 0);
            
            if ( model && model.range.length > 0) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(label:didLongPressWithModel:)]) {
                    [self.delegate label:self didLongPressWithModel:model];
                }
            }
            break;
        }
        default:
        {
            self.highlightedRange = NSMakeRange(NSNotFound, 0);
            break;
        }
    }
    
    [self setNeedsDisplay];
    
}


- (void)drawRect:(CGRect)rect
{
    if (self.highLightedColorEnable == NO) {
        [super drawRect:rect];
        return;
    }
    
    UIColor *highlightedBackgroundColor = _tapAttribute[ZGTapColorAttributeStateHighLighted];
    if (highlightedBackgroundColor  && _highlightedRange.length > 0) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGFloat _highlightedBackgroundCornerRadius = 0;
        
        if(_highlightedRange.location != NSNotFound && _highlightedRange.length > 0)
        {
            CGMutablePathRef path = CGPathCreateMutable();
            CGContextSetFillColorWithColor(context, highlightedBackgroundColor.CGColor);
            NSArray *rects = [self rectsForRange:_highlightedRange];
            for(NSString *rectStr in rects)
            {
                CGPathAddRoundedRect(path, NULL, CGRectFromString(rectStr), _highlightedBackgroundCornerRadius, _highlightedBackgroundCornerRadius);
            }
            
            CGContextAddPath(context, path);
            CGContextFillPath(context);
            CGPathRelease(path);
        }
        
    }
    
    [super drawRect:rect];
}


- (NSArray*)rectsForRange:(NSRange) range;
{
   
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) self.attributedText);
    
    //开始绘制
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect bounds = self.bounds;
    CGPathAddRect(path, NULL, bounds);
     CGRect textBounds = bounds;
    //文本框大小
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    CFRelease(path);

    
    NSMutableArray *rects = [NSMutableArray array];
    
    CFArrayRef lines = CFRetain(CTFrameGetLines(ctFrame));
    
    NSInteger count = CFArrayGetCount(lines);
    CGPoint lineOrigins[count];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    for(NSInteger i = 0;i < count;i ++)
    {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFRange lineRange = CTLineGetStringRange(line);
        
        NSRange innerRange = [self innerRangeBetweenOne:range andSecond:NSMakeRange(lineRange.location == kCFNotFound ? NSNotFound : lineRange.location, lineRange.length)];
        
        if(innerRange.location != NSNotFound && innerRange.length > 0)
        {
            CGFloat lineAscent;
            CGFloat lineDescent;
            CGFloat lineLeading;
            
            //获取文字排版
            CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
            CGFloat startX = CTLineGetOffsetForStringIndex(line, innerRange.location, NULL);
            CGFloat endX = CTLineGetOffsetForStringIndex(line, innerRange.location + innerRange.length, NULL);
            
            ///行末尾，但是末尾部分无法显示一个字，要占满
            if(i != count - 1 && innerRange.location + innerRange.length == lineRange.length + lineRange.location)
            {
                endX = CGRectGetMaxX(textBounds);
            }
            
            CGPoint lineOrigin = lineOrigins[i];
            
            CGRect rect = CGRectMake(lineOrigin.x + startX, self.bounds.size.height - lineOrigin.y - lineDescent, endX - startX, lineAscent + lineDescent + lineLeading);
            
            [rects addObject:NSStringFromCGRect(rect)];
            
        }else if(lineRange.location > range.location + range.length){
            break;
        }
    }
    
    
    return rects;
}


- (NSRange)innerRangeBetweenOne:(NSRange) one andSecond:(NSRange) second
{
    NSRange range = NSMakeRange(NSNotFound, 0);
    
    //交换
    if(one.location > second.location)
    {
        NSRange tmp = one;
        one = second;
        second = tmp;
    }
    
    if(second.location < one.location + one.length)
    {
        range.location = second.location;
        
        NSInteger end = MIN(one.location + one.length, second.location + second.length);
        range.length = end - range.location;
    }
    
    return range;
}



//获取点中的url
- (ZGAttributeModel *)urlAtPoint:(CGPoint) point
{
    NSUInteger index = [self characterIndexAtPoint:point];
    return [self urlAtCharacterIndex:index];
}

//判断是否点击到url
- (ZGAttributeModel *)urlAtCharacterIndex:(NSInteger) index
{
    if(index == NSNotFound)
        return nil;
    
    NSInteger computerIndex = index-- >= 0 ? index-- : 0;
    for (NSString *key in _attributeDic.allKeys) {
        if ([key isEqualToString:ZGTapAttributeName]) {
            
            NSMutableArray *tapAttributeNameArray = _attributeDic[key];
            if (tapAttributeNameArray.count > 0) {
                for (ZGAttributeModel *model in tapAttributeNameArray) {
                    if(model.range.location <= computerIndex && computerIndex <= (model.range.location + model.range.length - 1))
                    {
                        return model;
                    }
                }
            }
        }
    }
    
    
    return nil;
}

//计算点击在字体上的位置
- (NSUInteger)characterIndexAtPoint:(CGPoint) point
{
    //判断点击处是否在文本内
    if (!CGRectContainsPoint(self.bounds, point))
    {
        return NSNotFound;
    }
    
    CGRect textRect = self.bounds;
    
    if (!CGRectContainsPoint(textRect, point))
    {
        return NSNotFound;
    }
    
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) self.attributedText);
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect bounds = self.bounds;
    CGPathAddRect(path, NULL, bounds);
    
    CTFrameRef _ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFArrayRef lines = CTFrameGetLines(_ctFrame);
    NSUInteger numberOfLines = CFArrayGetCount(lines);
    if (numberOfLines == 0)
    {
        return NSNotFound;
    }
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    /**
     * seaCode 算法一
     
    NSUInteger lineIndex;
    for (lineIndex = 0; lineIndex < (numberOfLines - 1); lineIndex++)
    {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        if (lineOrigin.y < point.y) {
            break;
        }
    }
    
    if (lineIndex >= numberOfLines)
    {
        return NSNotFound;
    }
    */
    
    /**
     * seacode 算法二
     NSUInteger lineIndex;
     for(lineIndex = 0;lineIndex < (numberOfLines - 1);lineIndex ++)
     {
     CGPoint lineOrigin = lineOrigins[lineIndex];
     CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
     CGFloat lineDescent;
     CTLineGetTypographicBounds(line, NULL, &lineDescent, NULL);
     
     if (lineOrigin.y - lineDescent < point.y)
     {
     break;
     }
     }
     if (lineIndex >= numberOfLines)
     {
     return NSNotFound;
     }
     **/
    
    /**
     * zongCode
     **/
    NSInteger lineIndex = 0;
    for (int i = 0; i < numberOfLines; i++)
    {
        CGPoint lineOrigin = lineOrigins[i];
        if (point.y > lineOrigin.y) {
            break;
        }else {
            lineIndex++;
        }
    }
    if (lineIndex != 0) {
        lineIndex--;
    }
    if (lineIndex >= numberOfLines)
    {
        return NSNotFound;
    }
    
    // 调试代码
//    NSLog(@"lineIndex %zd",lineIndex);
    CGPoint lineOrigin = lineOrigins[lineIndex];
    CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
    
    // Convert CT coordinates to line-relative coordinates
//    NSLog(@"lineOrigin %@",NSStringFromCGPoint(lineOrigin));
    CGFloat offsetX = 4;
    CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x + offsetX, point.y - lineOrigin.y);
    CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
//    NSLog(@"idx %zd",idx);
    // We should check if we are outside the string range
    CFIndex glyphCount = CTLineGetGlyphCount(line);
    CFRange stringRange = CTLineGetStringRange(line);
    CFIndex stringRelativeStart = stringRange.location;
    if ((idx - stringRelativeStart) == glyphCount)
    {
        return NSNotFound;
    }
    
    return idx;
}


@end
