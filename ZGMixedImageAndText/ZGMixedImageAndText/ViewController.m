//
//  ViewController.m
//  ZGMixedImageAndText
//
//  Created by Zong on 16/9/7.
//  Copyright © 2016年 Zong. All rights reserved.
//

#import "ViewController.h"
#import "ZGLabel.h"

@interface ViewController () <ZGLabelDelegate>

@property (nonatomic, strong) ZGLabel *urlLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
//    @"大张伟音乐才华还是不错的，就是话太多，管不住嘴。" @"abcdefghijklmnopqrstuvwxyz"
    NSMutableAttributedString *mAttributeContentString = [[NSMutableAttributedString alloc] initWithString:@"大张伟音乐才华还是不错的，就是话太多，管不住嘴。"];
    _urlLabel = [[ZGLabel alloc] init];
    _urlLabel.delegate = self;
    _urlLabel.numberOfLines = 0;
    _urlLabel.frame = CGRectMake(10, 150, 300, 60);
//    _urlLabel.textAlignment = NSTextAlignmentCenter;
    
    NSRange keywordRange = [mAttributeContentString.string rangeOfString:@"大张伟"];
    [mAttributeContentString addAttribute:ZGTapAttributeName
                                    value:@"username://www.baidu.com"
                                    range:keywordRange];
    
    NSRange keywordRange2 = [mAttributeContentString.string rangeOfString:@"多"];
    [mAttributeContentString addAttribute:ZGTapAttributeName
                                    value:@"username://www.google.com"
                                    range:keywordRange2];

    
    
    [mAttributeContentString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, mAttributeContentString.string.length)];
    _urlLabel.attributedText = mAttributeContentString;
    
    _urlLabel.tapAttribute = @{ZGTapColorAttributeStateNormal : [UIColor yellowColor],
                               ZGTapColorAttributeStateHighLighted : [UIColor purpleColor]
                               };
    [self.view addSubview:_urlLabel];
}

#pragma mark - ZGLabelDelegate
- (void)label:(ZGLabel *)label didTapWithModel:(ZGAttributeModel *)model
{
    NSLog(@"tapGesture %@",model.value);
}

- (void)label:(ZGLabel *)label didLongPressWithModel:(ZGAttributeModel *)model
{
    NSLog(@"longPress %@",model.value);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
