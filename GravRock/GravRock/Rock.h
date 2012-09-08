//
//  Rock.h
//  GravRock
//
//  Created by Justin Shacklette on 9/5/12.
//  Copyright __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface Rock : CCSprite {
	CGPoint vel;
    CGPoint acc;
}

@property(nonatomic,assign) CGPoint vel;
@property(nonatomic,assign) CGPoint acc;

@end
