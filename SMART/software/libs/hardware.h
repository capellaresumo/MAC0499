//----------------------------------------------------------------------------
// MIT License
// 
// Copyright (c) 2018 Gabriel Capella
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//----------------------------------------------------------------------------
//
// This source code is part of my final undergraduate thesis.
// For any suggestion, doubt or comment send an email to
// gabriel@capella.pro
//
//----------------------------------------------------------------------------
//
// *File Name: smart_mac.v
//
// *Module Description: SMART Memory Access Control
//
//----------------------------------------------------------------------------
#ifndef HARDWARE_H
#define HARDWARE_H

//--------------------------------------------------
// Hardware UART register address mapping
//--------------------------------------------------

#define UART_CTL          (*(volatile unsigned char *) 0x0080)  // UART Control register (8bit)
#define UART_STAT         (*(volatile unsigned char *) 0x0081)  // UART Status register (8bit)
#define UART_BAUD         (*(volatile unsigned int  *) 0x0082)  // UART Baud rate configuration (16bit)
#define UART_TXD          (*(volatile unsigned char *) 0x0084)  // UART Transmit data register (8bit)
#define UART_RXD          (*(volatile unsigned char *) 0x0085)  // UART Receive data register (8bit)

#define UART2_CTL         (*(volatile unsigned char *) 0x0090)  // UART2 Control register (8bit)
#define UART2_STAT        (*(volatile unsigned char *) 0x0091)  // UART2 Status register (8bit)
#define UART2_BAUD        (*(volatile unsigned int  *) 0x0092)  // UART2 Baud rate configuration (16bit)
#define UART2_TXD         (*(volatile unsigned char *) 0x0094)  // UART2 Transmit data register (8bit)
#define UART2_RXD         (*(volatile unsigned char *) 0x0095)  // UART2 Receive data register (8bit)

//--------------------------------------------------
// Hardware UART register field mapping
//--------------------------------------------------

// UART Control register fields
#define  UART_IEN_TX_EMPTY  0x80
#define  UART_IEN_TX        0x40
#define  UART_IEN_RX_OVFLW  0x20
#define  UART_IEN_RX        0x10
#define  UART_SMCLK_SEL     0x02
#define  UART_EN            0x01

// UART Status register fields
#define  UART_TX_EMPTY_PND  0x80
#define  UART_TX_PND        0x40
#define  UART_RX_OVFLW_PND  0x20
#define  UART_RX_PND        0x10
#define  UART_TX_FULL       0x08
#define  UART_TX_BUSY       0x04
#define  UART_RX_BUSY       0x01

//--------------------------------------------------
// Hardware SHA256 register field mapping
//--------------------------------------------------

#define SHA_CONFIG      (*(volatile unsigned char *) 0x001F)
#define SHA_STATUS      (*(volatile unsigned char *) 0x001F)
#define SHA_INPUT       (*(volatile unsigned long *) 0x0020)
#define SHA_OUTPUT      (*(volatile unsigned long *) 0x0060)

// SHA Control register fields
#define  SHA_MODE           0x08 // set to 1 for sha256
#define  SHA_INIT           0x02
#define  SHA_ON             0x01
#define  SHA_NEXT           0x04

// SHA Status register fields
#define  SHA_READY          0x1
#define  SHA_DIGEST_VALID   0x2

//--------------------------------------------------
// Diverse
//--------------------------------------------------

// BAUD = (mclk_freq/baudrate)-1

//#define BAUD          2083                //   9600  @20.0MHz
#define BAUD            1041                //  19200  @20.0MHz
//#define BAUD          521                 //  38400  @20.0MHz
//#define BAUD          347                 //  57600  @20.0MHz
// #define BAUD         170                 // 115200  @20.0MHz
//#define BAUD          87                  // 230400  @20.0MHz

#endif //HARDWARE_H
