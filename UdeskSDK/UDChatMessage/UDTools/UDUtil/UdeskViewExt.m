/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "UdeskViewExt.h"

@implementation UIView (UdeskViewGeometry)

// Retrieve and set the origin
- (CGPoint)ud_origin
{
	return self.frame.origin;
}

- (void)setUd_origin:(CGPoint)ud_origin {

	CGRect newframe = self.frame;
	newframe.origin = ud_origin;
	self.frame = newframe;
}


// Retrieve and set the size
- (CGSize) ud_size
{
	return self.frame.size;
}

- (void)setUd_size:(CGSize)ud_size {

	CGRect newframe = self.frame;
	newframe.size = ud_size;
	self.frame = newframe;
}

// Query other frame locations

- (CGPoint) ud_bottomRight {

	CGFloat x = self.frame.origin.x + self.frame.size.width;
	CGFloat y = self.frame.origin.y + self.frame.size.height;
	return CGPointMake(x, y);
}

- (CGPoint) ud_bottomLeft {

	CGFloat x = self.frame.origin.x;
	CGFloat y = self.frame.origin.y + self.frame.size.height;
	return CGPointMake(x, y);
}

- (CGPoint) ud_topRight {

	CGFloat x = self.frame.origin.x + self.frame.size.width;
	CGFloat y = self.frame.origin.y;
	return CGPointMake(x, y);
}

- (CGFloat)ud_x {

    return self.frame.origin.x;
}

- (void)setUd_x:(CGFloat)ud_x {

    CGRect newframe = self.frame;
    newframe.origin.x = ud_x;
    self.frame = newframe;
}

- (CGFloat)ud_y {

    return self.frame.origin.y;
}

- (void)setUd_y:(CGFloat)ud_y {

    CGRect newframe = self.frame;
    newframe.origin.y = ud_y;
    self.frame = newframe;
}

- (CGFloat)ud_centerX {
    return self.center.x;
}

- (void)setUd_centerX:(CGFloat)ud_centerX {

    self.center = CGPointMake(ud_centerX, self.center.y);
}

- (CGFloat)ud_centerY {
    return self.center.y;
}

- (void)setUd_centerY:(CGFloat)ud_centerY {

    self.center = CGPointMake(self.center.x, ud_centerY);
}

// Retrieve and set height, width, top, bottom, left, right
- (CGFloat) ud_height
{
	return self.frame.size.height;
}

- (void)setUd_height:(CGFloat)ud_height {

	CGRect newframe = self.frame;
	newframe.size.height = ud_height;
	self.frame = newframe;
}

- (CGFloat) ud_width
{
	return self.frame.size.width;
}

- (void) setUd_width: (CGFloat) ud_width
{
	CGRect newframe = self.frame;
	newframe.size.width = ud_width;
	self.frame = newframe;
}

- (CGFloat) ud_top
{
	return self.frame.origin.y;
}

- (void) setUd_top: (CGFloat) ud_top
{
	CGRect newframe = self.frame;
	newframe.origin.y = ud_top;
	self.frame = newframe;
}

- (CGFloat) ud_left
{
	return self.frame.origin.x;
}

- (void) setUd_left: (CGFloat) ud_left
{
	CGRect newframe = self.frame;
	newframe.origin.x = ud_left;
	self.frame = newframe;
}

- (CGFloat) ud_bottom
{
	return self.frame.origin.y + self.frame.size.height;
}

- (void) setUd_bottom: (CGFloat) ud_bottom
{
	CGRect newframe = self.frame;
	newframe.origin.y = ud_bottom - self.frame.size.height;
	self.frame = newframe;
}

- (CGFloat) ud_right
{
	return self.frame.origin.x + self.frame.size.width;
}

- (void) setUd_right: (CGFloat) ud_right
{
	CGFloat delta = ud_right - (self.frame.origin.x + self.frame.size.width);
	CGRect newframe = self.frame;
	newframe.origin.x += delta ;
	self.frame = newframe;
}

// Move via offset
- (void) moveBy: (CGPoint) delta
{
	CGPoint newcenter = self.center;
	newcenter.x += delta.x;
	newcenter.y += delta.y;
	self.center = newcenter;
}

// Scaling
- (void) scaleBy: (CGFloat) scaleFactor
{
	CGRect newframe = self.frame;
	newframe.size.width *= scaleFactor;
	newframe.size.height *= scaleFactor;
	self.frame = newframe;
}

// Ensure that both dimensions fit within the given size by scaling down
- (void) fitInSize: (CGSize) aSize
{
	CGFloat scale;
	CGRect newframe = self.frame;
	
	if (newframe.size.height && (newframe.size.height > aSize.height))
	{
		scale = aSize.height / newframe.size.height;
		newframe.size.width *= scale;
		newframe.size.height *= scale;
	}
	
	if (newframe.size.width && (newframe.size.width >= aSize.width))
	{
		scale = aSize.width / newframe.size.width;
		newframe.size.width *= scale;
		newframe.size.height *= scale;
	}
	
	self.frame = newframe;	
}
@end
