//
//  HelloWorldLayer.mm
//  CrateSpring
//
//  Created by Justin Shacklette on 9/8/12.
//  Copyright Saturnboy 2012. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "Entity.h"

#define TAG_SPRITESHEET 1
#define TAG_ARROW 2
#define TAG_CRATE 3
#define TAG_ROCK 4
#define TAG_SPRING 5

#define ACCELEROMETER_INTERP_FACTOR 0.1f
#define MAX_CRATES 16
#define IMPULSE_FACTOR 2.0f

@interface HelloWorldLayer()
-(void) createWorld;
-(void) createCrate;
-(void) createRock;
-(void) createSpring;
-(void) createJoints;
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
		
        // init crate
        [self createCrate];
        
        // init rock
        [self createRock];
        
        // init spring
        [self createSpring];
        
        // init joints
        [self createJoints];
        
        // init arrow
        _arrow = [CCSprite spriteWithSpriteFrameName:@"arrow.png"];
        _arrow.position = ccp(_winsize.width/2, _winsize.height/2);
        _arrow.anchorPoint = ccp(0.25f,0.5f);
        [self addChild:_arrow z:2 tag:TAG_ARROW];
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc {
	delete _world;
	_world = NULL;
    
    delete _debug;
	_debug = NULL;
	
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
	_world = new b2World(b2Vec2(0.0f, 0.0f));
	_world->SetAllowSleeping(true);
	_world->SetContinuousPhysics(true);
    
    _debug = new GLESDebugDraw(PTM_RATIO);
	_debug->SetFlags(b2Draw::e_shapeBit + b2Draw::e_jointBit);
    //_world->SetDebugDraw(_debug);
}

-(void) createCrate {
	CCNode *sheet = [self getChildByTag:TAG_SPRITESHEET];
	
	_crate = [Entity spriteWithSpriteFrameName:@"crate.png"];
    _crate.position = ccp(_winsize.width/2, 100.0f);
	[sheet addChild:_crate z:0 tag:TAG_CRATE];
    
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(_crate.position.x/PTM_RATIO, _crate.position.y/PTM_RATIO);
    bodyDef.userData = _crate;
    bodyDef.allowSleep = false;
	b2Body *body = _world->CreateBody(&bodyDef);
	
	b2PolygonShape shape;
    
    // half-width & half-height of our crate (in meters)
	shape.SetAsBox(_crate.contentSize.width/2/PTM_RATIO, _crate.contentSize.height/2/PTM_RATIO);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.25f;
	body->CreateFixture(&fixtureDef);
	
	_crate.body = body;
}

-(void) createRock {
	CCNode *sheet = [self getChildByTag:TAG_SPRITESHEET];
	
	_rock = [Entity spriteWithSpriteFrameName:@"bigrock.png"];
    _rock.position = ccp(_winsize.width/2, _winsize.height/2);
	[sheet addChild:_rock z:1 tag:TAG_ROCK];
    
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(_rock.position.x/PTM_RATIO, _rock.position.y/PTM_RATIO);
    bodyDef.userData = _rock;
    bodyDef.allowSleep = false;
	b2Body *body = _world->CreateBody(&bodyDef);
	
	b2CircleShape shape;
    shape.m_radius = _rock.contentSize.width/2/PTM_RATIO;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.25f;
	body->CreateFixture(&fixtureDef);
    
	_rock.body = body;
}

-(void) createSpring {
	CCNode *sheet = [self getChildByTag:TAG_SPRITESHEET];
	
	_spring = [Entity spriteWithSpriteFrameName:@"spring.png"];
    _spring.position = ccp(_winsize.width/2, _winsize.height/2);
	[sheet addChild:_spring z:3 tag:TAG_SPRING];

	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(_spring.position.x/PTM_RATIO, _spring.position.y/PTM_RATIO);
    bodyDef.userData = _spring;
    bodyDef.allowSleep = false;
	b2Body *body = _world->CreateBody(&bodyDef);
	
	b2PolygonShape shape;
    shape.SetAsBox(_spring.contentSize.width/2/PTM_RATIO, _spring.contentSize.height/2/PTM_RATIO);
    //CCLOG(@"spring sz: %.3fx%.3f", _spring.contentSize.width/2/PTM_RATIO, _spring.contentSize.height/2/PTM_RATIO);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.2f;
    fixtureDef.restitution = 0.25f;
	body->CreateFixture(&fixtureDef);
    
	_spring.body = body;
}

-(void) createJoints {
    // attach spring to rock
    b2RevoluteJointDef jointDef;
    jointDef.bodyA = _rock.body;
    jointDef.bodyB = _spring.body;
    jointDef.collideConnected = false;
    
    // anchor spring to center of rock
    jointDef.localAnchorA.Set(0,0);
    
    // anchor rock to top of spring
    jointDef.localAnchorB.Set(0,_spring.contentSize.height/2/PTM_RATIO);
    
    // add some 'friction' via a speedless motor
    jointDef.maxMotorTorque = 25.0f;
    jointDef.motorSpeed = 0.0f;
    jointDef.enableMotor = true;
    
    _world->CreateJoint( &jointDef );
    
    // attach spring to crate
    b2RevoluteJointDef joint2Def;
    joint2Def.bodyA = _spring.body;
    joint2Def.bodyB = _crate.body;
    joint2Def.collideConnected = false;
    
    // anchor crate to bottom of spring
    joint2Def.localAnchorA.Set(0,-_spring.contentSize.height/2/PTM_RATIO);
    
    // anchor spring to center of crate
    joint2Def.localAnchorB.Set(0,0);
    
    // add some 'friction' via a speedless motor
    joint2Def.maxMotorTorque = 100.0f;
    joint2Def.motorSpeed = 0.0f;
    joint2Def.enableMotor = true;
    
    _world->CreateJoint( &joint2Def );
}

/*
-(void) createDistanceJoint {
    // attach crate to rock
    b2DistanceJointDef jointDef;
    jointDef.bodyA = _rock.body;
    jointDef.bodyB = _crate.body;
    jointDef.collideConnected = false;
    
    // anchor spring to center of rock
    jointDef.localAnchorA.Set(0,0);
    
    // anchor spring to center of crate
    jointDef.localAnchorB.Set(0,0);
    
    jointDef.frequencyHz = 4.0f;
    jointDef.dampingRatio = 0.5f;
    jointDef.length = _spring.contentSize.height/PTM_RATIO;
    
    _world->CreateJoint( &jointDef );
}
*/

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
            Entity *entity = (Entity *) b->GetUserData();
            entity.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            entity.rotation = -CC_RADIANS_TO_DEGREES(b->GetAngle());
        }        
    }
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {    
    _accelerometer = ccpLerp(_accelerometer, ccp(-acceleration.x, -acceleration.y), ACCELEROMETER_INTERP_FACTOR);
    float angle = -CC_RADIANS_TO_DEGREES(ccpToAngle(_accelerometer));
    //CCLOG(@"ang=%.3f mag=%.5f", angle, ccpLength(_accelerometer));
    
    // rotate arrow
    _arrow.rotation = angle + 180.0f;
   
    // update gravity
    b2Vec2 gravity(_accelerometer.x * -10.0f, _accelerometer.y * -10.0f);
    _world->SetGravity( gravity );
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (_world->GetBodyCount() > MAX_CRATES) return;
        
		CGPoint pos = [touch locationInView: [touch view]];
		pos = [[CCDirector sharedDirector] convertToGL:pos];
        
        // compute target vector to get crate to touch pos
        b2Vec2 target = b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO) - _crate.body->GetPosition();
        
        //CCLOG(@"pos: (%.3f, %.3f)", pos.x, pos.y);
        //CCLOG(@"crate pos: (%.3f, %.3f)", _crate.body->GetPosition().x * PTM_RATIO, _crate.body->GetPosition().y * PTM_RATIO);
        //CCLOG(@"target: (%.3f, %.3f)", target.x * PTM_RATIO, target.y * PTM_RATIO);
        
        // scale impulse
        target *= IMPULSE_FACTOR;
        
        // give crate a kick in towards the target 
        _crate.body->ApplyLinearImpulse(target, b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO));
	}
}

@end
