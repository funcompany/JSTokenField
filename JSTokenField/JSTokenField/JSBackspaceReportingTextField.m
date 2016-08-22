//
//  JSBackspaceReportingTextField.m
//  JSTokenField
//
//  Created by BJ Homer on 2/18/13.
//  Copyright (c) 2013 JamSoft. All rights reserved.
//

#import "JSBackspaceReportingTextField.h"

@implementation JSBackspaceReportingTextField

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
	self.leftViewMode = UITextFieldViewModeAlways;
	return self;
}

- (void)insertText:(NSString *)text {
    [super insertText:text];
}

- (BOOL)keyboardInputShouldDelete:(UITextField *)textField {
    if (self.text.length == 0) {
        if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            [self.delegate textField:self shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@""];
        }
    }
    return YES;
}

@end
