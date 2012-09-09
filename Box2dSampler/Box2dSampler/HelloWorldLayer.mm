//
//  HelloWorldLayer.mm
//  Box2dSampler
//
//  Created by Justin Shacklette on 9/8/12.
//  Copyright Saturnboy 2012. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"

@implementation HelloWorldLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init {
	if( (self=[super init])) {
		_winsize = [CCDirector sharedDirector].winSize;
        CCLOG(@"window : size=%.0fx%.0f", _winsize.width, _winsize.height);
        
		[self createWorld];
        [self createGround];
        [self createBox];
        [self createCircle];
        [self createDiamond];
        [self createLine];
        
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc {
	delete _world; _world = NULL;
    delete _debug; _debug = NULL;
	[super dealloc];
}

-(void) draw {
	[super draw];
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	kmGLPushMatrix();
	_world->DrawDebugData();	
	kmGLPopMatrix();
}

-(void) createWorld {
	_world = new b2World(b2Vec2(0.0f, -10.0f));
	_world->SetAllowSleeping(true);
	_world->SetContinuousPhysics(true);
    
    _debug = new GLESDebugDraw(PTM_RATIO);
	_debug->SetFlags(b2Draw::e_shapeBit);
    _world->SetDebugDraw(_debug);
}

-(void) createGround {
	b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
	bodyDef.position.Set(0, 0);
	b2Body* body = _world->CreateBody(&bodyDef);
	
	// Define the ground box shape.
	b2EdgeShape shape;		
	
	// bottom
	shape.Set(b2Vec2(0,0), b2Vec2(_winsize.width/PTM_RATIO,0));
	body->CreateFixture(&shape,0);
	
	// top
	shape.Set(b2Vec2(0,_winsize.height/PTM_RATIO), b2Vec2(_winsize.width/PTM_RATIO,_winsize.height/PTM_RATIO));
	body->CreateFixture(&shape,0);
	
	// left
	shape.Set(b2Vec2(0,_winsize.height/PTM_RATIO), b2Vec2(0,0));
	body->CreateFixture(&shape,0);
	
	// right
	shape.Set(b2Vec2(_winsize.width/PTM_RATIO,_winsize.height/PTM_RATIO), b2Vec2(_winsize.width/PTM_RATIO,0));
	body->CreateFixture(&shape,0);
}

-(void) createBox {
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(100.0f/PTM_RATIO, 100.0f/PTM_RATIO);
	_box = _world->CreateBody(&bodyDef);
	
	b2PolygonShape shape;
	shape.SetAsBox(1, 1);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.25f;
	_box->CreateFixture(&fixtureDef);
}

-(void) createCircle {
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(175.0f/PTM_RATIO, 300.0f/PTM_RATIO);
	_circle = _world->CreateBody(&bodyDef);
	
	b2CircleShape shape;
    shape.m_radius = 1.0f;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;
    fixtureDef.restitution = 0.75f;
	_circle->CreateFixture(&fixtureDef);
}

-(void) createDiamond {
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(140.0f/PTM_RATIO, 200.0f/PTM_RATIO);
    bodyDef.angle = CC_DEGREES_TO_RADIANS(15.0f);
	_diamond = _world->CreateBody(&bodyDef);
	
	b2PolygonShape shape;
    b2Vec2 verts[] = { b2Vec2(0.5f,0), b2Vec2(0,1), b2Vec2(-0.5f,0), b2Vec2(0,-1.2) };
    shape.Set(verts, 4);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;	
	_diamond->CreateFixture(&fixtureDef);
}

-(void) createLine {
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
	bodyDef.position.Set(0, 0);
	_line = _world->CreateBody(&bodyDef);
	
	b2EdgeShape shape;
    b2Vec2 p1(_winsize.width/3/PTM_RATIO, 1);
    b2Vec2 p2(_winsize.width/PTM_RATIO-2, _winsize.height/2/PTM_RATIO);
    shape.Set(p1,p2);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;
	_line->CreateFixture(&fixtureDef);
}

-(void) update:(ccTime)dt {
	_world->Step(dt, 8, 2);
}

@end
