//
//  IPAddress.h
//  xlinksdklib
//
//  Created by Leon on 15/8/25.
//  Copyright (c) 2015年 xtmac02. All rights reserved.
//

#ifndef xlinksdklib_IPAddress_h
#define xlinksdklib_IPAddress_h

#define MAXADDRS 32

extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];

// Function prototypes

void InitAddresses();
void FreeAddresses();
int GetIPAddresses();
void GetHWAddresses();

const char * GetIPAddress(int index);
const char * GetHWAddress(int index);

#endif
