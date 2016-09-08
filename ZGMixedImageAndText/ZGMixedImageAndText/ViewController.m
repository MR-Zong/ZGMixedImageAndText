//
//  ViewController.m
//  ZGMixedImageAndText
//
//  Created by Zong on 16/9/7.
//  Copyright © 2016年 Zong. All rights reserved.
//

#import "ViewController.h"
#import "ZGLabel.h"

@interface ViewController ()

@property (nonatomic, strong) ZGLabel *urlLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
//    @"大张伟音乐才华还是不错的，就是话太多，管不住嘴。" @"abcdefghijklmnopqrstuvwxyz"
    NSMutableAttributedString *mAttributeContentString = [[NSMutableAttributedString alloc] initWithString:@"大张伟音乐才华还是不错的，就是话太多，管不住嘴。"];
    _urlLabel = [[ZGLabel alloc] init];
    _urlLabel.numberOfLines = 0;
    _urlLabel.frame = CGRectMake(10, 150, 300, 120);
    _urlLabel.textAlignment = NSTextAlignmentCenter;
    
    NSRange keywordRange = [mAttributeContentString.string rangeOfString:@"lm"];
    [mAttributeContentString addAttribute:ZGTapAttributeName
                                    value:@"username://www.baidu.com"
                                    range:keywordRange];
    
    
    [mAttributeContentString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, mAttributeContentString.string.length)];
    _urlLabel.attributedText = mAttributeContentString;
    [self.view addSubview:_urlLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
