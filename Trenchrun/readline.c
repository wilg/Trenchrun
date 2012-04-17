#include "readline.h"

/* change this to your USB port Device Name*/
#define PORT "/dev/tty.usbserial-A800H22L"  

//void USBSerialGetline(char *buffer, int bufsize);
//int  USBSerialInit();


/*
 ** this is just a sample c Main program.
 ** It reads lines and prints them
 */
// int main(int argc, char *argv[])
// {
//     int fd;
//     char buffer[256];
//     
//     fd = USBSerialInit();
//     /* loop reading lines from the USB Serial Port */  
//     while (1)
//     {
//         USBSerialGetLine(fd,buffer,sizeof buffer);
//         /*
//          ** here's where to process the line that was read
//          ** As an example, this code is just printing it out
//          */
//         printf("%s\n",buffer);
//     }
// }  

int USBSerialInit()
{
    int fd;
//    int i, j;
    struct termios options;
    
    /* open the USB Serial Port */
    fd = open(PORT, O_RDWR | O_NOCTTY | O_NDELAY);
    if (fd == -1)
    {
        perror("open_port: Unable to open serial port - ");
        return -1;
    }
    else fcntl(fd, F_SETFL, 0);
    /* set the port to 9600 Baud, 8 data bits, etc. */
    tcgetattr(fd, &options);
    cfsetispeed(&options, B115200);
    cfsetospeed(&options, B115200);
    options.c_cflag |= (CLOCAL | CREAD);
    options.c_cflag &= ~CSIZE; /* Mask the character size bits */
    options.c_cflag |= CS8;    /* Select 8 data bits */
    options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
    tcsetattr(fd, TCSANOW, &options);
    return fd;
}

/*
 ** this reads an entire line of text, up to a Newline
 ** and discards any Carriage Returns
 ** The resulting line has the Newline stripped and
 ** is null-terminated
 */
void USBSerialGetLine(int fd,char *buffer,int bufsize)
{
    char *bufptr;
    int nbytes;
    char inchar;
    
    bufptr = buffer;
    while ((nbytes = read(fd, &inchar, 1)) > 0)
    {
        if (inchar == '\r') continue;
        if (inchar == '\n') break;
        *bufptr = inchar;
        ++bufptr;
    }
    *bufptr = '\0';
}

