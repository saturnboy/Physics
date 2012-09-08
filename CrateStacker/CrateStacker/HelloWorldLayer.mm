//
//  HelloWorldLayer.mm
//  CrateStacker
//
//  Created by Justin Shacklette on 9/8/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "Crate.h"

#define TAG_SPRITESHEET 1

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) createWorld;
-(void) createGround;
-(void) addCrate:(CGPoint)pos;
@end

@implementation HelloWorldLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init {
	if( (self=[super init])) {
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
        // compute window size
		_winsize = [CCDirector sharedDirector].winSize;
        CCLOG(@"window : size=%.0fx%.0f", _winsize.width, _winsize.height);
        
		// init box2d world
		[self createWorld];
        
        // create the ground
        [self createGround];
        
        // compute texture filename
        NSString *texturePlist = @"tex.plist";
        NSString *textureFile = @"tex.png";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            texturePlist = @"tex-hd.plist";
            textureFile = @"tex-hd.png";
        }
        
        // load texture into spritesheet
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:texturePlist];
        CCSpriteBatchNode *sheet = [CCSpriteBatchNode batchNodeWithFile:textureFile];
        [self addChild:sheet z:0 tag:TAG_SPRITESHEET];
		
		[self addCrate:ccp(_winsize.width/2, _winsize.height/2)];
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc {
	delete _world;
	_world = NULL;
	
	//delete m_debugDraw;
	//m_debugDraw = NULL;
	
	[super dealloc];
}	

-(void) createWorld {
    b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	_world = new b2World(gravity);
	
	_world->SetAllowSleeping(true);
	_world->SetContinuousPhysics(true);
}

-(void) createGround {
	b2BodyDef groundBodyDef;
    groundBodyDef.type = b2_staticBody;
	groundBodyDef.position.Set(0, 0);
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = _world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	groundBox.Set(b2Vec2(0,0), b2Vec2(_winsize.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,_winsize.height/PTM_RATIO), b2Vec2(_winsize.width/PTM_RATIO,_winsize.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,_winsize.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(_winsize.width/PTM_RATIO,_winsize.height/PTM_RATIO), b2Vec2(_winsize.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
}

-(void) addCrate:(CGPoint)pos {
	CCNode *sheet = [self getChildByTag:TAG_SPRITESHEET];
	
	Crate *crate = [Crate spriteWithSpriteFrameName:@"crate.png"];
    crate.position = pos;
	[sheet addChild:crate];
    
    CCLOG(@"add crate : pos=(%.1f,%.1f) sz=%.1fx%.1f", pos.x, pos.y, crate.contentSize.width, crate.contentSize.height);
    
    // Define the dynamic body.
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(pos.x/PTM_RATIO, pos.y/PTM_RATIO);
    bodyDef.userData = crate;
	b2Body *body = _world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
    
    // half-width & half-height of our crate (in meters)
	dynamicBox.SetAsBox(crate.contentSize.width/2/PTM_RATIO, crate.contentSize.height/2/PTM_RATIO);
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.25f;
	body->CreateFixture(&fixtureDef);
	
	crate.body = body;
}

-(void) update:(ccTime)dt {
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 2;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	_world->Step(dt, velocityIterations, positionIterations);
    
    for(b2Body *b = _world->GetBodyList(); b; b = b->GetNext()) {    
        if (b->GetUserData() != NULL) {
            Crate *crate = (Crate *) b->GetUserData();
            crate.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            crate.rotation = -CC_RADIANS_TO_DEGREES(b->GetAngle());
        }        
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		CGPoint pos = [touch locationInView: [touch view]];
		pos = [[CCDirector sharedDirector] convertToGL:pos];
		[self addCrate:pos];
	}
}

@end
