//
//	Copyright 2011 James Addyman (JamSoft). All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//		1. Redistributions of source code must retain the above copyright notice, this list of
//			conditions and the following disclaimer.
//
//		2. Redistributions in binary form must reproduce the above copyright notice, this list
//			of conditions and the following disclaimer in the documentation and/or other materials
//			provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JAMES ADDYMAN (JAMSOFT) ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAMES ADDYMAN (JAMSOFT) OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of James Addyman (JamSoft).
//

#import "JSTokenButton.h"
#import "JSTokenField.h"
#import <QuartzCore/QuartzCore.h>

@interface JSTokenButton ()

@end

@implementation JSTokenButton

+ (JSTokenButton *)tokenWithString:(NSString *)string representedObject:(id)obj parentField:(JSTokenField *)parentField {
  JSTokenButton *button = (JSTokenButton *)[self buttonWithType:UIButtonTypeCustom];
  [button setNormalBg:[[UIImage imageNamed:@"tokenNormal.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0]];
  [button setHighlightedBg:[[UIImage imageNamed:@"tokenHighlighted.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0]];
  [button setAdjustsImageWhenHighlighted:NO];
  [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [[button titleLabel] setFont:[UIFont fontWithName:@"Helvetica Neue" size:15]];
  [[button titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
  [button setTitleEdgeInsets:UIEdgeInsetsMake(2, 10, 0, 10)];
  
  [button setTitle:string forState:UIControlStateNormal];
  
  [button sizeToFit];
  CGRect frame = [button frame];
  frame.size.width += 20;
  frame.size.height = 25;
  [button setFrame:frame];
  
  [button setToggled:NO];
  [button setRepresentedObject:obj];
  [button setParentField:parentField];
  return button;
}

- (void)setToggled:(BOOL)toggled {
	_toggled = toggled;
	[self setSelected:_toggled];
}

- (BOOL)becomeFirstResponder {
	self.toggled = YES;
    BOOL superReturn = [super becomeFirstResponder];
    return superReturn;
}

- (BOOL)resignFirstResponder {
	self.toggled = NO;
    BOOL superReturn = [super resignFirstResponder];
	if (!_parentField.willBeFirstResponder) {
		if ([_parentField respondsToSelector:@selector(textFieldDidEndEditing:)]) {
			[_parentField textFieldDidEndEditing:_parentField.textField];
		}
	}
    return superReturn;
}

#pragma mark - UIKeyInput
- (void)deleteBackward {
    id <JSTokenFieldDelegate> delegate = _parentField.delegate;
    if ([delegate respondsToSelector:@selector(tokenField:shouldRemoveToken:representedObject:)]) {
        NSString *name = [self titleForState:UIControlStateNormal];
        BOOL shouldRemove = [delegate tokenField:_parentField shouldRemoveToken:name representedObject:self.representedObject];
        if (!shouldRemove) {
            return;
        }
    }
    [_parentField removeTokenForString:[self titleForState:UIControlStateNormal]];
}

- (BOOL)hasText {
    return NO;
}

- (void)insertText:(NSString *)text {
    return;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UITextAutocorrectionType)autocorrectionType {
  return UITextAutocorrectionTypeNo;
}

@end
