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

#import "JSTokenField.h"
#import "JSTokenButton.h"
#import <QuartzCore/QuartzCore.h>

NSString *const JSTokenFieldFrameDidChangeNotification = @"JSTokenFieldFrameDidChangeNotification";
NSString *const JSTokenFieldNewFrameKey = @"JSTokenFieldNewFrameKey";
NSString *const JSTokenFieldOldFrameKey = @"JSTokenFieldOldFrameKey";
NSString *const JSDeletedTokenKey = @"JSDeletedTokenKey";

CGFloat const kJSTokenFieldHeightPadding = 6;
CGFloat const kJSTokenFieldWidthPadding = 10;
CGFloat const kJSTokenFieldRightViewPadding = 20;
CGFloat const kJSTokenFieldHeight = 44;

@interface JSTokenField ()

@property (nonatomic, readwrite) JSBackspaceReportingTextField *textField;
@property (nonatomic, readwrite) UILabel *label;
@property (nonatomic, strong) NSMutableArray *tokens;

@property (nonatomic, strong) JSTokenButton *deletedToken;
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)deleteHighlightedToken;
- (void)commonSetup;

@end


@implementation JSTokenField

- (void)dealloc {
	self.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
	if (frame.size.height < kJSTokenFieldHeight) {
		frame.size.height = kJSTokenFieldHeight;
	}
    if ((self = [super initWithFrame:frame])) {
        [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup {
    CGRect frame = self.frame;
    
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.clipsToBounds = YES;
	[self addSubview:_scrollView];
	
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, kJSTokenFieldHeightPadding, 0, frame.size.height - kJSTokenFieldHeightPadding*2)];
    [self.label setBackgroundColor:[UIColor clearColor]];
    [self.label setTextColor:[UIColor grayColor]];
    [self.label setFont:[UIFont systemFontOfSize:14]];
    
    [self.scrollView addSubview:self.label];
    
    self.tokens = [[NSMutableArray alloc] init];
    
    frame.origin.y += kJSTokenFieldHeightPadding;
    frame.size.height -= kJSTokenFieldHeightPadding * 2;
    self.textField = [[JSBackspaceReportingTextField alloc] initWithFrame:frame];
    [self.textField setDelegate:self];
    [self.textField setBorderStyle:UITextBorderStyleNone];
    [self.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.scrollView addSubview:self.textField];
    
    [self.textField addTarget:self action:@selector(textFieldWasUpdated:) forControlEvents:UIControlEventEditingChanged];
	
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self.textField action:@selector(becomeFirstResponder)];
	[self addGestureRecognizer:gesture];
}

- (NSArray *)allTokens {
	return [self.tokens copy];
}

- (void)addTokenWithTitle:(NSString *)string representedObject:(id)obj {
	NSString *aString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if ([aString length]) {
		JSTokenButton *token = [self tokenWithString:aString representedObject:obj];
		[self.tokens addObject:token];
		
		if ([self.delegate respondsToSelector:@selector(tokenField:didAddToken:representedObject:)]) {
			[self.delegate tokenField:self didAddToken:aString representedObject:obj];
		}
		
		[self setNeedsLayout];
	}
}

- (JSTokenButton *)tokenWithString:(NSString *)string representedObject:(id)obj {
	JSTokenButton *token = [JSTokenButton tokenWithString:string representedObject:obj parentField:self];
	CGRect frame = [token frame];
	
	if (frame.size.width > self.frame.size.width) {
		frame.size.width = self.frame.size.width - (kJSTokenFieldWidthPadding * 2);
	}
	[token setFrame:frame];
	[token addTarget:self
						action:@selector(toggle:)
	forControlEvents:UIControlEventTouchUpInside];
	return token;
}

- (void)toggle:(id)sender
{
	for (JSTokenButton *token in self.tokens) {
		[token setToggled:NO];
	}
	JSTokenButton *token = (JSTokenButton *)sender;
	[token setToggled:YES];
	[token becomeFirstResponder];
}

- (void)addTokenWithTitle:(NSString *)title token:(JSTokenButton *)token {
	[self.tokens addObject:token];
	self.textField.text = @"";
	if ([self.delegate respondsToSelector:@selector(tokenField:didAddToken:representedObject:)]) {
		[self.delegate tokenField:self didAddToken:title representedObject:token.representedObject];
	}
	[self setNeedsLayout];
}

- (void)removeTokenWithTest:(BOOL (^)(JSTokenButton *token))test {
    JSTokenButton *tokenToRemove = nil;
    for (JSTokenButton *token in [self.tokens reverseObjectEnumerator]) {
        if (test(token)) {
            tokenToRemove = token;
            break;
        }
    }
    
    if (tokenToRemove) {
        if (tokenToRemove.isFirstResponder) {
            [self.textField becomeFirstResponder];
        }
        [tokenToRemove removeFromSuperview];
        
        [self.tokens removeObject:tokenToRemove];
        if ([self.delegate respondsToSelector:@selector(tokenField:didRemoveToken:representedObject:)]) {
				NSString *tokenName = [tokenToRemove titleForState:UIControlStateNormal];
				[self.delegate tokenField:self didRemoveToken:tokenName representedObject:tokenToRemove.representedObject];
		}
	}
	
	[self setNeedsLayout];
}

- (void)removeTokenForString:(NSString *)string {
    [self removeTokenWithTest:^BOOL(JSTokenButton *token) {
        return [[token titleForState:UIControlStateNormal] isEqualToString:string] && [token isToggled];
    }];
}

- (void)removeTokenWithRepresentedObject:(id)representedObject {
    [self removeTokenWithTest:^BOOL(JSTokenButton *token) {
        return [[token representedObject] isEqual:representedObject];
    }];
}

- (void)removeAllTokens {
	NSArray *tokensCopy = [self.tokens copy];
	for (JSTokenButton *button in tokensCopy) {
		[self removeTokenWithTest:^BOOL(JSTokenButton *token) {
			return token == button;
		}];
	}
}

- (void)deleteHighlightedToken {
	for (int i = 0; i < [self.tokens count]; i++) {
		self.deletedToken = [self.tokens objectAtIndex:i];
		if ([self.deletedToken isToggled]) {
			NSString *tokenName = [self.deletedToken titleForState:UIControlStateNormal];
			if ([self.delegate respondsToSelector:@selector(tokenField:shouldRemoveToken:representedObject:)]) {
				BOOL shouldRemove = [self.delegate tokenField:self
											shouldRemoveToken:tokenName
											representedObject:self.deletedToken.representedObject];
				if (shouldRemove == NO) {
					return;
				}
			}
			
			[self.deletedToken removeFromSuperview];
			[self.tokens removeObject:self.deletedToken];
			
			if ([self.delegate respondsToSelector:@selector(tokenField:didRemoveToken:representedObject:)]) {
				[self.delegate tokenField:self didRemoveToken:tokenName representedObject:self.deletedToken.representedObject];
			}
			[self setNeedsLayout];	
		}
	}
}

- (void)layoutSubviews {
	if (self.singleLine) {
		[self layoutSubviewsInSingleLine];
	} else {
		[self layoutSubviewsInMutiLine];
	}
}

- (void)layoutSubviewsInSingleLine {
	CGRect currentRect = CGRectZero;
	
	[self.label sizeToFit];
	[self.label setFrame:CGRectMake(16, kJSTokenFieldHeightPadding, [self.label frame].size.width, [self.label frame].size.height)];
	
	currentRect.origin.x = self.label.frame.origin.x;
	if (self.label.frame.size.width > 0) {
		currentRect.origin.x += self.label.frame.size.width + kJSTokenFieldWidthPadding;
	}
	
	NSMutableArray *lastLineTokens = [NSMutableArray array];
	
	for (UIButton *token in self.tokens) {
		CGRect frame = [token frame];
		
		frame.origin.x = currentRect.origin.x;
		frame.origin.y = currentRect.origin.y;
		
		[token setFrame:frame];
		
		if (![token superview]) {
			[self.scrollView addSubview:token];
		}
		[lastLineTokens addObject:token];
		
		currentRect.origin.x += frame.size.width + kJSTokenFieldWidthPadding;
		currentRect.size = frame.size;
	}
	
	CGRect textFieldFrame = [self.textField frame];
	
	textFieldFrame.origin = currentRect.origin;
	CGSize textSize = [self.textField.text sizeWithAttributes:@{NSFontAttributeName:self.textField.font}];
	CGFloat textWidth = textSize.width >= self.frame.size.width?self.frame.size.width: textSize.width;
	textWidth = textWidth == 0 ? 2 : textWidth;
	textWidth += self.textField.leftView.frame.size.width;

	textWidth += 20;
	textFieldFrame.size.width = textWidth;
	if (self.tokens.count == 0) {
		textFieldFrame.size.width = self.frame.size.width - kJSTokenFieldWidthPadding*4;
	}
	
	textFieldFrame.origin.y += kJSTokenFieldHeightPadding;
	[self.textField setFrame:textFieldFrame];
	
	CGRect rightViewFrame = textFieldFrame;
	rightViewFrame.origin.x = CGRectGetMaxX(textFieldFrame) + kJSTokenFieldRightViewPadding;
	rightViewFrame.size.width = 1;
	
	[_scrollView setContentSize:CGSizeMake(CGRectGetMaxX(rightViewFrame), _scrollView.frame.size.height)];
	[_scrollView scrollRectToVisible:rightViewFrame animated:YES];
	
	CGFloat textFieldMidY = CGRectGetMidY(textFieldFrame);
	for (UIButton *token in lastLineTokens) {
		// Center the last line's tokens vertically with the text field
		CGPoint tokenCenter = token.center;
		tokenCenter.y = textFieldMidY;
		token.center = tokenCenter;
	}
}

- (void)layoutSubviewsInMutiLine {
	CGRect currentRect = CGRectZero;
	
	[self.label sizeToFit];
	[self.label setFrame:CGRectMake(16, kJSTokenFieldHeightPadding, [self.label frame].size.width, [self.label frame].size.height)];
	
	currentRect.origin.x = self.label.frame.origin.x;
	if (self.label.frame.size.width > 0) {
		currentRect.origin.x += self.label.frame.size.width + kJSTokenFieldWidthPadding;
	}
	
	NSMutableArray *lastLineTokens = [NSMutableArray array];
	
	for (UIButton *token in self.tokens) {
		CGRect frame = [token frame];
		
		if ((currentRect.origin.x + frame.size.width) > self.frame.size.width) {
			[lastLineTokens removeAllObjects];
			currentRect.origin = CGPointMake(16, (currentRect.origin.y + frame.size.height + kJSTokenFieldHeightPadding));
		}
		
		frame.origin.x = currentRect.origin.x;
		frame.origin.y = currentRect.origin.y + kJSTokenFieldHeightPadding;
		
		[token setFrame:frame];
		
		if (![token superview]) {
			[self.scrollView addSubview:token];
		}
		[lastLineTokens addObject:token];
		
		currentRect.origin.x += frame.size.width + kJSTokenFieldWidthPadding;
		currentRect.size = frame.size;
	}
	
	CGRect textFieldFrame = [self.textField frame];
	
	textFieldFrame.origin = currentRect.origin;
	CGSize textSize = [self.textField.text sizeWithAttributes:@{NSFontAttributeName:self.textField.font}];
	CGFloat textWidth = textSize.width >= self.frame.size.width?self.frame.size.width: textSize.width;
	textWidth = textWidth == 0 ? 2 : textWidth;
	textWidth += self.textField.leftView.frame.size.width;
	if ((self.frame.size.width - textFieldFrame.origin.x - textWidth) > 1) {
		textWidth += 20;
		textFieldFrame.size.width = textWidth;
		if (self.tokens.count == 0) {
			textFieldFrame.size.width = self.frame.size.width;
			
		}
	} else {
		[lastLineTokens removeAllObjects];
		textFieldFrame.size.width = self.frame.size.width;
		textFieldFrame.origin = CGPointMake(kJSTokenFieldWidthPadding * 2,
											(currentRect.origin.y + currentRect.size.height + kJSTokenFieldHeightPadding));
	}
	
	textFieldFrame.origin.y += kJSTokenFieldHeightPadding;
	[self.textField setFrame:textFieldFrame];
	CGRect selfFrame = [self frame];
	selfFrame.size.height = textFieldFrame.origin.y + textFieldFrame.size.height + kJSTokenFieldHeightPadding;
	
	CGFloat textFieldMidY = CGRectGetMidY(textFieldFrame);
	for (UIButton *token in lastLineTokens) {
		// Center the last line's tokens vertically with the text field
		CGPoint tokenCenter = token.center;
		tokenCenter.y = textFieldMidY;
		token.center = tokenCenter;
	}
	
	if (self.layer.presentationLayer == nil) {
		[self setFrame:selfFrame];
	} else {
		[UIView animateWithDuration:0.3
						 animations:^{
							 [self setFrame:selfFrame];
						 }
						 completion:nil];
	}

}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    
	[super setFrame:frame];
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSValue valueWithCGRect:frame] forKey:JSTokenFieldNewFrameKey];
    [userInfo setObject:[NSValue valueWithCGRect:oldFrame] forKey:JSTokenFieldOldFrameKey];
	if (self.deletedToken) {
		[userInfo setObject:self.deletedToken forKey:JSDeletedTokenKey]; 
		self.deletedToken = nil;
	}
	
	if (CGRectEqualToRect(oldFrame, frame) == NO) {
		[[NSNotificationCenter defaultCenter] postNotificationName:JSTokenFieldFrameDidChangeNotification object:self userInfo:[userInfo copy]];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsLayout) name:UITextFieldTextDidChangeNotification object:nil];
	self.willBeFirstResponder = YES;
	return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if ([self.delegate respondsToSelector:@selector(tokenFieldDidBeginEditing:)]) {
		[self.delegate tokenFieldDidBeginEditing:self];
	}
}

- (void)textFieldWasUpdated:(UITextField *)sender {
    if ([self.delegate respondsToSelector:@selector(tokenFieldTextDidChange:)]) {
        [self.delegate tokenFieldTextDidChange:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""] && NSEqualRanges(range, NSMakeRange(0, 0))) {
        JSTokenButton *token = [self.tokens lastObject];
		if (!token) {
			return NO;
		}
		
		NSString *name = [token titleForState:UIControlStateNormal];
		// If we don't allow deleting the token, don't even bother letting it highlight
		BOOL responds = [self.delegate respondsToSelector:@selector(tokenField:shouldRemoveToken:representedObject:)];
		if (responds == NO || [self.delegate tokenField:self shouldRemoveToken:name representedObject:token.representedObject])
		{
			[token performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
		}
		return NO;
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.textField == textField) {
        if ([self.delegate respondsToSelector:@selector(tokenFieldShouldReturn:)]) {
            return [self.delegate tokenFieldShouldReturn:self];
        }
    }
	return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

	self.willBeFirstResponder = NO;
	BOOL toggled = NO;
	for (JSTokenButton *token in self.tokens) {
		if (token.isToggled) {
			toggled = YES;
			break;
		}
	}

    if (!toggled && !self.forceEnd && [self.delegate respondsToSelector:@selector(tokenFieldDidEndEditing:)]) {
        [self.delegate tokenFieldDidEndEditing:self];
        return;
    }
}

-(void)setSingleLine:(BOOL)singleLine {
	_singleLine = singleLine;
	if (singleLine) {
		_scrollView.alwaysBounceHorizontal = YES;
	} else {
		_scrollView.scrollEnabled = NO;
	}
}

@end
