//
//  readline.h
//  Timmy Fell Down The Well
//
//  Created by Wil Gieseler on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Timmy_Fell_Down_The_Well_readline_h
#define Timmy_Fell_Down_The_Well_readline_h

#include <stdio.h>   /* Standard input/output definitions */
#include <string.h>  /* String function definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */
#include <termios.h> /* POSIX terminal control definitions */

int USBSerialInit();
void USBSerialGetLine(int fd, char *buffer, int bufsize);

#endif
