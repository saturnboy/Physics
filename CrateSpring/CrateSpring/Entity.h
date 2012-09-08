//
//  Entity.h
//  CrateSpring
//
//  Created by Justin Shacklette on 9/8/12.
//  Copyright Saturnboy 2012. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

@interface Entity : CCSprite {
	b2Body *_body;	// strong ref
}

@property(nonatomic,assign) b2Body *body;

@end
