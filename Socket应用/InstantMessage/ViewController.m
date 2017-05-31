//
//  AppDelegate.h
//  InstantMessage
//
//  Created by 郭吉刚 on 16/5/24.
//  Copyright © 2016年 郭吉刚. All rights reserved.
//

#import "ViewController.h"
#import <AsyncSocket.h>
//#import <GCDAsyncSocket.h>
@interface ViewController ()<AsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UILabel *hostName;
@property (weak, nonatomic) IBOutlet UILabel *portName;
@property (weak, nonatomic) IBOutlet UITextField *host;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextView *historytext;
@property (weak, nonatomic) IBOutlet UITextView *massageText;

@property(nonatomic,strong) AsyncSocket * socket;
@property(nonatomic,strong) NSDateFormatter * format;
- (IBAction)sendClick:(UIButton *)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)connect:(id)sender;
@end

@implementation ViewController
-(AsyncSocket *)socket{

    if (!_socket) {
        _socket=[[AsyncSocket alloc]initWithDelegate:self];
    }
    return _socket;
}
-(NSDateFormatter *)format{
    if (!_format) {
        _format=[[NSDateFormatter alloc]init];
        [_format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _format;
}
/**
 *  发送数据包给服务器
 *
 *  @param sender 发送按钮
 */
- (IBAction)sendClick:(UIButton *)sender {
    
    //发给服务器
    NSString * msg = self.massageText.text;
    NSDictionary * dic =@{@"user":@"客户端1",@"massage":msg};
    [self.socket writeData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil] withTimeout:3 tag:1];
    NSLog(@"已经发送，请等待发送结果");
    [self.socket readDataWithTimeout:-1 tag:0];
  
}
/**
 *  断开连接
 *
 *  @param sender 断开连接按钮
 */
- (IBAction)disconnect:(id)sender {
    //断开连接
    [self.socket disconnect];
}

/**
 *  与服务器建立长连接
 *
 *  @param sender
 */
- (IBAction)connect:(id)sender {
    NSError * error=nil;
    NSLog(@"%@====%@",self.host.text,self.port.text);
   BOOL result= [self.socket connectToHost:self.host.text onPort:[self.port.text integerValue] error:&error];
    NSLog(@"%d连接结果%@",result,error);
}

#pragma mark * AsyncSocketDelegate
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"连接成功");
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"即将失去连接%@",err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"失去连接");
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{   [self.socket readDataWithTimeout:-1 tag:0];
    NSLog(@"发送数据");
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    UIApplicationState  state = [UIApplication sharedApplication].applicationState;
    if (state==UIApplicationStateBackground) {
        NSInteger number = [UIApplication sharedApplication].applicationIconBadgeNumber;
        NSLog(@"设置程序标示后台情况下%ld",number);
        number++;
        NSLog(@"%ld",number);
        NSLog(@"%@",[NSThread currentThread]);
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
       
    }
    
   //将数据包转换为字符串
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   
    NSString * datestring = [self.format stringFromDate:[NSDate date]];
    NSString * massege =[datestring stringByAppendingString:[NSString stringWithFormat:@":%@",aStr]];
    NSLog(@"%@",massege);
    NSString * text = self.historytext.text;
    text=[text stringByAppendingString:[NSString stringWithFormat:@"\n%@",massege]];
    NSLog(@"====%@",text);
    self.historytext.text=text;
    [self.socket readDataWithTimeout:-1 tag:0];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}



@end
