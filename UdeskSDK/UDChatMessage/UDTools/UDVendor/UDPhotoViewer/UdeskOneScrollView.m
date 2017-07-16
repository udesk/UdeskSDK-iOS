//
//  UdeskOneScrollView.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskOneScrollView.h"
#import "UdeskFoundationMacro.h"
#import "UdeskManager.h"
#import "UdeskFoundationMacro.h"
#import "Udesk_YYWebImage.h"

#define AnimationTime 0.25

@interface UdeskOneScrollView()<UIScrollViewDelegate>
{
    BOOL _isdoubleTap;//记录是否是双击放大,还是单机返回 的一个动作判断参数
    
}

//保存图片
@property(nonatomic,weak) UIImageView *mainImageView;

//双击动作,在下载完图片后才会有双击手势动作
@property(nonatomic,strong)UITapGestureRecognizer *twoTap;

//返回去的位置
@property(nonatomic,weak)UIImageView *originalImageView;

@end
@implementation UdeskOneScrollView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //页面不能点击
        self.userInteractionEnabled = NO;
        
        //代理
        self.delegate = self;
        
        //添加主图片显示View
        UIImageView *mainImageView = [[Udesk_YYAnimatedImageView alloc]init];
        mainImageView.userInteractionEnabled = YES;
        [self addSubview:mainImageView];
        self.mainImageView = mainImageView;
        
        //点击时返回退出
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
        [tap addTarget:self action:@selector(goBack:)];
        [tap setNumberOfTapsRequired:1];
        [self addGestureRecognizer:tap];
        
        //双击
        UITapGestureRecognizer *twoTap = [[UITapGestureRecognizer alloc]init];
        [twoTap addTarget:self action:@selector(beginZoom:)];
        [twoTap setNumberOfTapsRequired:2];
        self.twoTap = twoTap;
       
        
        //系统默认的 双击单机共存 但是速度有点慢
       // [tap requireGestureRecognizerToFail:twoTap];
        
    }
    return self;
}


#pragma mark - 加载图片
-(void)setLocalImage:(UIImageView *)imageView withMessageURL:(NSString *)url
{

    //初始位置
    self.originalImageView = imageView;
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    CGRect originalRect = [imageView convertRect: imageView.bounds toView:window];
    self.mainImageView.frame = originalRect;
    
    //动画变换设置frame
    [UIView animateWithDuration:AnimationTime animations:^{
        
        [self setFrameAndZoom:imageView withMessageURL:url];
        self.superview.backgroundColor = [UIColor blackColor];
        
    } completion:^(BOOL finished) {
        
        self.userInteractionEnabled = YES ;
        [self.mainImageView addGestureRecognizer:self.twoTap];
    }];
    
}

#pragma mark - 🈲计算frame 核心代码
-(void)setFrameAndZoom:(UIImageView *)imageView withMessageURL:(NSString *)url
{
    //ImageView.image的大小
    CGFloat   imageH;
    CGFloat   imageW;

    //设置空image时的情况
    if(imageView.image == nil || imageView.image.size.width == 0 || imageView.image.size.height ==0)
    {
        //设置主图片
        imageH = UD_SCREEN_HEIGHT;
        imageW = UD_SCREEN_WIDTH;
        self.mainImageView.image = [UIImage imageNamed:@"none"];
        
    }else//不空
    {
        //设置主图片
        imageW  = imageView.image.size.width;
        imageH = imageView.image.size.height;
        //放大的图片 显示原图片 不缩小
        self.mainImageView.image = imageView.image;
        [self.mainImageView yy_setImageWithURL:[NSURL URLWithString:url] placeholder:imageView.image];
    }
    
    //设置主图片Frame 与缩小比例
    if(imageW >= (imageH * (UD_SCREEN_WIDTH/UD_SCREEN_HEIGHT)))//横着
    {
        
        //设置居中frame
        CGFloat  myX_ =  0;
        CGFloat  myW_ = UD_SCREEN_WIDTH;
        CGFloat  myH_  = myW_ *(imageH/imageW);;
        CGFloat  myY_ = UD_SCREEN_HEIGHT - myH_ - ((UD_SCREEN_HEIGHT - myH_)/2);
        
        
        self.mainImageView.frame = CGRectMake(myX_, myY_, myW_, myH_);
        
        
        //判断原图是小图还是大图来判断,是可以缩放,还是可以放大
        if (imageW >  myW_) {
            self.maximumZoomScale = 2*(imageW/myW_ ) ;//放大比例

        }else
        {
            self.minimumZoomScale = (imageW/myW_);//缩小比例
   
        }
        
        
    }else//竖着
    {
        
        CGFloat  myH_ = UD_SCREEN_HEIGHT;
        CGFloat  myW_ = myH_ *(imageW/imageH);
        CGFloat  myX_ = UD_SCREEN_WIDTH - myW_ - ((UD_SCREEN_WIDTH - myW_)/2);
        CGFloat  myY_ = 0;
        
        //变换设置frame
        self.mainImageView.frame = CGRectMake(myX_, myY_, myW_, myH_);
        
        //判断原图是小图还是大图来判断,是可以缩放,还是可以放大
        
        if (imageH >  myH_) {
            self.maximumZoomScale =  2*(imageH/myH_ ) ;//放大比例
         
        }else
        {
            self.minimumZoomScale = (imageH/myH_);//缩小比例
        }
    }
    
}

//开始缩放,一开始会自动调用几次,并且要返回告来诉scroll我要缩放哪一个控件.
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
       return self.mainImageView;
}


//缩放时调用 ,确定中心点代理方法
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    CGSize scrollSize = scrollView.bounds.size;
    CGRect imgViewFrame = self.mainImageView.frame;
    CGSize contentSize = scrollView.contentSize;
    CGPoint centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
    
    // 竖着长的 就是垂直居中
    if (imgViewFrame.size.width <= scrollSize.width)
    {
        centerPoint.x = scrollSize.width/2;
    }
    
    // 横着长的  就是水平居中
    if (imgViewFrame.size.height <= scrollSize.height)
    {
        centerPoint.y = scrollSize.height/2;
    }
    
    self.mainImageView.center = centerPoint;
}

//单机返回
-(void)goBack:(UITapGestureRecognizer *)tap
{
    _isdoubleTap = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (_isdoubleTap) return;
        
        UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
        CGRect newOriginalRect = [self.originalImageView convertRect: self.originalImageView.bounds toView:window];
        
        self.userInteractionEnabled = NO;
        self.zoomScale = 1;
        self.delegate = nil;
        
        [UIView animateWithDuration:AnimationTime animations:^{
            
            self.mainImageView.frame = newOriginalRect;
            self.superview.backgroundColor = [UIColor clearColor];
            
        } completion:^(BOOL finished) {
            
            if([self.mydelegate respondsToSelector:@selector(goBack)])
            {
                [self.mydelegate goBack];
            }
            
        }];
        
    });
    
}


//双击放大或者缩小
-(void)beginZoom:(UITapGestureRecognizer*)tap
{

    _isdoubleTap = YES;
    CGPoint touchPoint = [tap locationInView:self.mainImageView];
    if (self.zoomScale == self.maximumZoomScale) {//缩小
        [self setZoomScale:1.0 animated:YES];
    } else {//放大
       
        CGRect zoomRect = CGRectMake(touchPoint.x, touchPoint.y, self.mainImageView.frame.size.width, self.mainImageView.frame.size.height);
        [self zoomToRect:zoomRect animated:YES];
    }
}

-(void)reloadFrame
{
    self.zoomScale = 1;
}

-(void)dealloc
{
    self.delegate = nil;
}


@end
