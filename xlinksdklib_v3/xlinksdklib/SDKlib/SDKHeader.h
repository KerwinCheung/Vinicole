//
//  SDKHeader.h
//  XLinkSdk
//
//  Created by xtmac02 on 14/12/24.
//  Copyright (c) 2014年 xtmac02. All rights reserved.
//

#ifndef XLinkSdk_SDKHeader_h
#define XLinkSdk_SDKHeader_h


typedef unsigned char       __b1;
typedef unsigned short      __b2;
typedef unsigned int        __b4;
typedef unsigned long long  __b8;

#pragma mark
#pragma mark 本地

#define SCAN_REQ_FLAG       0b00010000 //v1 v2 v3
#define SCAN_RSP_FLAG       0b00011000 //v1 v2 v3

#define HANDSHAKE_REQ_FLAG  0b00100000 //v1 v2 v3
#define HANDSHAKE_RSP_FLAG  0b00101000 //v1 v2 v3

#define PROBE_REQ_FLAG      0b00110000 //v1 v2 v3
#define PROBE_RSP_FLAG      0b00111000 //v1 v2 v3

#define SET_REQ_FLAG        0b01000000 //v1 v2 v3
#define SET_RSP_FLAG        0b01001000 //v1 v2 v3

#define SYNC_REQ_FLAG       0b01010000 //v1 v2 v3
#define SYNC_RSP_FLAG       0b01011000 //v1 v2 v3

#define SUBKEY_REQ_FLAG     0b01110000 //      v3
#define SUBKEY_RSP_FLAG     0b01111000 //      v3

#define PIPE_REQ_FLAG       0b10000000 //v1 v2 v3
#define PIPE_RSP_FLAG       0b10001000 //v1 v2 v3

#define SETPSW_REQ_FLAG     0b10010000 //v1
#define SETPSW_RSP_FLAG     0b10011000 //v1

#define SETACK_REQ_FLAG     0b10110000 //v1 v2 v3
#define SETACK_RSP_FLAG     0b10111000 //v1 v2 v3

#define PING_REQ_FLAG       0b11010000 //v1 v2 v3
#define PING_RSP_FLAG       0b11011000 //v1 v2 v3

#define BYBBYE_REQ_FLAG     0b11100000 //v1 v2 v3
#define BYBBYE_RSP_FLAG     0b11101000 //v1 v2 v3

#define Reserved_REQ_FLAG   0b11110000
#define Reserved_RSP_FLAG   0b11111000



#define DEVICE_KEY_LENGTH 16
#define MAC_ADDRESS_LENGTH 6
#define PRODUCT_ID_LENGTH 32


/*
 *****constraint******
 1.device key用来进行数据加密解密和本地的Device SN无关，产生方式待定
 2.UDP通信的定位：
    a.Session ID：app发送HANDSHAKE后，device产生一个Session ID并且返回给APP，Device保证Session ID能够对应上App，app主动发送请求到Deviece时，必须要带上Session ID
    b.Device 主动推送消息给app时，消息包中有Mac地址，app通过Mac地址来定位设备
 3.数据实体中的UTF-8字符串
    a.字符串数据由2个byte的长度定义＋UTF8编码后的数据包组成
 4.数据实体中的DataPoint的描述
    a.DataPoint默认全部发送
    b.在DataPoint的数据实体前，有可变个bit(8个bit对应一个byte)用来描述
 */

/*
 
 */
#pragma pack(1)
//typedef struct FIX_HEADER{  // 固定协议头
//    __b1 HeadInfo;          // 协议头消息
//    __b4 DataLength;        // 数据包的长度
//}FIX_HEADER;


/*******************
 1  app上线网络后，扫描本网段中所有Wi-Fi的设备，app广播，UDP,端口号35222
 */

//扫描协议头

//typedef struct SCAN_HEADER_PACKET{
//    
//    __b1  _Version;              //协议头版本
//    __b2  _Port;                 //端口号
//    __b1  _Reserved;             //预留
//    
//}SCAN_HEADER_PACKET;





//无协议载荷数据

//回包
//typedef struct SCAN_RETRUN_PACKET{
//    
//    __b1 Version;               //版本号                1
//    __b1 MacAddress[MAC_ADDRESS_LENGTH];         //Mac地址               7
//    __b2 Length;                //pruductId字符串长度    9
//    __b1 PruductID[PRODUCT_ID_LENGTH];         //pruductID             41
//    
//    __b1 MCUVersion;            //硬件版本                42
//    __b2 MCU_SOFT_Version;      //软件版本                44
//    
//    __b2 DeviceKeyLength;       //设备Key长度            46
//    __b1 DeviceKeyStr[DEVICE_KEY_LENGTH];      //设备key                78
//    
//    __b2 DeviceUdpPort;         //port（device监听UDP数据端口，预留，暂时不允许自定义）         80
//    __b1 flag;                  //name flag (0, 字符串)表示payload中有name字符串   data point(1)表示payload中有dp 设置（默认设置为0，不发datapoint）reserved   81
//
//}SCAN_RETRUN_PACKET;

/*
 
 */
//typedef struct DATA_POINT_PAYLOAD_PACKET{
//
//
//}DATA_POINT_PAYLOAD_PACKET;





/*******************
 2  a.app告诉设备，app上线，设备记录app状态（IP，通信端口等。。。）以及app支持的版本协议
    b. 设备返回自己支持的协议版本，若app版本低于设备协议版本，app需要提示用户进行app升级
    c.  设备收到app的握手包后，需要在程序内部维护这个app的在线状态（主要是ping的处理）
    d.app若收到回包则表示设备在线
 */

//协议头包
//typedef struct HANDSHAKE_HEADER_PACKET{
//    __b1 _Version;               //协议版本
//    __b2 _DeviceKeyLength;       //key长度
//    __b1 _DeviceKeyStr[DEVICE_KEY_LENGTH];      //key字符串
//    __b2 _Port;                  //端口号
//    __b1 _Reserved;              //保留
//    __b2 _keepAliveTime;         //上线间隔时间
//}HANDSHAKE_HEADER_PACKET;




//handshake回包
//typedef struct HANDSHAKE_RETRUN_PACKET{
//    
//    __b1 Version;//协议版本
//
//    __b1 MacAddress[6];         //Mac地址
////    __b2 DeviceIDLength;        //deviceid 长度
////    __b1 DeviceIDStr[32];       //deviceid 字符串
//    __b4 DeviceID;
//    
//    __b2 MCU_SOFT_Version;      //MCU软件版本
//    __b2 SessionID;             //session对话ID
//    __b1 HandshakeKey;          //握手参数
//
//    
//}HANDSHAKE_RETRUN_PACKET;





/*******************
 3 app通知设备app下线，设备清理改app的相关资源
 */

//typedef struct BYEBYE_PACKET{
//    __b2 SessionID;            //对话ID
//}BYEBYE_PACKET;



/*******************
 5 ping  app不跟踪Ping包，只需要在收到Ping包后，通过Mac地址找到设备节点，延长其生命周期  app收到ping包也是做延长生命周期的工作，当 app或者Device在（keepAliceTime*1.5) 的时间周期内，没有收到对方的Ping则认为设备下线
 */

//协议头
//typedef struct PING_HEADER_PACKET{
//    __b2 SessionID;             //对话ID
//}PING_HEADER_PACKET;



//没有协议载荷数据

//ping返回包
//typedef struct PING_RETRUN_PACKET{
//    __b1 MacAddress[6];         //Mac地址
//}PING_RETRUN_PACKET;

/*******************
 6 由app主动发送，Wi-Fi处理并应答，应答的数据包，只是表示Wi-Fi模块收到set消息，Wi-Fi修改之后的状态由sync包发送给app
 */
//set协议头
//typedef struct SET_HEADER_PACKET{
//    __b2 SessionID;
//    __b2 MessageID;
//    __b1 SetFlag;
//
//}SET_HEADER_PACKET;

//set协议有效载荷
//typedef struct SET_PAYLOAD_PACKET{
//    ///
//    
//}SET_PAYLOAD_PACKET;

//set应答
//typedef struct SET_RESPONSE_PACKET{
//    __b2 MessageID;         //消息ID
//    __b1 SetState;          //设置执行状态
//    
//}SET_RESPONSE_PACKET;

/*******************
 7，设备属性状态发生变化需要通知关注的app，非广播
 */

//协议头
typedef struct SYNC_PACKET_HEADER{
    __b1 MacAddress[6];         //Mac地址
    __b1 SyncFlag;              //同步标示
}SYNC_PACKET_HEADER;

//协议的有效载荷数据实体
typedef struct SYNC_PACKET_PAYLOAD{
    __b1 DataPointFlag;      //dataPoint标示
    
    //data value
    
}SYNC_PACKET_PAYLOAD;

//无应答


/*******************
 8.1 app主动获取Device的整体状态，无数据实体，app会收到SYNC同步包
 */

//协议头
typedef struct PROBE_PACKET_HEADER{
    __b2 SessionID;         //对话sessionID
    __b1 ProbeFlag;         //探测标示
    
}PROBE_PACKET_HEADER;

//无协议有效载荷

//返回SYNC同步包


/*******************
 9.1 设备上线后发出的广播包，通知关注的App发送handshake,app的监听端口为35223
 */


//协议头
typedef struct DEVONLINE_PACKET_HEADER{
    __b1 Version;           //协议版本号
    __b2 Port;              //端口号

}DEVONLINE_PACKET_HEADER;
#pragma pack()
//协议的有效载荷数据实体，Device SN的字符串，从app中获得

#endif
