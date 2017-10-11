//
//  XlinkMessage.m
//  xlinksdklib
//
//  Created by xtmac02 on 15/3/12.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#import "XlinkMessage.h"
#import "DeviceEntity.h"
#import "XLinkCoreObject.h"
#import "XLinkExportObject.h"

@implementation XlinkMessage
-(void)checkTimeOut{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (!_messageID) {
            return;
        }
        
        DeviceEntity *tempDevice = [[XLinkCoreObject sharedCoreObject] getMessageDeviceByMessageID:_messageID];
        
        if (tempDevice) {
            
            //超时回调
            switch (_messageType) {
                    
                case MSG_TYPE_SET_LOCAL_AUTH:
                {
                    //本地设置密码超时回调
                    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSetLocalDeviceAuthorizeCode:withResult:withMessageID:)]) {
                        [[XLinkExportObject sharedObject].delegate onSetLocalDeviceAuthorizeCode:tempDevice withResult:CODE_TIMEOUT withMessageID:_messageID];
                    }
                }
                    break;
                    
                case MSG_TYPE_SEND_LOCAL_PIPE:
                {
                    //本地PIPE超时回调
                    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSendLocalPipeData:withResult:withMessageID:)]) {
                        [[XLinkExportObject sharedObject].delegate onSendLocalPipeData:tempDevice withResult:CODE_TIMEOUT withMessageID:_messageID];
                    }
                    
                }
                    break;
                    
                case MSG_TYPE_SUBSCRIBE_CLOUD:
                {
                    //订阅超时回调
                    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSubscription:withResult:withMessageID:)]) {
                        [[XLinkExportObject sharedObject].delegate onSubscription:tempDevice withResult:CODE_TIMEOUT withMessageID:_messageID];
                    }
                }
                    break;
                    
                case MSG_TYPE_SET_CLOUD_AUTH:
                {
                    //云端设置密码超时回调
                    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSetDeviceAuthorizeCode:withResult:withMessageID:)]) {
                        [[XLinkExportObject sharedObject].delegate onSetDeviceAuthorizeCode:tempDevice withResult:CODE_TIMEOUT withMessageID:_messageID];
                    }
                }
                    break;
                    
                case MSG_TYPE_SEND_CLOUD_PIPE:
                {
                    //发送云端pipe回调
                    if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onSendPipeData:withResult:withMessageID:)]) {
                        [[XLinkExportObject sharedObject].delegate onSendPipeData:tempDevice withResult:CODE_TIMEOUT withMessageID:_messageID];
                    }
                    
                    
                }
                    break;
                    
                case MSG_TYPE_SEND_CLOUD_PROBE:
                {
                    /* 探测超时，不放在这个里面
                     NSLog(@"云端探测超时");
                     if ([[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onDeviceProbe:withResult:withMessageID:)]) {
                     [[XLinkExportObject sharedObject].delegate onDeviceProbe:tempDevice withResult:-100 withMessageID:_messageID];
                     }
                     */
                }
                    break;
                case MSG_TYPE_SEND_LOCAL_HANK:{
                    if ([XLinkExportObject sharedObject].isConnectDevice && [XLinkCoreObject sharedCoreObject].isLoginSuccessed) {
//                        tempDevice.isCloud = YES;
                        if (tempDevice.deviceID != 0) {
                            [[XLinkExportObject sharedObject] probeDevice:tempDevice];
                        }else{
                            [[XLinkCoreObject sharedCoreObject] subscribeDevice:tempDevice andAuthKey:[XLinkExportObject sharedObject].accessKey andFlag:YES];
                        }
                    }else{
                        if( [[XLinkExportObject sharedObject].delegate respondsToSelector:@selector(onHandShakeWithDevice:withResult:)]) {
                            [[XLinkExportObject sharedObject].delegate onHandShakeWithDevice:tempDevice withResult:-1];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
            
            [[XLinkCoreObject sharedCoreObject] removeMessageByMessageID:_messageID];
            
        }
    });
}
@end
