/* $Id: xiic_l.h,v 1.2 2007/05/31 00:29:41 wre Exp $ */
/*****************************************************************************
*
*       XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
*       AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND
*       SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,
*       OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
*       APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION
*       THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
*       AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
*       FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
*       WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
*       IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
*       REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
*       INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*       FOR A PARTICULAR PURPOSE.
*
*       (c) Copyright 2002-2006 Xilinx Inc.
*       All rights reserved.
*
*****************************************************************************/
/****************************************************************************/
/**
*
* @file xiic_l.h
*
* This header file contains identifiers and low-level driver functions (or
* macros) that can be used to access the device in normal and dynamic
* controller mode.  High-level driver functions are defined in xiic.h.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00b jhl  05/07/02 First release
* 1.01c ecm  12/05/02 new rev
* 1.01d jhl  10/08/03 Added general purpose output feature
* 1.02a mta	 03/09/06 Implemented Repeated Start in the Low Level Driver.
* 1.03a mta  04/04/06 Implemented Dynamic IIC core routines.
* 1.03a rpm  09/08/06 Added include of xstatus.h for completeness
* 1.13a wgr  03/22/07 Converted to new coding style.
* </pre>
*
*****************************************************************************/

#ifndef XIIC_L_H		/* prevent circular inclusions */
#define XIIC_L_H		/* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files ********************************/

#include "xbasic_types.h"
#include "xstatus.h"

/************************** Constant Definitions ****************************/

#define XIIC_MSB_OFFSET                3

#define XIIC_REG_OFFSET 0x100 + XIIC_MSB_OFFSET

/*
 * Register offsets in bytes from RegisterBase. Three is added to the
 * base offset to access LSB (IBM style) of the word
 */
#define XIIC_CR_REG_OFFSET   0x00+XIIC_REG_OFFSET	/* Control Register   */
#define XIIC_SR_REG_OFFSET   0x04+XIIC_REG_OFFSET	/* Status Register    */
#define XIIC_DTR_REG_OFFSET  0x08+XIIC_REG_OFFSET	/* Data Tx Register   */
#define XIIC_DRR_REG_OFFSET  0x0C+XIIC_REG_OFFSET	/* Data Rx Register   */
#define XIIC_ADR_REG_OFFSET  0x10+XIIC_REG_OFFSET	/* Address Register   */
#define XIIC_TFO_REG_OFFSET  0x14+XIIC_REG_OFFSET	/* Tx FIFO Occupancy  */
#define XIIC_RFO_REG_OFFSET  0x18+XIIC_REG_OFFSET	/* Rx FIFO Occupancy  */
#define XIIC_TBA_REG_OFFSET  0x1C+XIIC_REG_OFFSET	/* 10 Bit Address reg */
#define XIIC_RFD_REG_OFFSET  0x20+XIIC_REG_OFFSET	/* Rx FIFO Depth reg  */
#define XIIC_GPO_REG_OFFSET  0x24+XIIC_REG_OFFSET	/* Output Register    */

/* Control Register masks */

#define XIIC_CR_ENABLE_DEVICE_MASK        0x01	/* Device enable = 1      */
#define XIIC_CR_TX_FIFO_RESET_MASK        0x02	/* Transmit FIFO reset=1  */
#define XIIC_CR_MSMS_MASK                 0x04	/* Master starts Txing=1  */
#define XIIC_CR_DIR_IS_TX_MASK            0x08	/* Dir of tx. Txing=1     */
#define XIIC_CR_NO_ACK_MASK               0x10	/* Tx Ack. NO ack = 1     */
#define XIIC_CR_REPEATED_START_MASK       0x20	/* Repeated start = 1     */
#define XIIC_CR_GENERAL_CALL_MASK         0x40	/* Gen Call enabled = 1   */

/* Status Register masks */

#define XIIC_SR_GEN_CALL_MASK             0x01	/* 1=a mstr issued a GC   */
#define XIIC_SR_ADDR_AS_SLAVE_MASK        0x02	/* 1=when addr as slave   */
#define XIIC_SR_BUS_BUSY_MASK             0x04	/* 1 = bus is busy        */
#define XIIC_SR_MSTR_RDING_SLAVE_MASK     0x08	/* 1=Dir: mstr <-- slave  */
#define XIIC_SR_TX_FIFO_FULL_MASK         0x10	/* 1 = Tx FIFO full       */
#define XIIC_SR_RX_FIFO_FULL_MASK         0x20	/* 1 = Rx FIFO full       */
#define XIIC_SR_RX_FIFO_EMPTY_MASK        0x40	/* 1 = Rx FIFO empty      */
#define XIIC_SR_TX_FIFO_EMPTY_MASK        0x80	/* 1 = Tx FIFO empty      */

/* IPIF Interrupt Status Register masks    Interrupt occurs when...       */

#define XIIC_INTR_ARB_LOST_MASK           0x01	/* 1 = arbitration lost   */
#define XIIC_INTR_TX_ERROR_MASK           0x02	/* 1=Tx error/msg complete */
#define XIIC_INTR_TX_EMPTY_MASK           0x04	/* 1 = Tx FIFO/reg empty  */
#define XIIC_INTR_RX_FULL_MASK            0x08	/* 1=Rx FIFO/reg=OCY level */
#define XIIC_INTR_BNB_MASK                0x10	/* 1 = Bus not busy       */
#define XIIC_INTR_AAS_MASK                0x20	/* 1 = when addr as slave */
#define XIIC_INTR_NAAS_MASK               0x40	/* 1 = not addr as slave  */
#define XIIC_INTR_TX_HALF_MASK            0x80	/* 1 = TX FIFO half empty */

/* IPIF Device Interrupt Register masks */

#define XIIC_IPIF_IIC_MASK          0x00000004UL	/* 1=inter enabled */
#define XIIC_IPIF_ERROR_MASK        0x00000001UL	/* 1=inter enabled */
#define XIIC_IPIF_INTER_ENABLE_MASK  (XIIC_IPIF_IIC_MASK |  \
                                      XIIC_IPIF_ERROR_MASK)

#define XIIC_TX_ADDR_SENT             0x00
#define XIIC_TX_ADDR_MSTR_RECV_MASK   0x02

/* The following constants specify the depth of the FIFOs */

#define IIC_RX_FIFO_DEPTH         16	/* Rx fifo capacity               */
#define IIC_TX_FIFO_DEPTH         16	/* Tx fifo capacity               */

/* The following constants specify groups of interrupts that are typically
 * enabled or disables at the same time
 */
#define XIIC_TX_INTERRUPTS                                          \
            (XIIC_INTR_TX_ERROR_MASK | XIIC_INTR_TX_EMPTY_MASK |    \
             XIIC_INTR_TX_HALF_MASK)

#define XIIC_TX_RX_INTERRUPTS (XIIC_INTR_RX_FULL_MASK | XIIC_TX_INTERRUPTS)

/* The following constants are used with the following macros to specify the
 * operation, a read or write operation.
 */
#define XIIC_READ_OPERATION  1
#define XIIC_WRITE_OPERATION 0

/* The following constants are used with the transmit FIFO fill function to
 * specify the role which the IIC device is acting as, a master or a slave.
 */
#define XIIC_MASTER_ROLE     1
#define XIIC_SLAVE_ROLE      0

/*
 * The following constants are used with Transmit Function (XIic_Send) to
 * specify whether to STOP after the current transfer of data or own the bus
 * with a Repeated start.
 */
#define XIIC_STOP				0x00
#define XIIC_REPEATED_START	0x01

 /*
  * Tx Fifo upper bit masks.
  */

#define XIIC_TX_DYN_START_MASK            0x0100	/* 1 = Set dynamic start
*/
#define XIIC_TX_DYN_STOP_MASK             0x0200	/* 1 = Set dynamic stop
*/


/**************************** Type Definitions ******************************/


/***************** Macros (Inline Functions) Definitions ********************/

/************************** Constant Definitions *****************************/

/* the following constants define the register offsets for the registers of the
 * IPIF, there are some holes in the memory map for reserved addresses to allow
 * other registers to be added and still match the memory map of the interrupt
 * controller registers
 */
#define XIIC_DISR_OFFSET     0UL  /* device interrupt status register */
#define XIIC_DIPR_OFFSET     4UL  /* device interrupt pending register */
#define XIIC_DIER_OFFSET     8UL  /* device interrupt enable register */
#define XIIC_DIIR_OFFSET     24UL /* device interrupt ID register */
#define XIIC_DGIER_OFFSET    28UL /* device global interrupt enable reg */
#define XIIC_IISR_OFFSET     32UL /* IP interrupt status register */
#define XIIC_IIER_OFFSET     40UL /* IP interrupt enable register */
#define XIIC_RESETR_OFFSET   64UL /* reset register */


#define XIIC_RESET_MASK             0xAUL

/* the following constant is used for the device global interrupt enable
 * register, to enable all interrupts for the device, this is the only bit
 * in the register
 */
#define XIIC_GINTR_ENABLE_MASK      0x80000000UL

/* the following constants contain the masks to identify each internal IPIF
 * condition in the device registers of the IPIF, interrupts are assigned
 * in the register from LSB to the MSB
 */
#define XIIC_ERROR_MASK             1UL     /* LSB of the register */

/* The following constants contain interrupt IDs which identify each internal
 * IPIF condition, this value must correlate with the mask constant for the
 * error
 */
#define XIIC_ERROR_INTERRUPT_ID     0    /* interrupt bit #, (LSB = 0) */
#define XIIC_NO_INTERRUPT_ID        128  /* no interrupts are pending */

/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/******************************************************************************
*
* MACRO:
*
* XIIC_RESET
*
* DESCRIPTION:
*
* Reset the IPIF component and hardware.  This is a destructive operation that
* could cause the loss of data since resetting the IPIF of a device also
* resets the device using the IPIF and any blocks, such as FIFOs or DMA
* channels, within the IPIF.  All registers of the IPIF will contain their
* reset value when this function returns.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* RETURN VALUE:
*
* None.
*
* NOTES:
*
* None.
*
******************************************************************************/

/* the following constant is used in the reset register to cause the IPIF to
 * reset
 */
#define XIIC_RESET(RegBaseAddress) \
    XIo_Out32(RegBaseAddress + XIIC_RESETR_OFFSET, XIIC_RESET_MASK)

/******************************************************************************
*
* MACRO:
*
* XIIC_WRITE_DISR
*
* DESCRIPTION:
*
* This function sets the device interrupt status register to the value.
* This register indicates the status of interrupt sources for a device
* which contains the IPIF.  The status is independent of whether interrupts
* are enabled and could be used for polling a device at a higher level rather
* than a more detailed level.
*
* Each bit of the register correlates to a specific interrupt source within the
* device which contains the IPIF.  With the exception of some internal IPIF
* conditions, the contents of this register are not latched but indicate
* the live status of the interrupt sources within the device.  Writing any of
* the non-latched bits of the register will have no effect on the register.
*
* For the latched bits of this register only, setting a bit which is zero
* within this register causes an interrupt to generated.  The device global
* interrupt enable register and the device interrupt enable register must be set
* appropriately to allow an interrupt to be passed out of the device. The
* interrupt is cleared by writing to this register with the bits to be
* cleared set to a one and all others to zero.  This register implements a
* toggle on write functionality meaning any bits which are set in the value
* written cause the bits in the register to change to the opposite state.
*
* This function writes the specified value to the register such that
* some bits may be set and others cleared.  It is the caller's responsibility
* to get the value of the register prior to setting the value to prevent a
* destructive behavior.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* Status contains the value to be written to the interrupt status register of
* the device.  The only bits which can be written are the latched bits which
* contain the internal IPIF conditions.  The following values may be used to
* set the status register or clear an interrupt condition.
*
*   XIIC_ERROR_MASK     Indicates a device error in the IPIF
*
* RETURN VALUE:
*
* None.
*
* NOTES:
*
* None.
*
******************************************************************************/
#define XIIC_WRITE_DISR(RegBaseAddress, Status) \
    XIo_Out32((RegBaseAddress) + XIIC_DISR_OFFSET, (Status))

/******************************************************************************
*
* MACRO:
*
* XIIC_READ_DISR
*
* DESCRIPTION:
*
* This function gets the device interrupt status register contents.
* This register indicates the status of interrupt sources for a device
* which contains the IPIF.  The status is independent of whether interrupts
* are enabled and could be used for polling a device at a higher level.
*
* Each bit of the register correlates to a specific interrupt source within the
* device which contains the IPIF.  With the exception of some internal IPIF
* conditions, the contents of this register are not latched but indicate
* the live status of the interrupt sources within the device.
*
* For only the latched bits of this register, the interrupt may be cleared by
* writing to these bits in the status register.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* RETURN VALUE:
*
* A status which contains the value read from the interrupt status register of
* the device. The bit definitions are specific to the device with
* the exception of the latched internal IPIF condition bits. The following
* values may be used to detect internal IPIF conditions in the status.
*
*   XIIC_ERROR_MASK     Indicates a device error in the IPIF
*
* NOTES:
*
* None.
*
******************************************************************************/
#define XIIC_READ_DISR(RegBaseAddress) \
    XIo_In32((RegBaseAddress) + XIIC_DISR_OFFSET)

/******************************************************************************
*
* MACRO:
*
* XIIC_WRITE_DIER
*
* DESCRIPTION:
*
* This function sets the device interrupt enable register contents.
* This register controls which interrupt sources of the device are allowed to
* generate an interrupt.  The device global interrupt enable register must also
* be set appropriately for an interrupt to be passed out of the device.
*
* Each bit of the register correlates to a specific interrupt source within the
* device which contains the IPIF.  Setting a bit in this register enables that
* interrupt source to generate an interrupt.  Clearing a bit in this register
* disables interrupt generation for that interrupt source.
*
* This function writes only the specified value to the register such that
* some interrupts source may be enabled and others disabled.  It is the
* caller's responsibility to get the value of the interrupt enable register
* prior to setting the value to prevent an destructive behavior.
*
* An interrupt source may not be enabled to generate an interrupt, but can
* still be polled in the interrupt status register.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* Enable contains the value to be written to the interrupt enable register
* of the device.  The bit definitions are specific to the device with
* the exception of the internal IPIF conditions. The following
* values may be used to enable the internal IPIF conditions interrupts.
*
*   XIIC_ERROR_MASK     Indicates a device error in the IPIF
*
* RETURN VALUE:
*
* None.
*
* NOTES:
*
* Signature: u32 XIIC_WRITE_DIER(u32 RegBaseAddress,
*                                         u32 Enable)
*
******************************************************************************/
#define XIIC_WRITE_DIER(RegBaseAddress, Enable) \
    XIo_Out32((RegBaseAddress) + XIIC_DIER_OFFSET, (Enable))

/******************************************************************************
*
* MACRO:
*
* XIIC_READ_DIER
*
* DESCRIPTION:
*
* This function gets the device interrupt enable register contents.
* This register controls which interrupt sources of the device
* are allowed to generate an interrupt.  The device global interrupt enable
* register and the device interrupt enable register must also be set
* appropriately for an interrupt to be passed out of the device.
*
* Each bit of the register correlates to a specific interrupt source within the
* device which contains the IPIF.  Setting a bit in this register enables that
* interrupt source to generate an interrupt if the global enable is set
* appropriately.  Clearing a bit in this register disables interrupt generation
* for that interrupt source regardless of the global interrupt enable.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* RETURN VALUE:
*
* The value read from the interrupt enable register of the device.  The bit
* definitions are specific to the device with the exception of the internal
* IPIF conditions. The following values may be used to determine from the
* value if the internal IPIF conditions interrupts are enabled.
*
*   XIIC_ERROR_MASK     Indicates a device error in the IPIF
*
* NOTES:
*
* None.
*
******************************************************************************/
#define XIIC_READ_DIER(RegBaseAddress) \
    XIo_In32((RegBaseAddress) + XIIC_DIER_OFFSET)

/******************************************************************************
*
* MACRO:
*
* XIIC_READ_DIPR
*
* DESCRIPTION:
*
* This function gets the device interrupt pending register contents.
* This register indicates the pending interrupt sources, those that are waiting
* to be serviced by the software, for a device which contains the IPIF.
* An interrupt must be enabled in the interrupt enable register of the IPIF to
* be pending.
*
* Each bit of the register correlates to a specific interrupt source within the
* the device which contains the IPIF.  With the exception of some internal IPIF
* conditions, the contents of this register are not latched since the condition
* is latched in the IP interrupt status register, by an internal block of the
* IPIF such as a FIFO or DMA channel, or by the IP of the device.  This register
* is read only and is not latched, but it is necessary to acknowledge (clear)
* the interrupt condition by performing the appropriate processing for the IP
* or block within the IPIF.
*
* This register can be thought of as the contents of the interrupt status
* register ANDed with the contents of the interrupt enable register.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* RETURN VALUE:
*
* The value read from the interrupt pending register of the device.  The bit
* definitions are specific to the device with the exception of the latched
* internal IPIF condition bits. The following values may be used to detect
* internal IPIF conditions in the value.
*
*   XIIC_ERROR_MASK     Indicates a device error in the IPIF
*
* NOTES:
*
* None.
*
******************************************************************************/
#define XIIC_READ_DIPR(RegBaseAddress) \
    XIo_In32((RegBaseAddress) + XIIC_DIPR_OFFSET)

/******************************************************************************
*
* MACRO:
*
* XIIC_READ_DIIR
*
* DESCRIPTION:
*
* This function gets the device interrupt ID for the highest priority interrupt
* which is pending from the interrupt ID register. This function provides
* priority resolution such that faster interrupt processing is possible.
* Without priority resolution, it is necessary for the software to read the
* interrupt pending register and then check each interrupt source to determine
* if an interrupt is pending.  Priority resolution becomes more important as the
* number of interrupt sources becomes larger.
*
* Interrupt priorities are based upon the bit position of the interrupt in the
* interrupt pending register with bit 0 being the highest priority. The
* interrupt ID is the priority of the interrupt, 0 - 31, with 0 being the
* highest priority. The interrupt ID register is live rather than latched such
* that multiple calls to this function may not yield the same results.  A
* special value, outside of the interrupt priority range of 0 - 31, is
* contained in the register which indicates that no interrupt is pending.  This
* may be useful for allowing software to continue processing interrupts in a
* loop until there are no longer any interrupts pending.
*
* The interrupt ID is designed to allow a function pointer table to be used
* in the software such that the interrupt ID is used as an index into that
* table.  The function pointer table could contain an instance pointer, such
* as to DMA channel, and a function pointer to the function which handles
* that interrupt.  This design requires the interrupt processing of the device
* driver to be partitioned into smaller more granular pieces based upon
* hardware used by the device, such as DMA channels and FIFOs.
*
* It is not mandatory that this function be used by the device driver software.
* It may choose to read the pending register and resolve the pending interrupt
* priorities on it's own.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* RETURN VALUE:
*
* An interrupt ID, 0 - 31, which identifies the highest priority interrupt
* which is pending.  A value of XIIF_NO_INTERRUPT_ID indicates that there is
* no interrupt pending. The following values may be used to identify the
* interrupt ID for the internal IPIF interrupts.
*
*   XIIC_ERROR_INTERRUPT_ID     Indicates a device error in the IPIF
*
* NOTES:
*
* None.
*
******************************************************************************/
#define XIIC_READ_DIIR(RegBaseAddress) \
    XIo_In32((RegBaseAddress) + XIIC_DIIR_OFFSET)

/******************************************************************************
*
* MACRO:
*
* XIIC_GLOBAL_INTR_DISABLE
*
* DESCRIPTION:
*
* This function disables all interrupts for the device by writing to the global
* interrupt enable register.  This register provides the ability to disable
* interrupts without any modifications to the interrupt enable register such
* that it is minimal effort to restore the interrupts to the previous enabled
* state.  The corresponding function, XIpIf_GlobalIntrEnable, is provided to
* restore the interrupts to the previous enabled state.  This function is
* designed to be used in critical sections of device drivers such that it is
* not necessary to disable other device interrupts.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* RETURN VALUE:
*
* None.
*
* NOTES:
*
* None.
*
******************************************************************************/
#define XIIC_GINTR_DISABLE(RegBaseAddress) \
    XIo_Out32((RegBaseAddress) + XIIC_DGIER_OFFSET, 0)

/******************************************************************************
*
* MACRO:
*
* XIIC_GINTR_ENABLE
*
* DESCRIPTION:
*
* This function writes to the global interrupt enable register to enable
* interrupts from the device.  This register provides the ability to enable
* interrupts without any modifications to the interrupt enable register such
* that it is minimal effort to restore the interrupts to the previous enabled
* state.  This function does not enable individual interrupts as the interrupt
* enable register must be set appropriately.  This function is designed to be
* used in critical sections of device drivers such that it is not necessary to
* disable other device interrupts.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* RETURN VALUE:
*
* None.
*
* NOTES:
*
* None.
*
******************************************************************************/
#define XIIC_GINTR_ENABLE(RegBaseAddress)           \
    XIo_Out32((RegBaseAddress) + XIIC_DGIER_OFFSET, \
               XIIC_GINTR_ENABLE_MASK)

/******************************************************************************
*
* MACRO:
*
* XIIC_IS_GINTR_ENABLED
*
* DESCRIPTION:
*
* This function determines if interrupts are enabled at the global level by
* reading the gloabl interrupt register. This register provides the ability to
* disable interrupts without any modifications to the interrupt enable register
* such that it is minimal effort to restore the interrupts to the previous
* enabled state.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* RETURN VALUE:
*
* XTRUE if interrupts are enabled for the IPIF, XFALSE otherwise.
*
* NOTES:
*
* None.
*
******************************************************************************/
#define XIIC_IS_GINTR_ENABLED(RegBaseAddress)             \
    (XIo_In32((RegBaseAddress) + XIIC_DGIER_OFFSET) ==    \
              XIIC_GINTR_ENABLE_MASK)

/******************************************************************************
*
* MACRO:
*
* XIIC_WRITE_IISR
*
* DESCRIPTION:
*
* This function sets the IP interrupt status register to the specified value.
* This register indicates the status of interrupt sources for the IP of the
* device.  The IP is defined as the part of the device that connects to the
* IPIF.  The status is independent of whether interrupts are enabled such that
* the status register may also be polled when interrupts are not enabled.
*
* Each bit of the register correlates to a specific interrupt source within the
* IP.  All bits of this register are latched. Setting a bit which is zero
* within this register causes an interrupt to be generated.  The device global
* interrupt enable register and the device interrupt enable register must be set
* appropriately to allow an interrupt to be passed out of the device. The
* interrupt is cleared by writing to this register with the bits to be
* cleared set to a one and all others to zero.  This register implements a
* toggle on write functionality meaning any bits which are set in the value
* written cause the bits in the register to change to the opposite state.
*
* This function writes only the specified value to the register such that
* some status bits may be set and others cleared.  It is the caller's
* responsibility to get the value of the register prior to setting the value
* to prevent an destructive behavior.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* Status contains the value to be written to the IP interrupt status
* register.  The bit definitions are specific to the device IP.
*
* RETURN VALUE:
*
* None.
*
* NOTES:
*
* None.
*
******************************************************************************/
#define XIIC_WRITE_IISR(RegBaseAddress, Status) \
    XIo_Out32((RegBaseAddress) + XIIC_IISR_OFFSET, (Status))

/******************************************************************************
*
* MACRO:
*
* XIIC_READ_IISR
*
* DESCRIPTION:
*
* This function gets the contents of the IP interrupt status register.
* This register indicates the status of interrupt sources for the IP of the
* device.  The IP is defined as the part of the device that connects to the
* IPIF. The status is independent of whether interrupts are enabled such
* that the status register may also be polled when interrupts are not enabled.
*
* Each bit of the register correlates to a specific interrupt source within the
* device.  All bits of this register are latched.  Writing a 1 to a bit within
* this register causes an interrupt to be generated if enabled in the interrupt
* enable register and the global interrupt enable is set.  Since the status is
* latched, each status bit must be acknowledged in order for the bit in the
* status register to be updated.  Each bit can be acknowledged by writing a
* 0 to the bit in the status register.

* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* RETURN VALUE:
*
* A status which contains the value read from the IP interrupt status register.
* The bit definitions are specific to the device IP.
*
* NOTES:
*
* None.
*
******************************************************************************/
#define XIIC_READ_IISR(RegBaseAddress) \
    XIo_In32((RegBaseAddress) + XIIC_IISR_OFFSET)

/******************************************************************************
*
* MACRO:
*
* XIIC_WRITE_IIER
*
* DESCRIPTION:
*
* This function sets the IP interrupt enable register contents.  This register
* controls which interrupt sources of the IP are allowed to generate an
* interrupt.  The global interrupt enable register and the device interrupt
* enable register must also be set appropriately for an interrupt to be
* passed out of the device containing the IPIF and the IP.
*
* Each bit of the register correlates to a specific interrupt source within the
* IP.  Setting a bit in this register enables the interrupt source to generate
* an interrupt.  Clearing a bit in this register disables interrupt generation
* for that interrupt source.
*
* This function writes only the specified value to the register such that
* some interrupt sources may be enabled and others disabled.  It is the
* caller's responsibility to get the value of the interrupt enable register
* prior to setting the value to prevent an destructive behavior.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* Enable contains the value to be written to the IP interrupt enable register.
* The bit definitions are specific to the device IP.
*
* RETURN VALUE:
*
* None.
*
* NOTES:
*
* None.
*
******************************************************************************/
#define XIIC_WRITE_IIER(RegBaseAddress, Enable) \
    XIo_Out32((RegBaseAddress) + XIIC_IIER_OFFSET, (Enable))

/******************************************************************************
*
* MACRO:
*
* XIIC_READ_IIER
*
* DESCRIPTION:
*
*
* This function gets the IP interrupt enable register contents.  This register
* controls which interrupt sources of the IP are allowed to generate an
* interrupt.  The global interrupt enable register and the device interrupt
* enable register must also be set appropriately for an interrupt to be
* passed out of the device containing the IPIF and the IP.
*
* Each bit of the register correlates to a specific interrupt source within the
* IP.  Setting a bit in this register enables the interrupt source to generate
* an interrupt.  Clearing a bit in this register disables interrupt generation
* for that interrupt source.
*
* ARGUMENTS:
*
* RegBaseAddress contains the base address of the IPIF registers.
*
* RETURN VALUE:
*
* The contents read from the IP interrupt enable register.  The bit definitions
* are specific to the device IP.
*
* NOTES:
*
* Signature: u32 XIIC_READ_IIER(u32 RegBaseAddress)
*
******************************************************************************/
#define XIIC_READ_IIER(RegBaseAddress) \
    XIo_In32((RegBaseAddress) + XIIC_IIER_OFFSET)

/************************** Function Prototypes ******************************/

/*
 * Initialization Functions
 */
int XIpIfV123b_SelfTest(u32 RegBaseAddress, u8 IpRegistersWidth);


/******************************************************************************
*
* This macro reads a register in the IIC device using an 8 bit read operation.
* This macro does not do any checking to ensure that the register exists if the
* register may be excluded due to parameterization, such as the GPO Register.
*
* @param    BaseAddress of the IIC device.
*
* @param    RegisterOffset contains the offset of the register from the device
*           base address.
*
* @return
*
* The value read from the register.
*
* @note
*
* Signature: u8 XIic_mReadReg(u32 BaseAddress, int RegisterOffset);
*
******************************************************************************/
#define XIic_mReadReg(BaseAddress, RegisterOffset) \
   XIo_In8((BaseAddress) + (RegisterOffset))

/******************************************************************************
*
* This macro writes a register in the IIC device using an 8 bit write
* operation. This macro does not do any checking to ensure that the register
* exists if the register may be excluded due to parameterization, such as the
* GPO Register.
*
* @param    BaseAddress of the IIC device.
*
* @param    RegisterOffset contains the offset of the register from the device
*           base address.
*
* @param    Data contains the data to be written to the register.
*
* @return   None.
*
* @note
*
* Signature: void XIic_mWriteReg(u32 BaseAddress,
*                                int RegisterOffset, u8 Data);
*
******************************************************************************/
#define XIic_mWriteReg(BaseAddress, RegisterOffset, Data) \
   XIo_Out8((BaseAddress) + (RegisterOffset), (Data))

/******************************************************************************
*
* This macro clears the specified interrupt in the IPIF interrupt status
* register.  It is non-destructive in that the register is read and only the
* interrupt specified is cleared.  Clearing an interrupt acknowledges it.
*
* @param    BaseAddress contains the IPIF registers base address.
*
* @param    InterruptMask contains the interrupts to be disabled
*
* @return
*
* None.
*
* @note
*
* Signature: void XIic_mClearIisr(u32 BaseAddress,
*                                 u32 InterruptMask);
*
******************************************************************************/
#define XIic_mClearIisr(BaseAddress, InterruptMask)                 \
    XIIC_WRITE_IISR((BaseAddress),                            \
        XIIC_READ_IISR(BaseAddress) & (InterruptMask))

/******************************************************************************
*
* This macro sends the address for a 7 bit address during both read and write
* operations. It takes care of the details to format the address correctly.
* This macro is designed to be called internally to the drivers.
*
* @param    SlaveAddress contains the address of the slave to send to.
*
* @param    Operation indicates XIIC_READ_OPERATION or XIIC_WRITE_OPERATION
*
* @return
*
* None.
*
* @note
*
* Signature: void XIic_mSend7BitAddr(u16 SlaveAddress, u8 Operation);
*
******************************************************************************/
#define XIic_mSend7BitAddress(BaseAddress, SlaveAddress, Operation)         \
{                                                                           \
    u8 LocalAddr = (u8)(SlaveAddress << 1);                         \
    LocalAddr = (LocalAddr & 0xFE) | (Operation);                           \
    XIo_Out8(BaseAddress + XIIC_DTR_REG_OFFSET, LocalAddr);                 \
}

/******************************************************************************
*
* This macro sends the address for a 7 bit address during both read and write
* operations. It takes care of the details to format the address correctly.
* This macro is designed to be called internally to the drivers.
*
* @param    BaseAddress contains the base address of the IIC Device.
* @param    SlaveAddress contains the address of the slave to send to.
* @param    Operation indicates XIIC_READ_OPERATION or XIIC_WRITE_OPERATION.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
#define XIic_mDynSend7BitAddress(BaseAddress, SlaveAddress, Operation)       \
{                                                                            \
    u8 LocalAddr = (u8)(SlaveAddress << 1);                          \
    LocalAddr = (LocalAddr & 0xFE) | (Operation);                            \
    XIo_Out16(BaseAddress + XIIC_DTR_REG_OFFSET - 1,                         \
              XIIC_TX_DYN_START_MASK | LocalAddr);                           \
}

/******************************************************************************
*
* This macro sends the address, start and stop for a 7 bit address during both
* write operations. It takes care of the details to format the address
* correctly.
* This macro is designed to be called internally to the drivers.
*
* @param    BaseAddress contains the base address of the IIC Device.
* @param    SlaveAddress contains the address of the slave to send to.
* @param    Operation indicates XIIC_WRITE_OPERATION.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
#define XIic_mDynSendStartStopAddress(BaseAddress, SlaveAddress, Operation)  \
{                                                                            \
    Xuint8 LocalAddr = (Xuint8)(SlaveAddress << 1);                          \
    LocalAddr = (LocalAddr & 0xFE) | (Operation);                            \
    XIo_Out16(BaseAddress + XIIC_DTR_REG_OFFSET - 1,                         \
              XIIC_TX_DYN_START_MASK | XIIC_TX_DYN_STOP_MASK | LocalAddr);   \
}

/******************************************************************************
* This macro sends a stop condition on IIC bus for Dynamic logic.
*
* @param    BaseAddress contains the base address of the IIC Device.
* @param    ByteCount is the number of Rx bytes received before the master.
*			doesn't respond with ACK.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
#define XIic_mDynSendStop(BaseAddress, ByteCount)                           \
{                                                                           \
    XIo_Out16(BaseAddress + XIIC_DTR_REG_OFFSET-1, XIIC_TX_DYN_STOP_MASK |  \
    		  ByteCount); \
}

/************************** Function Prototypes *****************************/

unsigned XIic_Recv(u32 BaseAddress, u8 Address,
		   u8 *BufferPtr, unsigned ByteCount, u8 Option);

unsigned XIic_Send(u32 BaseAddress, u8 Address,
		   u8 *BufferPtr, unsigned ByteCount, u8 Option);

unsigned XIic_DynRecv(u32 BaseAddress, u8 Address, u8 *BufferPtr, u8 ByteCount);

unsigned XIic_DynSend(u32 BaseAddress, u16 Address, u8 *BufferPtr,
		      u8 ByteCount, u8 Option);

int XIic_DynInit(u32 BaseAddress);


#ifdef __cplusplus
}
#endif

#endif /* end of protection macro */

