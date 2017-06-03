//
//  Constants.h

// Physic collision bitmasks

static NSString* ballCategoryName 	= @"ball";
static const CGFloat ballCategoryZIndex = 4;

static NSString* floorCategoryName 	= @"floor";

static NSString* coinCategoryName 	= @"coin";
static const CGFloat coinCategoryZIndex = 5;

static NSString* paperPlaineCategoryName 	= @"paperPlaine";
static const CGFloat paperPlaineCategoryZIndex = 10;

static NSString* callCategoryName 	= @"callPlaine";
static const unsigned int callAtTime = 10;

static NSString* invulnerabilityFileName = @"dubble";
static NSString* invulnerabilityCategoryName 	= @"dubblePlaine";
static const CFTimeInterval invulnerabilityToTime = 8;
static const CFTimeInterval invulnerabilityLiveTime = 8;

static NSString* backgroundCategoryName_l0 	= @"background-layer_0";
static NSString* backgroundCategoryName_l1 	= @"background-layer_1";
static NSString* backgroundCategoryName_l2 	= @"background-layer_2";
static const CGFloat backgroundCategoryName_l0ZIndex = 1;
static const CGFloat backgroundCategoryName_l1ZIndex = 2;
static const CGFloat backgroundCategoryName_l2ZIndex = 3;
static NSString* backgroundCategoryName_l0_ImgName 	= @"background-layer_0";
static NSString* backgroundCategoryName_l0_ImgName_red 	= @"background-layer_0_red";
static NSString* backgroundCategoryName_l1_ImgName  	= @"background-layer_1";
static NSString* backgroundCategoryName_l2_ImgName  	= @"background-layer_2";

static const CGFloat sunCategoryNameZIndex = 2.1;

static NSString* cloudCategoryName 	= @"cloud";
static const CGFloat cloudCategoryNameZIndex = 2.11;

// Physic collision bitmasks
static const uint32_t paperPlaineCategory  		= 0x1 << 0;  // 00000000000000000000000000000001
static const uint32_t floorCategory 			= 0x1 << 1;  // 00000000000000000000000000000010
static const uint32_t coinCategory 				= 0x1 << 2;  // 00000000000000000000000000000100
static const uint32_t ballCategory 				= 0x1 << 3;  // 00000000000000000000000000001000
static const uint32_t callCategory 				= 0x1 << 4;  // 00000000000000000000000000010000
static const uint32_t invulnerabilityCategory 	= 0x1 << 5;  // 00000000000000000000000000100000

#define kCoin1FileName                       @"Coin1.png"
#define kCoin2FileName                       @"Coin2.png"
#define kCoin3FileName                       @"Coin3.png"

//
#define TIME 1.2
static const float BG_VELOCITY_PER_SEC_LAYER0 = (TIME * 60) / 1.5;
static const float BG_VELOCITY_PER_SEC_LAYER1 = (TIME * 60);

static const unsigned int TOTAL_GAME_TIME = 25;