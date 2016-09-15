//
//  LinkView.m
//  ZGMixedImageAndText
//
//  Created by 徐宗根 on 16/9/10.
//  Copyright © 2016年 Zong. All rights reserved.
//
#import "LinkView.h"

@implementation LinkView

@synthesize text;
@synthesize linkArray;
@synthesize phoneArray;
@synthesize isClick;
@synthesize clickNum;
@synthesize clickType;

- (void)dealloc{
//    [text release];
//    [linkArray release];
//    [phoneArray release];
//    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
//        [self showMenu];
    }
}



//是否包含汉字
- (BOOL) containsChinese:(NSString *)str {
    for(int i = 0; i < [str length]; i++) {
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
            return TRUE;
    }
    return FALSE;
}
//是否包含特殊符号,可以在这里判断超链接 结尾
- (BOOL) containsSpecialSymbol:(NSString *)str{
    NSSet *symbols = [NSSet setWithObjects:@" ",@",", nil];
    for(int i = 0; i < [str length]; i++) {
        NSString *c = [str substringWithRange:NSMakeRange(i, 1)];
        if ([symbols containsObject:c]) {
            return YES;
        }
    }
    return NO;
}
//电话号码是否合法
- (BOOL)isValidatePhone:(NSString *)phone{
    
    return NO;//本版本不进行电话号码得判断
    
    NSString *phoneRegex = @"\\b(1)[358][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\\b";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@" , phoneRegex];
    BOOL ret = [phoneTest evaluateWithObject:phone];
    return ret;
}
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphx = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
        || ([regextestphx evaluateWithObject:mobileNum]))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//是否是连接开头
- (BOOL)isValidateLink:(NSString *)Link{
    if ([Link hasPrefix:@"http://"] || [Link hasPrefix:@"www."]) {
        return YES;
    }
    return NO;
}

//获取链接的NSRangeArray  array 里面存的是链接的 NSRange
- (NSArray *)getLinkRangeWithString:(NSString *)string{
    NSMutableArray *rangeArray = [NSMutableArray arrayWithCapacity:0];
    for (int loc = 0; loc < [string length]; ) {
        for (int len = 0; len <= [string length] - loc; ) {
            NSString *lenStr = [string substringWithRange:NSMakeRange(loc, len)];
            if ([self isValidateLink:lenStr]) {
                if (![self containsSpecialSymbol:lenStr]) {
                    //不包含特殊字符 以特殊字符或汉字结尾，或者结尾为空
                    if (loc + len == [string length]) {
                        NSString *rangeStr = NSStringFromRange(NSMakeRange(loc, len));
                        [rangeArray addObject:rangeStr];
                        loc += len - 1;
                        break;
                    }else{
                        if ( [self containsSpecialSymbol:[string substringWithRange:NSMakeRange(loc + len, 1)]]) {
                            NSString *rangeStr = NSStringFromRange(NSMakeRange(loc, len));
                            [rangeArray addObject:rangeStr];
                            loc += len - 1;
                            break;
                        }
                    }
                }
            }
            len++;
        }
        loc++;
    }
    return rangeArray;
}
//获取电话的NSRange
- (NSArray *)getPhoneRangeWithString:(NSString *)string{
    
    NSMutableArray *rangeArray = [[NSMutableArray alloc]initWithCapacity:0];
    for (int loc = 0; loc < [string length]; ) {
        for (int len = 0; len <= [string length] - loc; ) {
            NSString *lenStr = [string substringWithRange:NSMakeRange(loc, len)];
            //            NSLog(@"lenStr: %@",lenStr);
            if ([self isMobileNumber:lenStr]) {
                NSString *rangeStr = NSStringFromRange(NSMakeRange(loc, len));
                [rangeArray addObject:rangeStr];
                loc += len - 1;
                break;
            }
            len++;
        }
        loc++;
    }
    return rangeArray;
}


//设置换行模式
- (void)setAttString:(NSMutableAttributedString *)attString LineBreakMode:(CTLineBreakMode)mode{
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = mode;
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    
    CTParagraphStyleSetting settings[] = {
        lineBreakMode
    };
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 1);
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(id)style forKey:(id)kCTParagraphStyleAttributeName];
    
    [attString addAttributes:attributes range:NSMakeRange(0, [attString length])];
}

- (void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGContextSaveGState(context);
    
    //x，y轴方向移动
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    //缩放x，y轴方向缩放，－1.0为反向1.0倍,坐标系转换,沿x轴翻转180度
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRect(path, NULL, self.bounds);
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:self.text];
    
    [attString beginEditing];
    
    //设置字体属性
    CTFontRef font = [self CTFontRefCTFontCreateFromUIFont:[UIFont systemFontOfSize:16.0f]];
    [attString addAttribute:(id)kCTFontAttributeName value:(__bridge  id)font range:NSMakeRange(0, [attString length])];
    
    //让文字细一点////
    CGFloat widthValue = -1.0;
    
    CFNumberRef strokeWidth = CFNumberCreate(NULL,kCFNumberFloatType,&widthValue);
    
    [attString addAttribute:(NSString*)(kCTStrokeWidthAttributeName) value:(__bridge id)strokeWidth range:NSMakeRange(0,[text length])];
    
    [attString addAttribute:(NSString*)(kCTStrokeColorAttributeName) value:(id)[[UIColor whiteColor]CGColor] range:NSMakeRange(0,[text length])];
    /////细一点
    
    
    self.phoneArray = [self getPhoneRangeWithString:self.text];
    self.linkArray = [self getLinkRangeWithString:self.text];
    
    //设置字体颜色
    [attString addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor blackColor].CGColor range:NSMakeRange(0, [attString length])];
    for (int i = 0; i < [self.linkArray count]; i ++) {
        [attString addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:NSRangeFromString([self.linkArray objectAtIndex:i])];
        [attString addAttribute:(id)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt: kCTUnderlineStyleSingle] range:NSRangeFromString([self.linkArray objectAtIndex:i])];
        [attString addAttribute:(id)kCTUnderlineColorAttributeName value:(id)[UIColor greenColor] range:NSRangeFromString([self.linkArray objectAtIndex:i])];
    }
    for (int i = 0; i < [self.phoneArray count]; i ++) {
        [attString addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:NSRangeFromString([self.phoneArray objectAtIndex:i])];
    }
    if (self.isClick) {
        switch (self.clickType) {
            case CLICK_TYPE_LINK:
                [attString removeAttribute:(id)kCTForegroundColorAttributeName range:NSRangeFromString([self.linkArray objectAtIndex:self.clickNum])];
//                [attString addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UtilityHelper colorWithHexString:@"#002f6f"].CGColor range:NSRangeFromString([self.linkArray objectAtIndex:self.clickNum])];
                break;
            case CLICK_TYPE_PHONE:
                [attString removeAttribute:(id)kCTForegroundColorAttributeName range:NSRangeFromString([self.phoneArray objectAtIndex:self.clickNum])];
                [attString addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:NSRangeFromString([self.phoneArray objectAtIndex:self.clickNum])];
                break;
            default:
                break;
        }
        
    }
    //换行模式
    //    [self setAttString:attString LineBreakMode:kCTLineBreakByWordWrapping];
    [self setText:attString Alignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByCharWrapping];
    
    [attString endEditing];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, [attString length]), path, NULL);
    _frame = frame;
    
    CTFrameDraw(frame, context);
    
    //    CFRelease(frame);
    
    CFRelease(frameSetter);
    
    CFRelease(path);
}

//设置换行和对其方式
-(void)setText:(NSMutableAttributedString *)attString Alignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode {
    [self setText:attString Alignment:alignment lineBreakMode:lineBreakMode range:NSMakeRange(0,[attString length])];
}
-(void)setText:(NSMutableAttributedString *)attString Alignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range {
    // kCTParagraphStyleAttributeName > kCTParagraphStyleSpecifierAlignment
    CTParagraphStyleSetting paraStyles[2] = {
        {.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void*)&alignment},
        {.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void*)&lineBreakMode},
    };
    CTParagraphStyleRef aStyle = CTParagraphStyleCreate(paraStyles, 2);
    [attString removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range]; // Work around for Apple leak
    [attString addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(id)aStyle range:range];
    CFRelease(aStyle);
}


//根据 点 判断 字符index
CFIndex CFIndexGet(CGPoint point,CTFrameRef frame){
    
    //获取每一行
    CFArrayRef lines = CTFrameGetLines(frame);
    CGPoint origins[CFArrayGetCount(lines)];
    //获取每行的原点坐标
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    CTLineRef line = NULL;
    CGPoint lineOrigin = CGPointZero;
    for (int i= 0; i < CFArrayGetCount(lines); i++)
    {
        CGPoint origin = origins[i];
        CGPathRef path = CTFrameGetPath(frame);
        //获取整个CTFrame的大小
        CGRect rect = CGPathGetBoundingBox(path);
        
        //坐标转换，把每行的原点坐标转换为uiview的坐标体系
        CGFloat y = rect.origin.y + rect.size.height - origin.y;
        //判断点击的位置处于那一行范围内
        if ((point.y <= y) && (point.x >= origin.x))
        {
            line = CFArrayGetValueAtIndex(lines, i);
            lineOrigin = origin;
            break;
        }
    }
    point.x -= lineOrigin.x;
    //获取点击位置所处的字符位置，就是相当于点击了第几个字符
    CFIndex index = CTLineGetStringIndexForPosition(line, point);
    
    return index;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
    
    CFIndex index = CFIndexGet(location, _frame);
    
    for (int i = 0; i< [self.linkArray count]; i++) {
        NSString *rangeStr = [self.linkArray objectAtIndex:i];
        NSRange range = NSRangeFromString(rangeStr);
        if (index >= range.location && index <= range.location + range.length) {
            self.isClick = YES;
            self.clickNum = i;
            self.clickType = CLICK_TYPE_LINK;
            [self setNeedsDisplay];
        }
    }
    for (int i = 0; i< [self.phoneArray count]; i++) {
        NSString *rangeStr = [self.phoneArray objectAtIndex:i];
        NSRange range = NSRangeFromString(rangeStr);
        if (index >= range.location && index <= range.location + range.length) {
            self.isClick = YES;
            self.clickNum = i;
            self.clickType = CLICK_TYPE_PHONE;
            [self setNeedsDisplay];
        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
    
    CFIndex index = CFIndexGet(location, _frame);
    
    //    NSLog(@"indexEnd:%ld",index);
    for (int i = 0; i< [self.linkArray count]; i++) {
        NSString *rangeStr = [self.linkArray objectAtIndex:i];
        NSRange range = NSRangeFromString(rangeStr);
        if (index >= range.location && index <= range.location + range.length) {
            if (i == self.clickNum) {
                NSMutableString *linkText = [NSMutableString stringWithString:[self.text substringWithRange:range]];
                if ([linkText hasPrefix:@"www:"]) {
                    linkText = [NSMutableString stringWithFormat:@"http://%@",linkText];
                }
//                [UtilityHelper gatrackEvent:@"客户聊天详情页" label:@"跳转超链接"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkText]];
            }
        }
    }
    for (int i = 0; i< [self.phoneArray count]; i++) {
        NSString *rangeStr = [self.phoneArray objectAtIndex:i];
        NSRange range = NSRangeFromString(rangeStr);
        if (index >= range.location && index <= range.location + range.length) {
            if (i == self.clickNum) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[self.text substringWithRange:range]]]];
            }
        }
    }
    self.isClick = NO;
    self.clickNum = -1;
    self.clickType = CLICK_TYPE_NONE;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    self.isClick = NO;
    self.clickNum = -1;
    self.clickType = CLICK_TYPE_NONE;
    [self setNeedsDisplay];
}



//根据UIFont 获取 CTFontRef
- (CTFontRef)CTFontRefCTFontCreateFromUIFont:(UIFont *)font
{
    CTFontRef ctFont =CTFontCreateWithName((CFStringRef)font.fontName,
                                           font.pointSize,
                                           NULL);
    return ctFont;
}
@end