// https://github.com/fishman/mail.appetizer


#import <Cocoa/Cocoa.h>

@interface NSBezierPath (FAFNSBezierPathAdditions)
+ (NSBezierPath*) bezierPathWithRoundedRect:(NSRect)rect_;
+ (NSBezierPath*)bezierPathWithRoundedRect:(NSRect)rect_ radius:(float)radius_;
@end

