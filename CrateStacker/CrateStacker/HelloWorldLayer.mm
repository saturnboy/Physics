//
//  HelloWorldLayer.mm
//  CrateStacker
//
//  Created by Justin Shacklette on 9/8/12.
//  Copyright Saturnboy 2012. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "Crate.h"

#define TAG_SPRITESHEET 1

#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) createWorld;
-(void) createGround;
-(void) createFunnel;
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
        
        // init the world
        [self createWorld];
        [self createGround];
        //[self createFunnel];
        
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
    //_world->SetDebugDraw(_debug);
}

-(void) createGround {
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(0, 0);
    b2Body* body = _world->CreateBody(&bodyDef);
    
    // Define the ground box shape.
    b2EdgeShape shape;		
    b2Vec2 bl = b2Vec2(0,0);
    
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

-(void) createFunnel {
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(0, 0);
	
    b2Body* body = _world->CreateBody(&bodyDef);
	
    // Define the ground box shape.
    b2EdgeShape shape;		
	
    // right
    shape.Set(b2Vec2(_winsize.width*0.667/PTM_RATIO, 0), b2Vec2(_winsize.width/PTM_RATIO, _winsize.height/2/PTM_RATIO));
    body->CreateFixture(&shape,0);
	
    // left
    shape.Set(b2Vec2(_winsize.width*0.333/PTM_RATIO, 0), b2Vec2(0, _winsize.height/2/PTM_RATIO));
    body->CreateFixture(&shape,0);
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
