//
//  ExtHeader.h
//  XLinkSdk
//
//  Created by xtmac02 on 15/1/5.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#ifndef XLinkSdk_ExtHeader_h
#define XLinkSdk_ExtHeader_h

typedef unsigned char       __b1;
typedef unsigned short      __b2;
typedef unsigned int        __b4;
typedef unsigned long long  __b8;


static const int macLen = 6;


//运行状态宏
//#define LOGIN_FAILURE_FLAG 100
//#define LOGIN_SUCCESS_FLAG 101
//
//#define CONNECT_FAILURE_FLAG 102
//#define CONNECT_SUCCESS_FLAG 103
//
//#define SET_FAILURE_FLAG 104
//#define SET_SUCCESS_FLAG 105
//
//#define SYNC_FAILURE_FLAG 106
//#define SYNC_SUCCESS_FLAG 107

//#define PIPE_FAILURE_FLAG 108
//#define PIPE_SUCCESS_FLAG 109
///////

//changl

//外网协议

/*
 消息类型定义
 */

//设备激活
#define ACTIVATE_REQ_MESSAGE 0
#define ACTIVATE_RSP_MESSAGE 8

//APP连接上服务器，并完成动作
#define LOGIN_REQ_MESSAGE 16
#define LOGIN_RSP_MESSAGE 24

//设备连接上服务器，并完成了验证动作
#define CONNECT_REQ_MESSAGE 32 + 3
#define CONNECT_RSP_MESSAGE 40

//更新设备属性

//更新设备属性
#define SET_REQ_MESSAGE 48 + 3
#define SET_RSP_MESSAGE 56


//设备属性变化同步
#define SYNC_REQ_MESSAGE 64
#define SYNC_RSP_MESSAGE 72

//云端设置密码
#define SETPWD_REQ_MESSAGE 0b01010000 + 3
#define SETPWD_RSP_MESSAGE 0b01011000

//数据通道，直接将收到的数据转发到指定的客户端，服务器不做协议实体的解析和分析
#define PIPE_REQ_MESSAGE 112 + 3
#define PIPE_RSP_MESSAGE 120

//数据广播，直接将数据广播给所有的关注的APP或者DEVICE
#define PIPE_SYNC_REQ_MESSAGE 128
#define PIPE_SYNC_RSP_MESSAGE 136

#define PROBE_REQ_MESSAGE 160 + 3
#define PROBE_RSP_MESSAGE 168

//心跳包
#define PING_REQ_MESSAGE 208 + 3
#define PING_RSP_MESSAGE 216

//10010000   9*16 = 4144  10011000
#define SUBSCRIPTION_REQ_MESSAGE 144
#define SUBSCRIPTION_RSP_MESSAGE 152

#define 断开连接
#define DISCONNECT_REQ_MESSAGE 224 + 3
#define DISCONNECT_RSP_MESSAGE 232

#define CLOUDSETPWD_REQ_MESSAGE  80 + 3
#define CLOUDSETPWD_RSP_MESSAGE  88

//原为 14 + 3 不明原因导致-3
#define MSG_XLINK_DISCONNECT        14
#define DISCONNECT_CODE_KICK        3

//预留flag
#define RESERVED_REQ_MESSAGE 240 + 3
#define RESERVED_RSP_MESSAGE 248

#define NOTIFY_REQ_FLAG     0b11000000

#define APP_ID 4

#define AUTH_STR "04e0e8fb4fa94a93ad18659ce41e2b14"

/*
 对齐方式为以1对齐
 */
#pragma pack(1)

//固定协议头
typedef struct FIX_EXT_HEADER{  // 固定协议头
    __b1 MessageInfo;       //byte 1   协议头消息
    __b4 DataLength;        //byte 2-5 数据包的长度
}FIX_EXT_HEADER;


//设备激活协议投
typedef struct ACTIVATE_HEADER{
    __b1 _version;            //byte 1 协议版本
    __b1 _macAddress[6];      //byte 2-7 Mac地址
    __b1 _hardIdentifier;     //byte 8 wifi设备厂商标示
    __b2 _softIdentifier;     //byte 9-10 wifi软件版本
    __b1 _mcuHardVersion;     //byte 11  mcu硬件版本
    __b2 _mcuSoftVersion;     //byte 12-13  mcu 软件版本
    __b2 _activateStrLength;  //byte 14-15  激活码长度
    __b1 _activateStr[32];    //byte 16-47  激活码
    __b1 _activateReserved;   //byte 48     预留
}ACTIVATE_HEADER;


/*
 1 byte1,byte2 为应答 Code,当 Code == 0,表示成功,后面会有 DeviceID 和 Authorize key。Code != 0,后面将无数据
 2 当设备收到 code 0 和 deviceid 以及 authorize code 后,需要将上述信息缓存到本 地,作为 CONNECT 时的认证参数
 */
typedef struct ACTIVATE_RETURN{
    __b1 _code;        //byte 1 code标示
    __b4 _deviceId;    //byte 2-5 deviceId
    __b2 _authorizeLen;   //byte 6-7 authorize长度
    __b1 _authorizeStr[32];//byte 8-39 authorize字符串
}ACTIVATE_RETURN;

//login
typedef struct LOGIN_HEADER{
    __b1 _version;           //byte 1 版本好
    __b4 _appId;             //byte 2-5 app ID
    __b2 _authorizeLen;      //byte 6-7 授权字符串长度
    __b1 _authorizeStr[32];  //byte 8-39 授权字符串
    __b1 _reserved;          //byte 40 预留
    __b2 _keepAliveTime;     //byte 41-42 保持存活时间
    
}LOGIN_HEADER;

typedef struct LOGIN_RETURN{
    __b1 _code;     //byte 1  状态标示
    __b1 _reserved; //byte 2  预留
}LOGIN_RETURN;


//connect
typedef struct CONNECT_HEADER{
    __b1 _version;          //byte 1 协议版本
    __b4 _deviceId;         //byte 2-5 设备ID
    __b2 _authorizeLen;     //byte 6-7   授权字符串长度
    __b4 _authorizeStr;     //byte 8-39  授权字符串
    __b1 _reserved;         //byte 40  预留
    __b2 _keepAliveTime;    //byte 41-42 保持存活时间
    
}CONNECT_HEADER;


typedef struct CONNECT_RETURN{
    __b1 _code;        //byte 1  状态标示
    __b1 _reserved;    //byte 2  预留
}CONNECT_RETURN;



//set
typedef struct SET_HEADER{
    __b4 _deviceId;   //byte 1-4设备ID
    __b2 _messageID;  //byte 5-6 消息ID
    __b1 _setFlag;    //byte 7  有无数据实体标示

}SET_HEADER;

//数据实体为datapoints

typedef struct SET_RETURN{
    __b4 _toID;    //byte 1-4 回应的ID
    __b2 _messageID;//byte 5-6 消息ID
    __b1 _code;     //byte 7 状态标示
    
}SET_RETURN;


//同步 sync
typedef struct SYNC_HEADER{
    __b4 _deviceId;  //byte 1-4  设备ID
    __b2 _messageID; //byte 5-6  消息ID
    __b1 _setFlag;   //byte 7    设置执行状态

}SYNC_HEADER;


typedef struct SYNC_RETURN{
    
    __b2 _messageID;   //byte 1-2消息ID
    __b1 _code;        //byte 3  状态标示

}SYNC_RETURN;

//pipe 数据管道
typedef struct PIPE_HEADER{
    __b4 _deviceId;   //byte 1-4 设备ID
    __b2 _messageID;  //byte 5-6 消息ID
    __b1 _flag;       //byte 7  数据实体标示
}PIPE_HEADER;


typedef struct PIPE_RETURN{
    __b4 _toID;       //byte 1-4 回应的ID
    __b2 _messageID;  //byte 5-6 消息ID
    __b1 _code;       //byte 7   执行
    
}PIPE_RETURN;

//disconnect
typedef struct DISCONNECT_HEADER{
    __b1 _reason;    //byte 1 断开原因
}DISCONNECT_HEADER;

//bucket
typedef struct BUCKET_HEADER{
    __b2 _messageID;     //byte 1-2 消息ID
    __b1 _messageFlag;   //byte 3   消息标示

}BUCKET_HEADER;

//collect
typedef struct COLLECT_HEADER{

}COLLECT_HEADER;

typedef struct SUBSCRIPTION_HEADER{
    __b4 _deviceID;         //byte 1-4 设备ID
    __b2 _deviceKeyLen;     //byte 5-6 设备Key长度
    __b1 _deviceKeyStr[16];     //byte 7-22 设备Key字符串
    __b2 _messageID;        //byte 23-24 消息ID
    __b1 _flag;             //byte 25 标示
}SUBSCRIPTION_HEADER;


typedef struct SUBSCRIPTION_RETURN{
    __b2 _messageID;        //byte 1-2 消息ID
    __b1 _code;             //byte 3 标示
}SUBSCRIPTION_RETURN;

#pragma pack()
#endif
