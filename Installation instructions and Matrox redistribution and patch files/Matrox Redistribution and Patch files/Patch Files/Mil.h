
/************************************************************************/
/*
*
* Filename     :  MIL.H
* Owner        :  Matrox Imaging dept.
* Rev          :  $Revision:   6.2  $
* Content      :  This file contains the defines necessary to use the
*                 Matrox Imaging Library "C" user interface.
*
* Comments     :  Some defines may be here but not yet
*                 implemented in the library.
*
* COPYRIGHT (c) Matrox Electronic Systems Ltd.
* All Rights Reserved
*************************************************************************/

#ifndef __MIL_H
#define __MIL_H

#ifndef M_MIL_BW_COMPAT
#define M_MIL_BW_COMPAT
#endif

/************************************************************************/
/* DEFAULT SETUP FLAG */
/************************************************************************/

/* include set-up instructions (if not specified) */
#ifndef M_MIL_USE_SETUP
#ifndef __midl /* IDL compiler used by ActiveMIL */
#include <milsetup.h>
#endif
#endif

/* include mil memory allocator when needed */
#ifdef M_MIL_USE_MEMORY_ALLOCATOR
#include <milmem.h>
#endif

/************************************************************************/
/* Support for old defines name                                         */
/************************************************************************/
#ifndef OldDefinesSupport
   #define OldDefinesSupport     1
#endif


/************************************************************************/
/* MIL HOST CURRENT VERSION  (Inquired by MappInquire)                  */
/************************************************************************/
#define M_MIL_CURRENT_VERSION        7.50
#define M_MIL_CURRENT_ASCII_VERSION  "7.50"


/************************************************************************/
/* MIL buffer identifier type                                           */
/************************************************************************/

#ifndef __midl /* IDL compiler used by ActiveMIL */
typedef long MIL_ID;
#endif

/************************************************************************/
/* MIL main                                                             */
/************************************************************************/
#if M_MIL_USE_CE
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#define main(x) *UnUsedPtr; int WINAPI WinMain(HINSTANCE hInstance,\
                     HINSTANCE hPrevInstance,\
                     LPTSTR     lpCmdLine,\
                     int       nCmdShow)
#endif


/************************************************************************/
/* General default parameters (may be bit encoded)                      */
/************************************************************************/
#define M_NULL                                        0x00000000L
#define M_FALSE                                       0L
#define M_NO                                          0L
#define M_OFF                                         0L
#define M_IN_PROGRESS                                 0L
#define M_FINISHED                                    1L
#define M_TRUE                                        1L
#define M_YES                                         1L
#define M_ON                                          1L
#define M_WAIT                                        1L
#define M_CREATE                                      M_YES
#define M_FREE                                        M_NO
#define M_DEFAULT                                     0x10000000L
#define M_QUIET                                       0x08000000L
#define M_INSFLAG                                     0x04000000L
#define M_VALID                                       0x00000001L
#define M_INVALID                                     -1L
#define M_CLEAR                                       0x00000001L
#define M_NO_CLEAR                                    0x00000002L
#define M_LUT_OFFSET                                  0x80000000L
#define M_ENABLE                                      -9997L
#define M_DISABLE                                     -9999L
#define M_LOCAL                                       0x00000001L
#define M_REMOTE                                      0x00000002L

#define M_EXTENDED                                    0x80000000L            // remove
#define M_EXTENDED_ATTRIBUTE                          M_EXTENDED             // remove

/************************************************************************/
/* Board generic information.                                           */
/************************************************************************/
#define M_RS170                                       0x00000001L
#define M_NTSC                                        0x00000002L
#define M_CCIR                                        0x00000003L
#define M_PAL                                         0x00000004L
#define M_NTSC_RGB                                    0x00000005L
#define M_PAL_RGB                                     0x00000006L
#define M_SECAM_RGB                                   0x00000007L
#define M_SECAM                                       0x00000008L
/* Reserve next 2 values                       from   0x00000009L*/
/*                                             to     0x0000000AL*/


/************************************************************************/
/* Buffer ID offset for defaults                                        */
/************************************************************************/
#define M_UNSIGNED                                    0x00000000L
#define M_SIGNED                                      0x80000000L
#define M_FLOAT                                      (0x40000000L | M_SIGNED)
#define M_DOUBLE                                     (0x20000000L | M_SIGNED)
#define M_SIZE_BIT_MASK                               0x000000FFL
#define M_TYPE_MASK                                   0xFFFFFF00L
#define M_TYPE_DONT_CARE                              M_TYPE_MASK

/************************************************************************/
/* MMX related                                                          */
/************************************************************************/
#define M_READ_PREFETCH_EXTRA_BYTES                   32

//Keep for backward compatibility
#define M_MMX_EXTRA_BYTES                             M_READ_PREFETCH_EXTRA_BYTES

/************************************************************************/
/* Multi thread                                                         */
/************************************************************************/
#define M_MULTI_THREAD                                0x00000001L
#define M_HOST_THREAD                                 0x00000002L
#define M_MIL_THREAD                                  0x00000004L
#define M_STATE                                       0x00000008L
#define M_SIGNALED                                    0x00000010L
#define M_NOT_SIGNALED                                0x00000020L
#define M_THREAD_SELECT                               0x00000040L
#define M_THREAD_DETACH                               0x00000080L
#define M_EVENT_WAIT                                  0x00000100L
#define M_EVENT_STATE                                 0x00000200L
#define M_EVENT_SET                                   0x00000400L
#define M_AUTO_RESET                                  0x00002000L
#define M_MANUAL_RESET                                0x00004000L

#define M_EVENT_ALLOC                                 1700L
#define M_EVENT_FREE                                  1701L
#define M_EVENT_SEND                                  1702L
#define M_EVENT_CONTROL                               1703L
#define M_EVENT_SYNCHRONIZE                           1704L
#define M_THREAD_ALLOC                                1800L
#define M_THREAD_FREE                                 1801L
#define M_THREAD_WAIT                                 1802L
#define M_THREAD_CONTROL                              1803L
#define M_THREAD_MODE                                 1804L
#define M_THREAD_IO_MODE                              1805L

/************************************************************************/
/* General Inquire/Control ...                                          */
/************************************************************************/
#define M_OWNER_APPLICATION                           1000L
#define M_OWNER_SYSTEM                                1001L
#define M_SIZE_X                                      1002L
#define M_SIZE_Y                                      1003L
#define M_SIZE_Z                                      1004L
#define M_SIZE_BAND                                   1005L
#define M_SIZE_BAND_LUT                               1006L
#define M_SIZE_BIT                                    1007L
#define M_TYPE                                        1008L
#define M_NUMBER                                      1009L
#define M_FORMAT                                      1010L
#define M_FORMAT_SIZE                                 1011L
#define M_INIT_FLAG                                   1012L
#define M_ATTRIBUTE                                   1013L
#define M_SIGN                                        1014L
#define M_LUT_ID                                      1015L
#define M_NATIVE_ID                                   1016L
#define M_NATIVE_CONTROL_ID                           1017L
#define M_COLOR_MODE                                  1018L
#define M_THREAD_PRIORITY                             1019L
#define M_NEED_UPDATE                                 1020L
#define M_SURFACE                                     1021L
#define M_WINDOW_DDRAW_SURFACE                        1022L
#define M_OWNER_SYSTEM_TYPE                           1023L
#define M_DISP_NATIVE_ID                              1024L
#define M_SATURATION_SIZE_BIT                         1035L
#define M_SATURATION_TYPE                             1036L
#define M_LOCATION                                    1037L

/************************************************************************/
/* MsysAlloc()                                                          */
/************************************************************************/
/* System type */
#define M_DEFAULT_HOST                                0x10000001L
#define M_SYSTEM_HOST_TYPE                             9L
#define M_SYSTEM_VGA_TYPE                             13L
#define M_SYSTEM_METEOR_TYPE                          15L
#define M_SYSTEM_PULSAR_TYPE                          16L
#define M_SYSTEM_GENESIS_TYPE                         17L
#define M_SYSTEM_CORONA_TYPE                          18L
#define M_SYSTEM_METEOR_II_TYPE                       20L
#define M_SYSTEM_METEOR_II_DIG_TYPE                   21L
#define M_SYSTEM_1394_TYPE                            22L
#define M_SYSTEM_METEOR_II_1394_TYPE                  M_SYSTEM_1394_TYPE
#define M_SYSTEM_MMX_TYPE                             23L
#define M_SYSTEM_SSE_TYPE                             24L
#define M_SYSTEM_ORION_TYPE                           25L
#define M_SYSTEM_SSE2_TYPE                            26L
#define M_SYSTEM_AMD_3DNOW_TYPE                       27L
#define M_SYSTEM_AMD_MMX_EXT_TYPE                     28L
#define M_SYSTEM_AMD_3DNOW_EXT_TYPE                   29L
#define M_SYSTEM_CORONA_II_TYPE                       30L
#define M_SYSTEM_REMOTE_HOST_TYPE                     31L
#define M_SYSTEM_METEOR_II_CL_TYPE                    32L
#define M_SYSTEM_CRONOS_TYPE                          34L
#define M_SYSTEM_ODYSSEY_TYPE                         35L
//#define M_SYSTEM_HELIOS_TYPE                          36L
//#define M_SYSTEM_IRIS_TYPE                            37L
#define M_SYSTEM_CRONOSPLUS_TYPE                     38L


/* MsysAlloc() flags  */
#define M_COMPLETE                                    0x00000000L
#define M_PARTIAL                                     0x00000001L
#define M_WINDOWS                                     0x00000002L
#define M_DISP_WAIT_SELECT                            0x00000004L
#define M_DISP_TEXT_SAVE                              0x00000008L
#define M_USE_DMA_FOR_PROC_BUF                        0x00000010L
#define M_USE_DMA_FOR_DISP_BUF                        0x00000020L
#define M_USE_DMA_FOR_GRAB_BUF                        0x00000040L
#define M_PRE_ALLOC_DMA_MEM                           0x00000080L
#define M_DMA_MEM_MASK                                0x0000FF00L
#define M_NO_INTERRUPT                                0x00010000L
#define M_NO_FIELD_START_INTERRUPT                    0x00020000L
#define M_DISP_NO_WAIT_SELECT                         0x00040000L
#define M_NO_DDRAW                                    0x00080000L
#define M_EXTERNAL_CLK_TTL                            0x00100000L
#define M_SYSTEM_METEOR_II_CL_FLAG                    0x00400000L
#define M_EXTERNAL_CLK_422                            0x00200000L
#define M_DDRAW                                       0x00800000L
#define M_SYSTEM_METEOR_II_FLAG                       0x01000000L
#define M_REGISTER_EDITOR                             0x02000000L
#define M_NEW_SYSALLOC                                0x04000000L
#define M_USE_COMMAND_DECODER                         0x00000100L
#define M_SYS_MD_ID                                   0x08000000L
#define M_DEFAULT                                     0x10000000L
#define M_INTERNAL_ALLOCATION                         0x80000000L
#define M_STAR_GATE                                   0x40000000L
#define M_SYSTEM_CORONA_II_FLAG                       0x20000000L

#define M_DMA_BLOCK_SIZE                           256L

#define M_DMA_BUF_SIZE(Val)  (((((Val+255L)/256L) << 8) & M_DMA_MEM_MASK) | M_PRE_ALLOC_DMA_MEM)
#define M_USE_DMA            (M_USE_DMA_FOR_PROC_BUF | M_USE_DMA_FOR_DISP_BUF | M_USE_DMA_FOR_GRAB_BUF)


/************************************************************************/
/* SysAlloc() in Mil Interpreter                                        */
/************************************************************************/
#define M_SYSTEM_HOST_PTR          (M_SYSTEM_HOST_TYPE            +  50L)
#define M_SYSTEM_VGA_PTR           (M_SYSTEM_VGA_TYPE             +  50L)
#define M_SYSTEM_METEOR_PTR        (M_SYSTEM_METEOR_TYPE          +  50L)
#define M_SYSTEM_PULSAR_PTR        (M_SYSTEM_PULSAR_TYPE          +  50L)
#define M_SYSTEM_GENESIS_PTR       (M_SYSTEM_GENESIS_TYPE         +  50L)
#define M_SYSTEM_CORONA_PTR        (M_SYSTEM_CORONA_TYPE          +  50L)
#define M_SYSTEM_ORION_PTR         (M_SYSTEM_ORION_TYPE           +  50L)
#define M_SYSTEM_METEOR_II_PTR     (M_SYSTEM_METEOR_II_TYPE       +  50L)
#define M_SYSTEM_METEOR_II_DIG_PTR (M_SYSTEM_METEOR_II_DIG_TYPE   +  50L)
#define M_SYSTEM_METEOR_II_CL_PTR  (M_SYSTEM_METEOR_II_CL_TYPE    +  50L)
#define M_SYSTEM_ORION_PTR         (M_SYSTEM_ORION_TYPE           +  50L)
#define M_SYSTEM_CRONOS_PTR        (M_SYSTEM_CRONOS_TYPE          +  50L)
#define M_SYSTEM_CRONOSPLUS_PTR    (M_SYSTEM_CRONOSPLUS_TYPE      +  50L)

/************************************************************************/
/* MsysInquire() / MsysControl() Types                                  */
/************************************************************************/
#define M_OWNER_APPLICATION                           1000L
#define M_OWNER_SYSTEM                                1001L
#define M_TYPE                                        1008L
#define M_NUMBER                                      1009L
#define M_FORMAT                                      1010L
#define M_FORMAT_SIZE                                 1011L
#define M_INIT_FLAG                                   1012L
#define M_ATTRIBUTE                                   1013L
#define M_NATIVE_ID                                   1016L
#define M_NATIVE_CONTROL_ID                           1017L
#define M_LOGICAL_TO_PHYSICAL_ADDRESS                 1018L

#define M_SYSTEM_TYPE                                 2000L
#define M_SYSTEM_TYPE_PTR                             2001L
#define M_DISPLAY_NUM                                 2002L
#define M_DISPLAY_TYPE                                2003L
#define M_DIGITIZER_NUM                               2004L
#define M_DIGITIZER_TYPE                              2005L
#define M_PROCESSOR_NUM                               2006L
//2007L was use by M_PROCESSOR_TYPE, that is now in the processor specific section.
#define M_PROCESSING_SYSTEM                           2008L
#define M_PROCESSING_SYSTEM_TYPE                      2009L
#define M_TUNER_NUM                                   2010L
#define M_TUNER_TYPE                                  2011L
#define M_RGB_MODULE_NUM                              2012L
#define M_RGB_MODULE_TYPE                             2013L
#define M_BOARD_TYPE                                  2014L
#define M_BOARD_REVISION                              2015L
#define M_DISPLAY_LIST                                2016L
#define M_WIN_MODE                                    2017L
#define M_DUAL_SCREEN_MODE                            2018L
#define M_UNDERLAY_SURFACE_AVAILABLE                  2019L
#define M_MAX_TILE_SIZE                               2021L
#define M_MAX_TILE_SIZE_X                             2022L
#define M_MAX_TILE_SIZE_Y                             2023L
#define M_LOW_LEVEL_SYSTEM_ID                         2024L
#define M_NATIVE_THREAD_ID                            2026L
#define M_NATIVE_MODE_ENTER                           2027L
#define M_NATIVE_MODE_LEAVE                           2028L
#define M_PHYSICAL_ADDRESS_UNDERLAY                   2029L
#define M_PHYSICAL_ADDRESS_VGA                        2030L
#define M_PSEUDO_LIVE_GRAB_ON_MGA                     2031L
#define M_PSEUDO_LIVE_GRAB                            2032L
#define M_FORCE_PSEUDO_IN_NON_UNDERLAY_DISPLAYS       2033L
#define M_LIVE_GRAB                                   2034L
#define M_LIVE_GRAB_WHEN_DISPLAY_DOES_NOT_MATCH       2035L
#define M_LIVE_GRAB_TRACK                             2036L
#define M_LIVE_GRAB_MOVE_UPDATE                       2037L
#define M_LIVE_GRAB_END_TRIGGER                       2038L
#define M_STOP_LIVE_GRAB_WHEN_MENU                    2040L
#define M_STOP_LIVE_GRAB_WHEN_INACTIVE                2041L
#define M_STOP_LIVE_GRAB_WHEN_DISABLED                2042L
#define M_GRAB_BY_DISPLAY_CAPTURE                     2043L
#define M_ALLOC_BUF_RGB888_AS_RGB555                  2044L
#define M_RGB555_BUFFER_ALLOCATION                    2045L
#define M_LAST_GRAB_IN_TRUE_BUFFER                    2046L
#define M_NO_GRAB_WHEN_NO_INPUT_SIGNAL                2047L
#define M_PCI_LATENCY                                 2048L
#define M_FAST_PCI_TO_MEM                             2049L
#define M_DCF_SUPPORTED                               2050L
#define M_DMA_ENABLE                                  2051L
#define M_DMA_DISABLE                                 2052L
#define M_DIB_ONLY                                    2053L
#define M_DIB_OR_DDRAW                                2054L
#define M_FLIP_ONLY                                   2055L
#define M_PRIMARY_DDRAW_SURFACE_MEM_PTR               2057L
#define M_PRIMARY_DDRAW_SURFACE_PITCH_BYTE            2058L
#define M_PRIMARY_DDRAW_SURFACE_SIZE_X                2059L
#define M_PRIMARY_DDRAW_SURFACE_SIZE_Y                2060L
#define M_PRIMARY_DDRAW_SURFACE_SIZE_BITS             2061L
#define M_INTERNAL_FORMAT_SIZE                        2062L
#define M_INTERNAL_FORMAT_ENUMERATION                 2063L
#define M_INTERNAL_FORMAT_CHECK                       2064L
#define M_DDRAW_AVAILABLE                             2065L
#define M_BOARD_CODE                                  2066L
#define M_LIVE_GRAB_DDRAW                             2067L
#define M_THREAD_CONTEXT_PTR                          2068L
#define M_PSEUDO_LIVE_GRAB_NB_FRAMES                  2069L
#define M_PSEUDO_LIVE_GRAB_NB_FIELDS                  2070L
#define M_DISPLAY_DOUBLE_BUFFERING                    2071L
#define M_PSEUDO_LIVE_GRAB_TIME                       2072L
#define M_PCI_BRIDGE_LATENCY                          2073L
#define M_PSEUDO_LIVE_GRAB_WITH_DDRAW                 2074L
#define M_MULTI_DISP_IN_UNDERLAY                      2075L
#define M_MULTI_DISP_FOR_GRAB                         2076L
#define M_TIMEOUT                                     2077L
#define M_AUTO_FLIP_FOR_TRUE_COLOR                    2078L
#define M_PCI_BRIDGE_HOST_WRITE_POSTING               2079L
#define M_FAST_MEM_TO_VGA                             2080L
#define M_ERROR_ASYNCHRONOUS_LOG                      2081L
#define M_LIVE_GRAB_WHEN_NOT_VISIBLE                  2082L
//TBM
//This is keep for backward compatibility with MIL 6.1. After MIL 7.0 release, this define will
//have to be rename M_USE_MMX_OLD and the MsysInquire and MsysControl functions will have to be
//modified at all levels to reflect this modification. The flag M_USE_MMX_NEW will be rename to
//M_USE_MMX.
#define M_USE_MMX                                     2083L
#define M_OVERLAPPED_STRUC                            2085L
#define M_PHYSICAL_ADDRESS_VIA                        2086L
#define M_PCI_MGA_ID                                  2087L
#define M_PCI_VIA_ID                                  2088L
#define M_PCI_BRIDGE_ID                               2089L
#define M_NATIVE_SYSTEM_NUMBER                        2090L
#define M_NATIVE_NODE_NUMBER                          2091L
#define M_VIDCAP_WINDOW_HANDLE                        2092L
#define M_CUSTOMER_PRODUCT_ID                         2093L
#define M_UNDERLAY_MEM_SIZE                           2094L
#define M_OVERLAY_MEM_SIZE                            2095L
#define M_VIA_MEM_SIZE                                2096L
#define M_SYSTEM_NAME                                 2097L
#define M_SERIAL_NUMBER                               2098L
#define M_ERROR_CLEAR                                 2099L
#define M_SYS_DEBUG_BUFFER_SIZE                       2100L  // internal use only
#define M_SYS_DEBUG_BUFFER_ID                         2101L  // internal use only
#define M_USE_NOA                                     2102L
#define M_MAIN_DDRAW_OBJECT                           2103L
#define M_COMPRESSION_MODULE_PRESENT                  2104L
#define M_DIGITAL_MODULE_PRESENT                      2105L
#define M_INTERRUPT_NEW_TECHNIQUE                     2106L
#define M_INTERRUPT_NEW_TECHNIQUE_STAT                2107L
#define M_INTERRUPT_NEW_TECHNIQUE_QUEUE               2108L
#define M_INTERRUPT_MASTER_SWITCH                     2109L
#define M_BUS_MASTER_COPY_TO_HOST                     2110L
#define M_BUS_MASTER_COPY_FROM_HOST                   2111L
#define M_MEMORY_OFF_SCREEN_AVAILABLE                 2112L
#define M_BUFCOPY_SUPPORTED                           2113L
#define M_COMPRESSION_SUPPORTED                       2114L

#define M_UART_BUFFER_INIT                            2115L  // internal use only
#define M_UART_BUFFER_FREE                            2116L  // internal use only
#define M_CLL_UART_PARITY                             2117L  // internal use only
#define M_CLL_UART_IRQ_CALL                           2118L  // internal use only
#define M_SET_DUAL_SCREEN_MODE                        2119L  // internal use only
#define M_RESET_GRAB_INFO                             2120L  // internal use only
#define M_COMPRESSION_BOARD_TYPE                      2121L
#define M_COMPRESSION_BOARD_RESET                     2122L
#define M_COMPACT_PCI_PRESENT                         2123L
#define M_HARDWARE_COMPRESSION                        2130L
#define M_HARDWARE_DECOMPRESSION                      2131L
#define M_UART_PRESENT                                2132L
#define M_PC104_PRESENT                               2133L

//TBM
//This is keep for backward compatibility with MIL 6.1. After MIL 7.0 release, this define will
//have to be rename M_USE_SSE_OLD and the MsysInquire and MsysControl functions will have to be
//modified at all levels to reflect this modification. The flag M_USE_SSE_NEW will be rename to
//M_USE_SSE.
#define M_USE_SSE                                     2134L

#define M_USE_DDRAW_UNDERLAY                          2135L
#define M_DDRAW_UNDERLAY_SUPPORTED                    2136L
#define M_DDRAW_UNDERLAY_FORMAT                       2137L
#define M_ENCODER_PRESENT                             2138L
#define M_COMPRESSION_INTERNAL_BUFFER_SIZE            2139L
#define M_PRIMARY_DDRAW_SURFACE_FORMAT                2140L
#define M_LIVE_GRAB_NO_TEARING                        2141L
#define M_DMA_POOL_FREE                               2150L
#define M_DMA_POOL_USED                               2151L
#define M_DMA_POOL_SIZE                               2152L
#define M_DDRAW_UNDERLAY_FORMAT_SUPPORTED             2153L
#define M_BIOS_REVISION                               2154L
#define M_FPGA_REVISION                               2155L
#define M_FIRMWARE_REVISION                           M_FPGA_REVISION
#define M_INTERNAL_CAMERA_STRUCT_PTR                  2156L
#define M_INTERNAL_CAMERA_STRUCT_SIZE                 2157L
#define M_INTERNAL_DRV_DEBUG                          2158L  // Internal use only
#define M_SUPPORTED_INTERFACE                         2159L
//2160L was use by M_USE_SSE2, that is now in the processor specific section.
//2161L was use by M_USE_AMD_3DNOW, that is now in the processor specific section.
//2162L was use by M_USE_AMD_MMX_EXTENSION, that is now in the processor specific section.
//2163L was use by M_USE_AMD_3DNOW_EXTENSION, that is now in the processor specific section.
//2164L was use by M_CPU_VENDOR_NAME, that is now in the processor specific section.
//2165L was use by M_CPU_FAMILY_NUMBER, that is now in the processor specific section.
//2166L was use by M_CPU_MODEL_NUMBER, that is now in the processor specific section.
//2167L was use by M_CPU_STEPPING_NUMBER, that is now in the processor specific section.
//2168L was use by M_CPU_SERIAL_NUMBER, that is now in the processor specific section.
#define M_SYSTEM_NUM                                  2169L
#define M_ASSOCIATED_VGA_SYSTEM_ID                    2170L  // internal use only
#define M_ASSOCIATED_VGA_DEVICE                       2171L
#define M_BOARD_SUB_REVISION                          2200L
#define M_USER_BIT_CHANGE                             2244L
#define M_USER_BIT_CHANGE_HANDLER_PTR                 2245L
/* Reserve next 19 values                       from  2246L*/
/*                                             to     2264L*/
#define M_USER_BIT_CHANGE_HANDLER_USER_PTR            2266L
/* Reserve next 19 values                       from  2267L*/
/*                                             to     2285L*/
#define M_1394_FORCE_BUS_RESET                        2286L
#define M_1394_GENERATION_COUNT                       2287L
#define M_PHYSICAL_SIZE_VGA                           2288L
#define M_CURRENTLY_USED_CAMERA                       2289L
#define M_DIGITIZER_MODE                              2290L
#define M_DDRAW_UNDERLAY_ZOOM_MAX                     3195L
#define M_DDRAW_UNDERLAY_ZOOM_MIN                     3196L
#define M_DUAL_HEAD                                   3197L
#define M_MULTI_MONITOR                               3198L
#define M_SUBSYSTEM_ID                                3199L // internal use only

#define M_DDRAW_OVERLAY_SURFACE_USED                  3200L
/* Reserve next 16 values                      from   3201L*/
/*                                             to     3216L*/
/* Next 16 values are used to specify the index of the VGA.*/
#define M_USE_DDRAW                                   3217L

#define M_USER_BIT_INQUIRE_START                      4363L
#define M_USER_BIT                                    4087L
/* Reserve next 31 values                      from   4088L*/
/*                                             to     4118L*/
/* Reserve next 4 values                       from   4120L*/
/*                                             to     4123L*/
#define M_USER_BIT_COUNT                              4364L
#define M_USER_BIT_OPTOMODULE                         4365L
#define M_USER_BIT_INQUIRE_END                        4366L

//EEPROM-related defines
#define M_EEPROM_SIZE                                 4369L
#define M_EEPROM_L_OFFSET                             4370L
#define M_EEPROM_L_SIZE                               4371L

#define M_BOARD_TYPE_STRING                           4372L
#define M_BOARD_TYPE_STRING_SIZE                      4373L

///////////////////////////////////////////////////////////////////////////////////////////////////
//Processor specific and optimization MsysInquire/MsysControl type.
//The range between 0x00002800 to 0x00002FFF (10240L to 12287).
///////////////////////////////////////////////////////////////////////////////////////////////////
#define M_CPU_FLAG_RANGE                              0x00002800L
#define M_CPU_FLAG_MASK                               0xFFFFF800L

#define M_PROCESSOR_TYPE                              0x00002800L
#define M_INTEL_X86                                   0x00002801L
#define M_INTEL_IA64                                  0x00002802L
#define M_PPC_7400                                    0x00002803L
//Reserved for future processor type                  0x00002804L
//                                                 to 0x0000281FL
#define M_UNKNOWN_TYPE                                0x00002820L

#define M_USE_FULL_OPTIMIZATION                       0x00002821L

//Intel x86 specific
#define M_USE_MMX_NEW                                 0x00002822L
#define M_USE_SSE_INT                                 0x00002823L
#define M_USE_SSE_NEW                                 0x00002824L
#define M_USE_SSE2_INT                                0x00002825L
#define M_USE_SSE2                                    0x00002826L
//Reserved for future Intel instruction set expension 0x00002827L
//                                                 to 0x00002830L
#define M_USE_AMD_3DNOW                               0x00002831L
#define M_USE_AMD_MMX_EXTENSION                       0x00002832L
#define M_USE_AMD_3DNOW_EXTENSION                     0x00002833L
//Reserved for future AMD instruction set expension   0x00002834L
//                                                 to 0x00002840L
#define M_CPU_VENDOR_NAME                             0x00002841L
#define M_CPU_FAMILY_NUMBER                           0x00002842L
#define M_CPU_MODEL_NUMBER                            0x00002843L
#define M_CPU_STEPPING_NUMBER                         0x00002844L
#define M_CPU_SERIAL_NUMBER                           0x00002845L
//Reserved for future processor specific flags        0x00002846L
//                                                 to 0x00002FFFL

//Auxiliary IO defines 4Sight
#define M_USER_BIT                                    4087L
/* Reserve next 31 values                      from   4088L*/
/*                                             to     4118L*/
#define M_USER_BIT_PRESENT                            0x40000000L
#define M_USER_BIT_MODE                               0x80000000L
#define M_USER_BIT_VALUE                              0xA0000000L
#define M_USER_BIT_INTERRUPT_MODE                     0xC0000000L
#define M_USER_BIT_INTERRUPT_STATE                    0xE0000000L
#define M_USER_BIT_MASK                               0xE0000000L
#define M_USER_BIT_BIT_MASK_ENABLED                   0x10000000L
#define M_USER_BIT_INVALID_BIT_MASK                   0x0FFFFFFFL
#define M_USER_BIT_ALL                                0xFFFFF
#define M_BIT_MASK(mask)   ( ((long) mask <= M_USER_BIT_ALL) ? (M_USER_BIT_BIT_MASK_ENABLED | ((long) mask)) : (M_USER_BIT_BIT_MASK_ENABLED | M_USER_BIT_INVALID_BIT_MASK) )
#define M_USER_BIT_CHANGE                             2244L
#define M_USER_BIT_CHANGE_HANDLER_PTR                 2245L
/* Reserve next 19 values                       from  2246L*/
/*                                             to     2264L*/
#define M_USER_BIT_CHANGE_HANDLER_USER_PTR            2266L
/* Reserve next 19 values                       from  2267L*/
/*                                             to     2285L*/
#define M_AGP_TO_PCI_TRANSFER                         2286L
#define M_TRANSFER_PRIORITY                           2287L

// To override compensation on default VGA system
#define M_NO_DEFAULT_VGA_COMPENSATION                 0x01000000L
#define M_IS_NO_DEFAULT_VGA_COMPENSATION(f)           (((f)&M_NO_DEFAULT_VGA_COMPENSATION)&&(((f)&(0xFFFF0000))==M_NO_DEFAULT_VGA_COMPENSATION))

// !!! MAP FOR OLD DEFINES
#if OldDefinesSupport
#define M_LIVE_VIDEO                                  M_LIVE_GRAB
#define M_LAST_GRAB_IN_ACTUAL_BUFFER                  M_LAST_GRAB_IN_TRUE_BUFFER
#define M_SWITCH_TO_PSEUDO_WHEN_OVERLAPPED            M_PSEUDO_LIVE_GRAB
#define M_FORCE_PSEUDO_IN_NON_PULSAR_DISPLAYS         M_FORCE_PSEUDO_IN_NON_UNDERLAY_DISPLAYS
#define M_SYS_TYPE                                    M_SYSTEM_TYPE
#define M_SYS_TYPE_PTR                                M_SYSTEM_TYPE_PTR
#define M_SYS_NUMBER                                  M_NUMBER
#define M_SYS_INIT_FLAG                               M_INIT_FLAG
#define M_SYS_DISPLAY_NUM                             M_DISPLAY_NUM
#define M_SYS_DISPLAY_TYPE                            M_DISPLAY_TYPE
#define M_SYS_DIGITIZER_NUM                           M_DIGITIZER_NUM
#define M_SYS_DIGITIZER_TYPE                          M_DIGITIZER_TYPE
#define M_SYS_PROCESSOR_NUM                           M_PROCESSOR_NUM
#define M_SYS_BOARD_TYPE                              M_BOARD_TYPE
#define M_SYS_BOARD_REVISION                          M_BOARD_REVISION
#define M_SYS_TUNER_NUM                               M_TUNER_NUM
#define M_SYS_TUNER_TYPE                              M_TUNER_TYPE
#define M_SYS_RGB_MODULE_NUM                          M_RGB_MODULE_NUM
#define M_SYS_RGB_MODULE_TYPE                         M_RGB_MODULE_TYPE
#define M_SYS_DISPLAY_LIST                            M_DISPLAY_LIST
#define M_SYS_DUAL_SCREEN_MODE                        M_DUAL_SCREEN_MODE
#define M_SYS_UNDERLAY_SURFACE_AVAILABLE              M_UNDERLAY_SURFACE_AVAILABLE
#define M_SYS_UNDERLAY_SURFACE_PHYSICAL_ADDRESS       M_PHYSICAL_ADDRESS_UNDERLAY
#define M_SYS_WIN_MODE                                M_WIN_MODE
#define M_SYS_MAX_TILE_SIZE                           M_MAX_TILE_SIZE
#define M_SYS_MAX_TILE_SIZE_X                         M_MAX_TILE_SIZE_X
#define M_SYS_MAX_TILE_SIZE_Y                         M_MAX_TILE_SIZE_Y
#define M_ON_BOARD_MEM_ADRS                           M_PHYSICAL_ADDRESS_UNDERLAY
#define M_ON_BOARD_VGA_ADRS                           M_PHYSICAL_ADDRESS_VGA
#define MMX_EXTRA_BYTES                               M_MMX_EXTRA_BYTES
#define M_PSEUDO_LIVE_GRAB_WHEN_OVERLAPPED            M_PSEUDO_LIVE_GRAB

#endif // !!! MAP FOR OLD DEFINES


/************************************************************************/
/* MsysHookFunction()                                                   */
/************************************************************************/
#define M_1394_BUS_RESET                              2287L
#define M_USER_BIT_CHANGE                             2244L
#define M_USER_BIT_CHANGE_HANDLER_PTR                 2245L
/* Reserve next 19 values                       from  2246L*/
/*                                             to     2264L*/
#define M_USER_BIT_CHANGE_HANDLER_USER_PTR            2266L
/* Reserve next 19 values                       from  2267L*/
/*                                             to     2285L*/


/************************************************************************/
/* MsysGetHookInfo()                                                    */
/************************************************************************/

#define M_USER_BIT                                    4087L
/* Reserve next 31 values                      from   4088L*/
/*                                             to     4118L*/
#define M_USER_BIT_FIELD                              4181L
#define M_USER_BIT_CHANGE                             2244L
#define M_USER_BIT_CHANGE_HANDLER_PTR                 2245L
/* Reserve next 19 values                       from  2246L*/
/*                                             to     2264L*/
#define M_USER_BIT_CHANGE_HANDLER_USER_PTR            2266L
/* Reserve next 19 values                       from  2267L*/
/*                                             to     2285L*/


/************************************************************************/
/* MsysConfigAccess()                                                   */
/************************************************************************/
#define M_PCI_CONFIGURATION_SPACE                     0L
#define M_DETECT_PCI_DEVICE                           1L
#define M_1394_CONFIGURATION_SPACE                    2L
#define M_RESERVED_FOR_INTERNAL_USE_SYS_CONFIG        3L

#define M_DEFAULT                                     0x10000000L
#define M_READ                                        1
#define M_WRITE                                       2
#define M_BIG_ENDIAN                                  0x00000100L
#define M_LITTLE_ENDIAN                               0x00000200L


#define M_PCI_VENDOR_ID                               0x00 // (16 lsb)
#define M_PCI_DEVICE_ID                               0x00 // (16 msb)
#define M_PCI_COMMAND                                 0x01 // (16 lsb)
#define M_PCI_STATUS                                  0x01 // (16 msb)
#define M_PCI_REVISION_ID                             0x02 // (byte 0)
#define M_PCI_CLASS_CODE                              0x02 // (byte 1,2,3)
#define M_PCI_LATENCY_TIMER                           0x03 // (byte 1)
#define M_PCI_BASE_ADRS0                              0x04 //
#define M_PCI_BASE_ADRS1                              0x05 //
#define M_PCI_INT_LINE                                0x0F // (byte 0)
#define M_PCI_INT_PIN                                 0x0F // (byte 1)

//Auxiliary IO values 4Sight
#define M_OFF                                         0L       // Must be zero
#define M_ON                                          1L
#define M_INPUT                                       2L
#define M_OUTPUT                                      3L
#define M_EDGE_RISING                                 12L
#define M_EDGE_FALLING                                13L
#define M_DISABLE                                     -9999L
#define M_ENABLE                                      -9997L


/************************************************************************/
/* MdispAlloc() for Windowed system                                     */
/************************************************************************/
/* DispNum */
#define M_DEV0                                        0L
#define M_DEV1                                        1L
#define M_DEV2                                        2L
#define M_DEV3                                        3L
#define M_DEV4                                        4L
#define M_DEV5                                        5L
#define M_DEV6                                        6L
#define M_DEV7                                        7L
#define M_DEV8                                        8L
#define M_DEV9                                        9L
#define M_DEV10                                       10L
#define M_DEV11                                       11L
#define M_DEV12                                       12L
#define M_DEV13                                       13L
#define M_DEV14                                       14L
#define M_DEV15                                       15L
#define M_DEV16                                       16L
#define M_DEV17                                       17L
#define M_DEV18                                       18L
#define M_DEV19                                       19L
#define M_DEV20                                       20L
#define M_DEV21                                       21L
#define M_DEV22                                       22L
#define M_DEV23                                       23L
#define M_DEV24                                       24L
#define M_DEV25                                       25L
#define M_DEV26                                       26L
#define M_DEV27                                       27L
#define M_DEV28                                       28L
#define M_DEV29                                       29L
#define M_DEV30                                       30L
#define M_DEV31                                       31L
#define M_DEV32                                       32L
#define M_DEV33                                       33L
#define M_DEV34                                       34L
#define M_DEV35                                       35L
#define M_DEV36                                       36L
#define M_DEV37                                       37L
#define M_DEV38                                       38L
#define M_DEV39                                       39L
#define M_DEV40                                       40L
#define M_DEV41                                       41L
#define M_DEV42                                       42L
#define M_DEV43                                       43L
#define M_DEV44                                       44L
#define M_DEV45                                       45L
#define M_DEV46                                       46L
#define M_DEV47                                       47L
#define M_DEV48                                       48L
#define M_DEV49                                       49L
#define M_DEV50                                       50L
#define M_DEV51                                       51L
#define M_DEV52                                       52L
#define M_DEV53                                       53L
#define M_DEV54                                       54L
#define M_DEV55                                       55L
#define M_DEV56                                       56L
#define M_DEV57                                       57L
#define M_DEV58                                       58L
#define M_DEV59                                       59L
#define M_DEV60                                       60L
#define M_DEV61                                       61L
#define M_DEV62                                       62L
#define M_DEV63                                       63L
#define M_NODE0                                       0x00010000L
#define M_NODE1                                       0x00020000L
#define M_NODE2                                       0x00040000L
#define M_NODE3                                       0x00080000L
#define M_NODE4                                       0x00100000L
#define M_NODE5                                       0x00200000L
#define M_NODE6                                       0x00400000L
#define M_NODE7                                       0x00800000L
#define M_NODE8                                       0x01000000L
#define M_NODE9                                       0x02000000L
#define M_NODE10                                      0x04000000L
#define M_NODE11                                      0x08000000L
#define M_NODE12                                      0x10000000L
#define M_NODE13                                      0x20000000L
#define M_NODE14                                      0x40000000L
#define M_NODE15                                      0x80000000L
/* Init Flag */
#define M_WINDOWED                                    0x01000000L
#define M_NON_WINDOWED                                0x02000000L
#define M_BASE_DRIVER                                 0x04000000L
#define M_OVR                                         0x00000080L
#define M_OVERLAY                                     M_OVR
#define M_UND                                         0x40000000L
#define M_UNDERLAY                                    M_UND
#define M_DDRAW_UNDERLAY                              0x00000002L
#define M_DDRAW_UND                                   M_DDRAW_UNDERLAY
#define M_VIDEO_ENCODER                               0x00000200L
#define M_DUAL_SCREEN                                 0x00040000L
#define M_SINGLE_SCREEN                               0x00080000L
#define M_WINDOW_MAXIMIZE                             0x00000008L
#define M_WINDOW_NO_MENUBAR                           0x00000010L
#define M_WINDOW_NO_TITLEBAR                          0x00000020L
#define M_WINDOW_NO_KEY                               0x00000040L
#define M_WINDOW_USE_FORMAT                           0x00000100L
#define M_ZOOM_ENHANCED                               0x00000000L
#define M_ZOOM_BASIC                                  0x00000400L
#define M_DISPLAY_8_BASIC                             0x00000000L
#define M_DISPLAY_8_ENHANCED                          0x00000800L
#define M_DISPLAY_24_ENHANCED                         0x00000000L
#define M_DISPLAY_24_BASIC                            0x00001000L
#define M_DISPLAY_24_WINDOWS                          0x00002000L
#define M_DISPLAY_ENHANCED                            (M_DISPLAY_8_ENHANCED + M_DISPLAY_24_ENHANCED)
#define M_DISPLAY_BASIC                               (M_DISPLAY_8_BASIC    + M_DISPLAY_24_BASIC   )
#define M_DISPLAY_WINDOWS                             (M_DISPLAY_8_BASIC    + M_DISPLAY_24_WINDOWS )
#define M_WINDOW_NO_SYSBUTTON                         0x00004000L
#define M_WINDOW_NO_MINBUTTON                         0x00008000L
#define M_WINDOW_NO_MAXBUTTON                         0x00010000L
#define M_COLORTABLE_INDEX                            0x00020000L
#define M_COLORTABLE_RGB                              0x00000000L
#define M_PALETTE_NOCOLLAPSE                          0x00100000L
#define M_PALETTE_COLLAPSE                            0x00000000L
#define M_USE_MEMORY_VCF                              0x00000010L
#define M_AUXILIARY                                   0x00200000L
#define M_USE_EXTERNAL_CLOCK                          0x00400000L
#define M_USE_INTERNAL_CLOCK                          0x00800000L

/************************************************************************/
/* MdispInquire() / MdispControl() Types                                */
/************************************************************************/
#define M_OWNER_APPLICATION                           1000L
#define M_OWNER_SYSTEM                                1001L
#define M_SIZE_X                                      1002L
#define M_SIZE_Y                                      1003L
#define M_SIZE_Z                                      1004L
#define M_SIZE_BAND                                   1005L
#define M_SIZE_BAND_LUT                               1006L
#define M_SIZE_BIT                                    1007L
#define M_TYPE                                        1008L
#define M_NUMBER                                      1009L
#define M_FORMAT                                      1010L
#define M_FORMAT_SIZE                                 1011L
#define M_INIT_FLAG                                   1012L
#define M_ATTRIBUTE                                   1013L
#define M_SIGN                                        1014L
#define M_LUT_ID                                      1015L
#define M_NATIVE_ID                                   1016L
#define M_NATIVE_CONTROL_ID                           1017L
#define M_COLOR_MODE                                  1018L
#define M_THREAD_PRIORITY                             1019L
#define M_NEED_UPDATE                                 1020L
#define M_SURFACE                                     1021L
#define M_WINDOW_DDRAW_SURFACE                        1022L
#define M_OWNER_SYSTEM_TYPE                           1023L
#define M_DISP_NATIVE_ID                              1024L
#define M_ENCODER_START                               1025L
#define M_ENCODER                                     M_ENCODER_START
#define M_ENCODER_MODE                                1026L
#define M_ENCODER_TYPE                                1027L
#define M_ENCODER_SYNC_SOURCE                         1028L
#define M_ENCODER_SYNC                                M_ENCODER_SYNC_SOURCE
#define M_ENCODER_PEDESTAL                            1029L
#define M_ENCODER_FILTER                              1030L
#define M_ENCODER_RGB_SYNC                            1031L
#define M_ENCODER_INFO_MODE                           1032L
#define M_ENCODER_RESET                               1033L   //1034 reseved
#define M_ENCODER_SELECT_FIELD_ODD                    1037L
#define M_ENCODER_SELECT_FIELD_EVEN                   1038L
#define M_ENCODER_CONTRAST                            1039L
#define M_ENCODER_BRIGHTNESS                          1040L
#define M_ENCODER_SATURATION                          1041L
#define M_ENCODER_HUE                                 1042L
#define M_ENCODER_OVR_SHOW                            1043L
#define M_ENCODER_OVR_LUT                             1044L
#define M_ENCODER_OVR_BUF_ID                          1045L

#define M_ENCODER_STATE                               M_ENCODER
#define M_SYNC_TYPE                                   M_ENCODER_RGB_SYNC
#define M_ENCODER_SYNC_LOCK                           M_ENCODER_SYNC_SOURCE
#define M_FILTER                                      1046L
#define M_ENCODER_SYNC_FIELDS                         1047L
#define M_ENCODER_CLOCK                               1048L

#define M_UNDERLAY_PAN_Y                              1049L
#define M_UNDERLAY_PAN_X                              1050L
/* Reserve next values endoder use             from   1049L*/
/*                                             to     1100L*/
#define M_ENCODER_END                                 1100L

#define M_PAN_X                                       3000L
#define M_PAN_Y                                       3001L
#define M_ZOOM_X                                      3002L
#define M_ZOOM_Y                                      3003L
#define M_HARDWARE_PAN                                3004L
#define M_HARDWARE_ZOOM                               3005L
#define M_SELECTED                                    3006L
#define M_KEY_MODE                                    3007L
#define M_KEY_CONDITION                               3008L
#define M_KEY_MASK                                    3009L
#define M_KEY_COLOR                                   3010L
#define M_KEY_SUPPORTED                               3011L
#define M_VGA_BUF_ID                                  3012L
#define M_WINDOW_BUF_WRITE                            3013L
#define M_WINDOW_BUF_ID                               3014L
#define M_WINDOW_OVR_BUF_ID                           3015L
#define M_WINDOW_OVR_WRITE                            3016L
#define M_WINDOW_OVR_DISP_ID                          3017L
#define M_INTERPOLATION_MODE                          3018L
#define M_HOOK_OFFSET                                 3019L
#define M_FRAME_START_HANDLER_PTR                     3020L
#define M_FRAME_START_HANDLER_USER_PTR                3021L
#define M_WINDOW_OVR_LUT                              3022L
#define M_WINDOW_OVR_SHOW                             3023L
#define M_WINDOW_DISPLAY_SETTINGS                     3024L
#define M_WINDOW_OVR_LUT_REMAP                        3025L
#define M_WINDOW_AUTO_ACTIVATION_FOR_DDRAW            3026L
#define M_DISPLAY_16_TO_8                             3027L
#define M_DISPLAY_16_TO_8_SHIFT                       3028L
#define M_DISPLAY_MODE                                3029L
#define M_WINDOW_OVR_FLICKER                          3031L
#define M_VGA_PIXEL_FORMAT                            3032L
#define M_LUT_SUPPORTED                               3033L


#define M_WINDOW_ZOOM                                 3051L
#define M_WINDOW_RESIZE                               3052L
#define M_WINDOW_OVERLAP                              3053L
#define M_WINDOW_SCROLLBAR                            3054L
#define M_WINDOW_UPDATE                               3055L
#define M_WINDOW_PROTECT_AREA                         3056L
#define M_WINDOW_TITLE_BAR                            3057L
#define M_WINDOW_MENU_BAR                             3058L
#define M_WINDOW_TITLE_BAR_CHANGE                     3059L
#define M_WINDOW_MENU_BAR_CHANGE                      3060L
#define M_WINDOW_MOVE                                 3061L
#define M_WINDOW_SYSBUTTON                            3062L
#define M_WINDOW_MINBUTTON                            3063L
#define M_WINDOW_MAXBUTTON                            3064L
#define M_WINDOW_COLOR                                3065L
#define M_WINDOW_COLOR_CHANGE                         3066L
#define M_PALETTE_WINDOWS                             3068L
#define M_WINDOW_PALETTE_NOCOLLAPSE                   3069L
#define M_WINDOW_PALETTE_BACKGROUND                   3070L
#define M_WINDOW_PALETTE_AUTO                         3071L
#define M_WINDOW_ERASE_BACKGROUND                     3072L
#define M_WINDOW_UPDATE_AUTO_ON_CONTROL               3073L
#define M_WINDOW_UPDATE_WITH_SEND_MESSAGE             3074L
#define M_WINDOW_SNAP_X                               3075L
#define M_WINDOW_SNAP_Y                               3076L
#define M_WINDOW_UPDATE_REGION                        3077L
#define M_WINDOW_UPDATE_ONLY_INVALID_BORDER           3078L
#define M_WINDOW_UPDATE_KEEP_PALETTE_ALIVE            3079L
#define M_WINDOW_UPDATE_ADD_BEGINPAINT                3080L
#define M_WINDOW_UPDATE_ON_PAINT                      3081L
#define M_WINDOW_UPDATE_MANUAL                        3082L
#define M_WINDOW_PAINT                                3083L
#define M_WINDOW_ACTIVATE_DELAY                       3084L
#define M_WINDOW_CLIP_IN_CLIENT                       3085L
#define M_WINDOW_SYNC_SELECT                          3087L
#define M_WINDOW_INITIAL_POSITION_X                   3088L
#define M_WINDOW_INITIAL_POSITION_Y                   3089L
#define M_WINDOW_BENCHMARK_IN_DEBUG                   3090L
#define M_WINDOW_RANGE                                3091L
#define M_WINDOW_OVR_BUFFER_ALIVE                     3092L
#define M_WINDOW_OVR_BUFFER_PTR                       3093L
#define M_WINDOW_OVR_FLICKER_FREE_ALIVE               3094L
#define M_WINDOW_OVR_FLICKER_FREE_PTR                 3095L
#define M_WINDOW_OVR_DESTRUCTIVE                      3096L
#define M_WINDOW_OVR_KEYER_PTR                        3097L
#define M_WINDOW_MANUAL_OVR_ADD                       3098L
#define M_WINDOW_MANUAL_FLICKER_COPY                  3099L
#define M_WINDOW_MANUAL_OVR_ADD_FLICKER_COPY          3100L
#define M_WINDOW_USE_SUBCLASS_TRACKING                3101L
#define M_WINDOW_USE_SYSTEMHOOK_TRACKING              3102L
#define M_WINDOW_ATTRIBUTE_FOR_OVERLAY                3103L
#define M_WINDOW_ATTRIBUTE_FOR_FLICKER                3104L
#define M_WINDOW_MASK_FOR_OVERLAY_VERIFICATION        3105L
#define M_WINDOW_MASK_FOR_FLICKER_VERIFICATION        3106L
#define M_DESKTOP_CHANGE                              3107L
#define M_WINDOW_HOOK_BLOCKING_SERIALIZATION          3108L
#define M_WINDOW_ATTRIBUTE_FOR_BUFFER                 3109L
#define M_WINDOW_HANDLE                               3110L
#define M_WINDOW_OFFSET_X                             3111L
#define M_WINDOW_OFFSET_Y                             3112L
#define M_WINDOW_SIZE_X                               3113L
#define M_WINDOW_SIZE_Y                               3114L
#define M_WINDOW_PAN_X                                3115L
#define M_WINDOW_PAN_Y                                3116L
#define M_WINDOW_ZOOM_X                               3117L
#define M_WINDOW_ZOOM_Y                               3118L
#define M_WINDOW_TITLE_NAME                           3119L
#define M_HOOK_MODIFIED_DIB_PTR                       3120L
#define M_WINDOW_USE_SYSTEMHOOK_TRACKING_ACTIVE       3121L
/* Reserve next 2 values                       from   3121L*/
/*                                             to     3122L*/
#define M_HOOK_MODIFIED_DIB_USER_PTR                  3123L
/* Reserve next 2 values                       from   3124L*/
/*                                             to     3125L*/
#define M_HOOK_MODIFIED_WINDOW_PTR                    3126L
/* Reserve next 2 values                       from   3127L*/
/*                                             to     3128L*/
#define M_HOOK_MODIFIED_WINDOW_USER_PTR               3129L
/* Reserve next 2 values                       from   3130L*/
/*                                             to     3131L*/
#define M_HOOK_MESSAGE_LOOP_PTR                       3132L
/* Reserve next 2 values                       from   3133L*/
/*                                             to     3134L*/
#define M_HOOK_MESSAGE_LOOP_USER_PTR                  3135L
/* Reserve next 2 values                       from   3136L*/
/*                                             to     3137L*/
#define M_WINDOW_APPFRAME_HANDLE                      3138L
#define M_WINDOW_MDICLIENT_HANDLE                     3139L
#define M_WINDOW_MDIFRAME_HANDLE                      3140L
#define M_WINDOW_VISIBLE_OFFSET_X                     3141L
#define M_WINDOW_VISIBLE_OFFSET_Y                     3142L
#define M_WINDOW_VISIBLE_SIZE_X                       3145L
#define M_WINDOW_VISIBLE_SIZE_Y                       3146L
#define M_WINDOW_DIB_HANDLE                           3147L
#define M_WINDOW_DISPLAY_DIB_HANDLE                   3148L
#define M_WINDOW_ACTIVE                               3149L
#define M_WINDOW_ENABLE                               3150L
#define M_PALETTE_HANDLE                              3151L
#define M_WINDOW_THREAD_HANDLE                        3152L
#define M_WINDOW_THREAD_ID                            3153L
#define M_WINDOW_DIB_HEADER                           3154L
#define M_WINDOW_KEYBOARD_USE                         3155L
#define M_WINDOW_CLIP_LIST_SIZE                       3156L
#define M_WINDOW_CLIP_LIST                            3157L
#define M_WINDOW_CLIP_LIST_ACCESS                     3158L
#define M_FRAME_START_TRIGGER_MODE                    3159L
#define M_FRAME_START_TRIGGER                         3160L
#define M_WINDOW_DIB                                  3161L
#define M_WINDOW_MAP_BUFFER                           3162L
#define M_WINDOW_UPDATE_EXCLUDE_RECTANGLE             3164L
#define M_WINDOW_SYNC_UPDATE                          3165L
#define M_WINDOW_TITLE_NAME_SIZE                      3166L
#define M_WINDOW_DRIVER_SIZE_BIT                      3167L
#define M_WINDOW_SYNC_UPDATE_WHEN_HOOK_BLOCKED        3168L
#define M_WINDOW_CLIP_LIST_BLOCKING_SERIALIZATION     3169L
#define M_DESKTOP_LOCK_TIMEOUT                        3170L
#define M_WINDOW_PALETTE_MESSAGES                     3171L
#define M_WINDOW_PAINT_MESSAGES                       3172L
#define M_WINDOW_COMMAND_PROMPT_FULL_DRAG             3173L
#define M_WINDOW_DISPLAY_MODE                         3174L
#define M_WINDOW_REFRESH_AT_DESELECT                  3175L
#define M_WINDOW_ASSOCIATED_VIDCAP_WND                3176L
#define M_WINDOW_ASSOCIATED_VIDCAP_WND_DLG_SOURCE     3177L
#define M_WINDOW_ASSOCIATED_VIDCAP_WND_DLG_FORMAT     3178L
#define M_WINDOW_ASSOCIATED_VIDCAP_WND_DLG_DISPLAY    3179L
#define M_WINDOW_BLIT_WITH_DDRAW                      3180L
#define M_DESKTOP_CURRENT_SCAN_LINE                   3181L
#define M_VIEW_MODE                                   3182L
#define M_VIEW_BIT_SHIFT                              3183L
#define M_DDRAW_UNDERLAY_SET_POSITION                 3184L
#define M_DDRAW_UPDATE_OVERLAY                        3185L
#define M_WINDOW_DDRAW_DDCAPS                         3186L
#define M_FLIP_DDRAW_SURFACE                          3187L
#define M_NO_TEARING                                  3188L
#define M_DEFAULT_PALETTE                             3189L
#define M_ZOOM_MAX_X                                  3190L
#define M_ZOOM_MIN_X                                  3191L
#define M_ZOOM_MAX_Y                                  3192L
#define M_ZOOM_MIN_Y                                  3193L
#define M_WINDOW_PAINT_DURING_WM_QUERYNEWPALETTE      3194L
#define M_DDRAW_UNDERLAY_ZOOM_MAX                     3195L
#define M_DDRAW_UNDERLAY_ZOOM_MIN                     3196L
#define M_DUAL_ZOOM                                   3197L
#define M_DUAL_ZOOM_SUPPORTED                         3198L
#define M_UPDATE                                      3199L
#define M_WINDOW_MOVING_STATE                         3200L
#define M_WINDOW_OVR_FLICKER_BUF_ID                   3201L
#define M_WINDOW_VISIBLE                              3202L
#define M_SCALE_X                                     3203L
#define M_SCALE_Y                                     3204L
#define M_WINDOW_SUBCLASSING_RESISTANT                3205L // internal use only
#define M_AUXILIARY_BUF_ID                            3206L // internal use only

#define M_SCALE                                 0x00008010L

// MdispControl(M_REMAP_TYPE)
#define M_BIT_SHIFT                                      1L
#define M_AUTO_SCALE                                     2L
#define M_MULTI_BYTES                                    3L
#define M_LOGARITHMIC                                    4L
#define M_PIXEL_VALUES                                   5L

// !!! MAP FOR OLD DEFINES
#if OldDefinesSupport
#define M_DISP_LUT                                    M_LUT_ID
#define M_DISP_NUMBER                                 M_NUMBER
#define M_DISP_FORMAT                                 M_FORMAT
#define M_DISP_INIT_FLAG                              M_INIT_FLAG
#define M_DISP_PAN_X                                  M_PAN_X
#define M_DISP_PAN_Y                                  M_PAN_Y
#define M_DISP_ZOOM_X                                 M_ZOOM_X
#define M_DISP_ZOOM_Y                                 M_ZOOM_Y
#define M_DISP_HARDWARE_PAN                           M_HARDWARE_PAN
#define M_DISP_HARDWARE_ZOOM                          M_HARDWARE_ZOOM
#define M_DISP_KEY_MODE                               M_KEY_MODE
#define M_DISP_KEY_CONDITION                          M_KEY_CONDITION
#define M_DISP_KEY_MASK                               M_KEY_MASK
#define M_DISP_KEY_COLOR                              M_KEY_COLOR
#define M_DISP_16_TO_8                                M_DISPLAY_16_TO_8
#define M_DISP_16_TO_8_SHIFT                          M_DISPLAY_16_TO_8_SHIFT
#define M_DISP_MODE                                   M_DISPLAY_MODE
#define M_DISP_THREAD_PRIORITY                        M_THREAD_PRIORITY
#define M_DISP_INTERPOLATION_MODE                     M_INTERPOLATION_MODE
#define M_DISP_HOOK_OFFSET                            M_HOOK_OFFSET
#define M_DISP_VGA_BUF_ID                             M_VGA_BUF_ID
#define M_DISP_OVR_WRITE                              M_WINDOW_OVR_WRITE
#define M_DISP_OVR_BUF_ID                             M_WINDOW_OVR_BUF_ID
#define M_DISP_BUF_WRITE                              M_WINDOW_BUF_WRITE
#define M_DISP_BUF_ID                                 M_WINDOW_BUF_ID
#define M_DISP_WINDOW_OVR_BUF_ID                      M_WINDOW_OVR_BUF_ID
#define M_DISP_WINDOW_OVR_WRITE                       M_WINDOW_OVR_WRITE
#define M_DISP_VGA_DISPLAY_ID                         M_WINDOW_OVR_DISP_ID
#define M_DISP_KEY_SUPPORTED                          M_KEY_SUPPORTED

#define M_DISP_WINDOW_ZOOM                            M_WINDOW_ZOOM
#define M_DISP_WINDOW_RESIZE                          M_WINDOW_RESIZE
#define M_DISP_WINDOW_OVERLAP                         M_WINDOW_OVERLAP
#define M_DISP_WINDOW_SCROLLBAR                       M_WINDOW_SCROLLBAR
#define M_DISP_WINDOW_UPDATE                          M_WINDOW_UPDATE
#define M_DISP_WINDOW_PROTECT_AREA                    M_WINDOW_PROTECT_AREA
#define M_DISP_WINDOW_TITLE_BAR                       M_WINDOW_TITLE_BAR
#define M_DISP_WINDOW_MENU_BAR                        M_WINDOW_MENU_BAR
#define M_DISP_WINDOW_TITLE_BAR_CHANGE                M_WINDOW_TITLE_BAR_CHANGE
#define M_DISP_WINDOW_MENU_BAR_CHANGE                 M_WINDOW_MENU_BAR_CHANGE
#define M_DISP_WINDOW_MOVE                            M_WINDOW_MOVE
#define M_DISP_WINDOW_SYSBUTTON                       M_WINDOW_SYSBUTTON
#define M_DISP_WINDOW_MINBUTTON                       M_WINDOW_MINBUTTON
#define M_DISP_WINDOW_MAXBUTTON                       M_WINDOW_MAXBUTTON
#define M_DISP_WINDOW_COLOR                           M_WINDOW_COLOR
#define M_DISP_WINDOW_COLOR_CHANGE                    M_WINDOW_COLOR_CHANGE
#define M_DISP_WINDOW_PALETTE_NOCOLLAPSE              M_WINDOW_PALETTE_NOCOLLAPSE
#define M_DISP_WINDOW_PALETTE_BACKGROUND              M_WINDOW_PALETTE_BACKGROUND
#define M_DISP_WINDOW_PALETTE_AUTO                    M_WINDOW_PALETTE_AUTO
#define M_DISP_WINDOW_ERASE_BACKGROUND                M_WINDOW_ERASE_BACKGROUND
#define M_DISP_WINDOW_AUTO_UPDATE                     M_WINDOW_UPDATE_AUTO_ON_CONTROL
#define M_DISP_WINDOW_UPDATE_WITH_MESSAGE             M_WINDOW_UPDATE_WITH_SEND_MESSAGE
#define M_DISP_WINDOW_SNAP_X                          M_WINDOW_SNAP_X
#define M_DISP_WINDOW_SNAP_Y                          M_WINDOW_SNAP_Y
#define M_DISP_WINDOW_UPDATE_REGION                   M_WINDOW_UPDATE_REGION
#define M_DISP_WINDOW_UPDATE_ONLY_INVALID_BORDER      M_WINDOW_UPDATE_ONLY_INVALID_BORDER
#define M_DISP_WINDOW_UPDATE_KEEP_PALETTE_ALIVE       M_WINDOW_UPDATE_KEEP_PALETTE_ALIVE
#define M_DISP_WINDOW_MANUAL_UPDATE                   M_WINDOW_UPDATE_MANUAL
#define M_DISP_WINDOW_PAINT                           M_WINDOW_PAINT
#define M_DISP_WINDOW_ACTIVATE_DELAY                  M_WINDOW_ACTIVATE_DELAY
#define M_DISP_WINDOW_CLIP_IN_CLIENT                  M_WINDOW_CLIP_IN_CLIENT
#define M_DISP_WINDOW_SYNC_SELECT                     M_WINDOW_SYNC_SELECT
#define M_DISP_WINDOW_INITIAL_POSITION_X              M_WINDOW_INITIAL_POSITION_X
#define M_DISP_WINDOW_INITIAL_POSITION_Y              M_WINDOW_INITIAL_POSITION_Y
#define M_DISP_WINDOW_BENCHMARK_IN_DEBUG              M_WINDOW_BENCHMARK_IN_DEBUG
#define M_DISP_WINDOW_RANGE                           M_WINDOW_RANGE
#define M_DISP_WINDOW_OVR_BUFFER_ALIVE                M_WINDOW_OVR_BUFFER_ALIVE
#define M_DISP_WINDOW_OVR_BUFFER_PTR                  M_WINDOW_OVR_BUFFER_PTR
#define M_DISP_WINDOW_OVR_FLICKER_FREE_ALIVE          M_WINDOW_OVR_FLICKER_FREE_ALIVE
#define M_DISP_WINDOW_OVR_FLICKER_FREE_PTR            M_WINDOW_OVR_FLICKER_FREE_PTR
#define M_DISP_WINDOW_OVR_DESTRUCTIVE                 M_WINDOW_OVR_DESTRUCTIVE
#define M_DISP_WINDOW_OVR_KEYER_PTR                   M_WINDOW_OVR_KEYER_PTR
#define M_DISP_WINDOW_MANUAL_OVR_ADD                  M_WINDOW_MANUAL_OVR_ADD
#define M_DISP_WINDOW_MANUAL_FLICKER_COPY             M_WINDOW_MANUAL_FLICKER_COPY
#define M_DISP_WINDOW_MANUAL_OVR_ADD_FLICKER_COPY     M_WINDOW_MANUAL_OVR_ADD_FLICKER_COPY
#define M_DISP_WINDOW_USE_SUBCLASS_TRACKING           M_WINDOW_USE_SUBCLASS_TRACKING
#define M_DISP_WINDOW_USE_SYSTEMHOOK_TRACKING         M_WINDOW_USE_SYSTEMHOOK_TRACKING
#define M_DISP_WINDOW_ATTRIBUTE_FOR_OVERLAY           M_WINDOW_ATTRIBUTE_FOR_OVERLAY
#define M_DISP_WINDOW_ATTRIBUTE_FOR_FLICKER           M_WINDOW_ATTRIBUTE_FOR_FLICKER
#define M_DISP_WINDOW_MASK_FOR_OVERLAY_VERIFICATION   M_WINDOW_MASK_FOR_OVERLAY_VERIFICATION
#define M_DISP_WINDOW_MASK_FOR_FLICKER_VERIFICATION   M_WINDOW_MASK_FOR_FLICKER_VERIFICATION
#define M_DISP_DESKTOP_CHANGE                         M_DESKTOP_CHANGE

#define M_DISP_WINDOW_HANDLE                          M_WINDOW_HANDLE
#define M_DISP_WINDOW_OFFSET_X                        M_WINDOW_OFFSET_X
#define M_DISP_WINDOW_OFFSET_Y                        M_WINDOW_OFFSET_Y
#define M_DISP_WINDOW_SIZE_X                          M_WINDOW_SIZE_X
#define M_DISP_WINDOW_SIZE_Y                          M_WINDOW_SIZE_Y
#define M_DISP_WINDOW_PAN_X                           M_WINDOW_PAN_X
#define M_DISP_WINDOW_PAN_Y                           M_WINDOW_PAN_Y
#define M_DISP_WINDOW_ZOOM_X                          M_WINDOW_ZOOM_X
#define M_DISP_WINDOW_ZOOM_Y                          M_WINDOW_ZOOM_Y
#define M_DISP_WINDOW_TITLE_NAME                      M_WINDOW_TITLE_NAME
#define M_DISP_HOOK_MODIFIED_DIB_PTR                  M_HOOK_MODIFIED_DIB_PTR
#define M_DISP_HOOK_MODIFIED_DIB_USER_PTR             M_HOOK_MODIFIED_DIB_USER_PTR
#define M_DISP_HOOK_MODIFIED_WINDOW_PTR               M_HOOK_MODIFIED_WINDOW_PTR
#define M_DISP_HOOK_MODIFIED_WINDOW_USER_PTR          M_HOOK_MODIFIED_WINDOW_USER_PTR
#define M_DISP_HOOK_MESSAGE_LOOP_PTR                  M_HOOK_MESSAGE_LOOP_PTR
#define M_DISP_HOOK_MESSAGE_LOOP_USER_PTR             M_HOOK_MESSAGE_LOOP_USER_PTR
#define M_DISP_WINDOW_APPFRAME_HANDLE                 M_WINDOW_APPFRAME_HANDLE
#define M_DISP_WINDOW_MDICLIENT_HANDLE                M_WINDOW_MDICLIENT_HANDLE
#define M_DISP_WINDOW_MDIFRAME_HANDLE                 M_WINDOW_MDIFRAME_HANDLE
#define M_DISP_VISIBLE_OFFSET_X                       M_WINDOW_VISIBLE_OFFSET_X
#define M_DISP_VISIBLE_OFFSET_Y                       M_WINDOW_VISIBLE_OFFSET_Y
#define M_DISP_VISIBLE_SIZE_X                         M_WINDOW_VISIBLE_SIZE_X
#define M_DISP_VISIBLE_SIZE_Y                         M_WINDOW_VISIBLE_SIZE_Y
#define M_VISIBLE_OFFSET_X                            M_WINDOW_VISIBLE_OFFSET_X
#define M_VISIBLE_OFFSET_Y                            M_WINDOW_VISIBLE_OFFSET_Y
#define M_VISIBLE_SIZE_X                              M_WINDOW_VISIBLE_SIZE_X
#define M_VISIBLE_SIZE_Y                              M_WINDOW_VISIBLE_SIZE_Y
#define M_DISP_WINDOW_DIB_HANDLE                      M_WINDOW_DIB_HANDLE
#define M_DISP_WINDOW_DISPLAY_DIB_HANDLE              M_WINDOW_DISPLAY_DIB_HANDLE
#define M_DISP_WINDOW_ACTIVE                          M_WINDOW_ACTIVE
#define M_DISP_WINDOW_ENABLE                          M_WINDOW_ENABLE
#define M_DISP_PALETTE_HANDLE                         M_PALETTE_HANDLE
#define M_DISP_WINDOW_THREAD_HANDLE                   M_WINDOW_THREAD_HANDLE
#define M_DISP_WINDOW_THREAD_ID                       M_WINDOW_THREAD_ID
#define M_DISP_WINDOW_DIB                             M_WINDOW_DIB
#define M_DISP_WINDOW_CLIP_LIST_SIZE                  M_WINDOW_CLIP_LIST_SIZE
#define M_DISP_WINDOW_CLIP_LIST                       M_WINDOW_CLIP_LIST
#define M_DISP_WINDOW_CLIP_LIST_ACCESS                M_WINDOW_CLIP_LIST_ACCESS

#define M_DISP_WINDOW_CHANGE_TITLE_BAR                M_DISP_WINDOW_TITLE_BAR_CHANGE
#define M_DISP_WINDOW_CHANGE_MENU_BAR                 M_DISP_WINDOW_MENU_BAR_CHANGE
#define M_DISP_WINDOW_CHANGE_COLOR                    M_DISP_WINDOW_COLOR_CHANGE
#define M_DISP_WINDOW_DO_PAINT                        M_DISP_WINDOW_PAINT
#define M_DISP_SELECT                                 M_SELECTED
#define M_AUTOMATIC                                   M_DEFAULT
#endif


/************************************************************************/
/* MdispControl() / MdispInquire() Values                               */
/************************************************************************/

#define M_FULL_SIZE                      0L
#define M_NORMAL_SIZE                    1L

#define M_BENCHMARK_IN_DEBUG_ON          0x00000001L
#define M_BENCHMARK_IN_DEBUG_OFF         0
#define M_BENCHMARK_IN_DEBUG_TRACE       0x00000002L
#define M_BENCHMARK_IN_DEBUG_NOTRACE     0
#define M_BENCHMARK_IN_DEBUG_ALLSIZE     0x00000004L
#define M_BENCHMARK_IN_DEBUG_CSTSIZE     0

#define M_DISPLAY_SCAN_LINE_START        0x00000000L
#define M_DISPLAY_SCAN_LINE_END          0xFFFFFFFFL

#define M_INFINITE                       0xFFFFFFFFL
#define M_SLAVE                          0L
#define M_MASTER                         1L

#define M_FILTER_LOW_PASS_TYPE_A         1L
#define M_FILTER_NOTCH                   2L
#define M_FILTER_EXTENDED                3L
#define M_FILTER_LOW_PASS_TYPE_B         4L
#define M_BYPASS                         5L
#define M_LOW_PASS_0                     M_FILTER_LOW_PASS_TYPE_A
#define M_LOW_PASS_1                     M_FILTER_LOW_PASS_TYPE_B
#define M_LOW_PASS_2                     M_FILTER_EXTENDED
#define M_NOTCH                          M_FILTER_NOTCH

/************************************************************************/
/* MdispLut()                                                           */
/************************************************************************/
#define M_PSEUDO                                      (M_LUT_OFFSET + 8L)


/************************************************************************/
/* MdispHook()                                                          */
/************************************************************************/

/* Defines for hook to modification to bitmap and window */
#define M_NOT_MODIFIED                0 /* No changed at all              */
#define M_MODIFIED_LUT                1 /* Disp lut is changed            */
#define M_MODIFIED_DIB                2 /* Disp buffer data is changed    */
#define M_MODIFIED_ZOOM               3 /* Disp is zoomed                 */
#define M_MODIFIED_PAN                4 /* Disp is panned                 */
#define M_MODIFIED_DIB_CREATION       5 /* Disp receives a new buffer ID  */
#define M_MODIFIED_DIB_DESTRUCTION    6 /* Disp receives a buffer ID 0    */
#define M_MODIFIED_WINDOW_CREATION    7 /* Wnd is created                 */
#define M_MODIFIED_WINDOW_DESTRUCTION 8 /* Wnd is destroyed               */
#define M_MODIFIED_WINDOW_LOCATION    9 /* Wnd size is changed            */
#define M_MODIFIED_WINDOW_OVERLAP    11 /* Wnd overlap is changed         */
#define M_MODIFIED_WINDOW_ICONIZED   12 /* Wnd is changed to iconic state */
#define M_MODIFIED_WINDOW_ZOOM       13 /* Wnd is zoomed                  */
#define M_MODIFIED_WINDOW_PAN        14 /* Wnd is panned                  */
#define M_MODIFIED_WINDOW_MENU       15 /* Wnd menu pulled-down           */
#define M_MODIFIED_WINDOW_PAINT      16 /* Wnd is painted with image      */
#define M_MODIFIED_WINDOW_ACTIVE     17 /* Wnd activation state changed   */
#define M_MODIFIED_WINDOW_ENABLE     18 /* Wnd enable state changed       */
#define M_MODIFIED_WINDOW_CLIP_LIST  19 /* Wnd clip list changed          */

/* M_MODIFIED_WINDOW_MENU modification hook defines */
#define M_MODIFIED_SYS_MENU            0x00100L
#define M_MODIFIED_APP_MENU            0x00200L
#define M_MODIFIED_USER_APP_MENU       0x10000L
#define M_MODIFIED_RESTORE_MENUITEM    0x00001L
#define M_MODIFIED_MOVE_MENUITEM       0x00002L
#define M_MODIFIED_SIZE_MENUITEM       0x00003L
#define M_MODIFIED_MINIMIZE_MENUITEM   0x00004L
#define M_MODIFIED_MAXIMIZE_MENUITEM   0x00005L
#define M_MODIFIED_CLOSE_MENUITEM      0x00006L
#define M_MODIFIED_TASKLIST_MENUITEM   0x00007L
#define M_MODIFIED_MENUBAR_MENUITEM    0x00008L
#define M_MODIFIED_TITLEOFF_MENUITEM   0x00009L
#define M_MODIFIED_ZOOMIN_MENUITEM     0x0000AL
#define M_MODIFIED_ZOOMOUT_MENUITEM    0x0000BL
#define M_MODIFIED_NOZOOM_MENUITEM     0x0000CL

/* M_MODIFIED_WINDOW_ACTIVE modification hook defines */
/* M_MODIFIED_WINDOW_ENABLE modification hook defines */
#define M_MODIFIED_STATE_FROM_WINDOW   0
#define M_MODIFIED_STATE_FROM_PARENT   0x00000010L
#define M_MODIFIED_OFF                 0
#define M_MODIFIED_ON                  0x00000001L

/* M_MODIFIED_WINDOW_CLIP_LIST modification hook defines */
/* M_MODIFIED_WINDOW_CLIP_LIST modification hook defines */
#define M_MODIFIED_ACCESS_RECTANGULAR_OFF 0
#define M_MODIFIED_ACCESS_RECTANGULAR_ON  0x00000001L
#define M_MODIFIED_ACCESS_OFF             0
#define M_MODIFIED_ACCESS_ON              0x00000002L
#define M_MODIFIED_ACCESS_COMMAND_PROMPT  0x00000004L

/* For hook after modification  */
#define M_HOOK_AFTER            0x10000000L
/* For hook before modification */
#define M_HOOK_BEFORE           0x20000000L
/* For buffer bitmap modification  */
#define M_HOOK_MODIFIED_DIB     1L
/* For disp window modification */
#define M_HOOK_MODIFIED_WINDOW  2L
/* For disp window modification */
#define M_HOOK_MESSAGE_LOOP     4L
/* For disp frame start */
#define M_FRAME_START           9L

/************************************************************************/
/* MdispOverlayKey()                                                    */
/************************************************************************/
#define M_KEY_ON_COLOR                                1L
#define M_KEY_OFF                                     2L
#define M_KEY_ALWAYS                                  3L


/************************************************************************/
/* MdigAlloc() defines                                                  */
/************************************************************************/
#define M_DIGITIZER_COLOR                             0x00000001L
#define M_DIGITIZER_MONO                              0x00000002L
#define M_USE_MEMORY_DCF                              0x00000010L
#define M_DCF_REALLOC                                 0x00000020L
#define M_DISPLAY_DIGITIZER                           0x00000040L
#define M_NO_INPUT_PRESENT                            0x00000080L
#define M_NO_FIELD_CHECK                              0x00000100L
#define M_SHARED_BANDWIDTH                            0x00000200L
#define M_1394_BANDWIDTH_FLAG                         0x00000800L
#define M_1394_BANDWIDTH(percent)   ( (((long) percent > 0) && ((long) percent <= 100)) ? (M_1394_BANDWIDTH_FLAG | ((long) percent)) : 0 )
#define M_EXCLUSIVE_BANDWIDTH                         M_DEFAULT
#define M_FAST                                        0x00040000L
#define M_RESTORE_DIG_LUT                             0x00080000L

/************************************************************************/
/* MdigInquire() / MdigControl() Types                                  */
/************************************************************************/
#define M_NO_INPUT_PRESENT                            0x00000080L

#define M_OWNER_APPLICATION                           1000L
#define M_OWNER_SYSTEM                                1001L
#define M_SIZE_X                                      1002L
#define M_SIZE_Y                                      1003L
#define M_SIZE_Z                                      1004L
#define M_SIZE_BAND                                   1005L
#define M_SIZE_BAND_LUT                               1006L
#define M_SIZE_BIT                                    1007L
#define M_TYPE                                        1008L
#define M_NUMBER                                      1009L
#define M_FORMAT                                      1010L
#define M_FORMAT_SIZE                                 1011L
#define M_INIT_FLAG                                   1012L
#define M_ATTRIBUTE                                   1013L
#define M_SIGN                                        1014L
#define M_LUT_ID                                      1015L
#define M_NATIVE_ID                                   1016L
#define M_NATIVE_CONTROL_ID                           1017L
#define M_COLOR_MODE                                  1018L
#define M_THREAD_PRIORITY                             1019L
#define M_OWNER_SYSTEM_TYPE                           1023L
#define M_LOW_LEVEL_API_OBJECT                        1024L
#define M_SERIAL_NUMBER                               2098L
#define M_SERIAL_NUMBER_0                             2099L
#define M_SERIAL_NUMBER_1                             2100L

#define M_CHANNEL                                     4000L
/* Reserve next 1 bits                         from  (4000L | 0x00800000L)*/
#define M_CHANNEL_NUM                                 4001L
#define M_BASE_BLACK_REF                              4002L
#define M_BLACK_REF                                   4003L
/* Reserve next 8 bits                         from  (4003L | 0x00000000L)*/
/*                                                   (4003L | 0x10000000L)*/
/*                                                   (4003L | 0x20000000L)*/
/*                                                   (4003L | 0x40000000L)*/
/*                                                   (4003L | 0x80000000L)*/
/*                                                   (4003L | 0x01000000L)*/
/*                                                   (4003L | 0x02000000L)*/
/*                                                   (4003L | 0x04000000L)*/
/*                                             to    (4003L | 0x08000000L)*/
#define M_WHITE_REF                                   4005L
/* Reserve next 8 bits                         from  (4005L | 0x00000000L)*/
/*                                                   (4005L | 0x10000000L)*/
/*                                                   (4005L | 0x20000000L)*/
/*                                                   (4005L | 0x40000000L)*/
/*                                                   (4005L | 0x80000000L)*/
/*                                                   (4005L | 0x01000000L)*/
/*                                                   (4005L | 0x02000000L)*/
/*                                                   (4005L | 0x04000000L)*/
/*                                             to    (4005L | 0x08000000L)*/
#define M_HUE_REF                                     4006L
#define M_SATURATION_REF                              4007L
#define M_BRIGHTNESS_REF                              4008L
#define M_CONTRAST_REF                                4009L
#define M_GRAB_SCALE                                  4010L
#define M_GRAB_SCALE_X                                4011L
#define M_GRAB_SCALE_Y                                4012L
#define M_GRAB_SUBSAMPLE                              4013L
#define M_GRAB_SUBSAMPLE_X                            4014L
#define M_GRAB_SUBSAMPLE_Y                            4015L
#define M_GRAB_MODE                                   4016L
#define M_GRAB_FRAME_NUM                              4017L
#define M_GRAB_FIELD_NUM                              4018L
#define M_GRAB_INPUT_GAIN                             4019L    // dependent of M_LUMINANCE and M_CHROMINANCE
#define M_INPUT_MODE                                  4020L
#define M_SCAN_MODE                                   4021L
#define M_SOURCE_SIZE_X                               4022L
#define M_SOURCE_SIZE_Y                               4023L
#define M_SOURCE_OFFSET_X                             4024L
#define M_SOURCE_OFFSET_Y                             4025L
#define M_INTERNAL_SOURCE_SIZE_X                      4026L
#define M_INTERNAL_SOURCE_SIZE_Y                      4027L
#define M_INTERNAL_SOURCE_OFFSET_X                    4028L
#define M_INTERNAL_SOURCE_OFFSET_Y                    4029L
#define M_GRAB_END_HANDLER_PTR                        4030L
#define M_GRAB_END_HANDLER_USER_PTR                   4032L
#define M_GRAB_START_HANDLER_PTR                      4033L
#define M_GRAB_START_HANDLER_USER_PTR                 4035L
#define M_GRAB_FIELD_END_HANDLER_PTR                  4036L
#define M_GRAB_FIELD_END_HANDLER_USER_PTR             4037L
#define M_GRAB_FIELD_END_ODD_HANDLER_PTR              4038L
#define M_GRAB_FIELD_END_ODD_HANDLER_USER_PTR         4039L
#define M_GRAB_FIELD_END_EVEN_HANDLER_PTR             4040L
#define M_GRAB_FIELD_END_EVEN_HANDLER_USER_PTR        4041L
#define M_GRAB_FRAME_END_HANDLER_PTR                  4042L
#define M_GRAB_FRAME_END_HANDLER_USER_PTR             4043L
#define M_GRAB_FRAME_START_HANDLER_PTR                4044L
#define M_GRAB_FRAME_START_HANDLER_USER_PTR           4045L
#define M_FIELD_START_HANDLER_PTR                     4046L
#define M_FIELD_START_HANDLER_USER_PTR                4047L
#define M_FIELD_START_ODD_HANDLER_PTR                 4048L
#define M_FIELD_START_ODD_HANDLER_USER_PTR            4049L
#define M_FIELD_START_EVEN_HANDLER_PTR                4050L
#define M_FIELD_START_EVEN_HANDLER_USER_PTR           4051L
#define M_SCALING_Y_AVAILABLE                         4052L
#define M_GRAB_TRIGGER_SOURCE                         4053L
#define M_GRAB_TRIGGER_MODE                           4054L
#define M_NATIVE_CAMERA_ID                            4060L
#define M_VCR_INPUT_TYPE                              4061L
#define M_CLIP_SRC_SUPPORTED                          4062L
#define M_CLIP_DST_SUPPORTED                          4063L
#define M_HOOK_FUNCTION_SUPPORTED                     4064L
#define M_GRAB_WINDOW_RANGE_SUPPORTED                 4065L
#define M_GRAB_SCALE_X_SUPPORTED                      4066L
#define M_GRAB_SCALE_Y_SUPPORTED                      4067L
#define M_GRAB_8_BITS_SUPPORTED                       4068L
#define M_GRAB_15_BITS_SUPPORTED                      4069L
#define M_GRAB_32_BITS_SUPPORTED                      4070L
#define M_GRAB_EXTRA_LINE                             4071L
#define M_GRAB_ABORT                                  4072L
#define M_GRAB_DESTRUCTIVE_IN_PROGRESS                4073L
#define M_GRAB_START_MODE                             4074L
#define M_GRAB_WINDOW_RANGE                           4075L
#define M_INPUT_SIGNAL_PRESENT                        4078L
#define M_INPUT_SIGNAL_SOURCE                         4079L
#define M_FIELD_START_THREAD_ID                       4080L
#define M_GRAB_FIELD_END_ODD_THREAD_ID                4081L
#define M_GRAB_FIELD_END_EVEN_THREAD_ID               4082L
#define M_FIELD_START_THREAD_HANDLE                   4083L
#define M_GRAB_FIELD_END_ODD_THREAD_HANDLE            4084L
#define M_GRAB_FIELD_END_EVEN_THREAD_HANDLE           4085L
#define M_FORMAT_UPDATE                               4086L
#define M_USER_BIT                                    4087L
/* Reserve next 31 values                      from   4088L*/
/*                                             to     4118L*/
#define M_GRAB_FAIL_CHECK                             4120L
#define M_GRAB_FAIL_STATUS                            4121L
#define M_GRAB_FAIL_RETRY_NUMBER                      4122L
#define M_GRAB_ON_ONE_LINE                            4123L
#define M_GRAB_WRITE_FORMAT                           4124L
#define M_GRAB_LUT_PALETTE                            4125L
#define M_GRAB_HALT_ON_NEXT_FIELD                     4126L
#define M_GRAB_TIMEOUT                                4127L
#define M_GRAB_IN_PROGRESS                            4128L
#define M_FIELD_START_HOOK_WHEN_GRAB_ONLY             4129L
#define M_SOUND_VOLUME_REF                            4130L
#define M_SOUND_VOLUME_RIGHT_REF                      4131L
#define M_SOUND_VOLUME_LEFT_REF                       4132L
#define M_SOUND_TYPE_REF                              4133L
#define M_SOUND_TYPE_STATUS                           4134L
#define M_SOUND_BASS_REF                              4135L
#define M_SOUND_TREBLE_REF                            4136L
#define M_EXTERNAL_CHROMINANCE                        4137L
#define M_TUNER_FREQUENCY                             4138L
#define M_TUNER_STANDARD                              4139L
#define M_CLOCK_NOT_ALWAYS_VALID                      4140L
#define M_GRAB_LINESCAN_MODE                          4141L
#define M_GRAB_PERIOD                                 4142L
#define M_OVERRIDE_ROUTER                             4143L
#define M_GRAB_EXPOSURE                               4150L
/* Reserve next 8 values                       from   4151L*/
/*                                             to     4158L*/
#define M_GRAB_EXPOSURE_SOURCE                        4160L
/* Reserve next 8 values                       from   4161L*/
/*                                             to     4168L*/
#define M_GRAB_EXPOSURE_MODE                          4170L
/* Reserve next 8 values                       from   4171L*/
/*                                             to     4178L*/
#define M_GRAB_EXPOSURE_TIME                          4180L
/* Reserve next 8 values                       from   4181L*/
/*                                             to     4188L*/
#define M_GRAB_EXPOSURE_TIME_DELAY                    4190L
/* Reserve next 8 values                       from   4191L*/
/*                                             to     4198L*/
#define M_GRAB_TRIGGER                                4200L
/* Reserve next 8 values                       from   4201L*/
/*                                             to     4208L*/
#define M_GRAB_EXPOSURE_BYPASS                        4210L
#define M_DCF_REALLOC_HANDLER_PTR                     4211L
#define M_DCF_REALLOC_HANDLER_USER_PTR                4212L
#define M_USER_IN_FORMAT                              4213L
#define M_USER_OUT_FORMAT                             4214L
#define M_GRAB_RESTRICTION_CHECK                      4215L
#define M_LAST_GRAB_BUFFER                            4216L
#define M_NATIVE_LAST_GRAB_OSB_ID                     4217L
#define M_SYNCHRONIZE_ON_STARTED                      4218L
#define M_GRAB_WAIT                                   4219L
#define M_GRAB_FIELD_START_HANDLER_PTR                4220L
#define M_GRAB_FIELD_START_HANDLER_USER_PTR           4221L
#define M_GRAB_FIELD_START_ODD_HANDLER_PTR            4222L
#define M_GRAB_FIELD_START_ODD_HANDLER_USER_PTR       4223L
#define M_GRAB_FIELD_START_EVEN_HANDLER_PTR           4224L
#define M_GRAB_FIELD_START_EVEN_HANDLER_USER_PTR      4225L
#define M_GRAB_16_BITS_SUPPORTED                      4226L
#define M_GRAB_24_BITS_SUPPORTED                      4227L
#define M_INPUT_SIGNAL_HSYNC_LOCK                     4228L
#define M_GRAB_BLOCK_SIZE                             4229L
#define M_GRAB_DIRECTION_X                            4230L
#define M_GRAB_DIRECTION_Y                            4231L
#define M_GRAB_FREQ_MAX                               4232L
#define M_GRAB_THREAD_HANDLE                          4233L
#define M_GRAB_THREAD_ID                              4234L
#define M_GRAB_START_THREAD_HANDLE                    4235L
#define M_GRAB_START_THREAD_ID                        4236L
#define M_GRAB_END_THREAD_HANDLE                      4237L
#define M_GRAB_END_THREAD_ID                          4238L
#define M_GRAB_PATH_OVERRIDE                          4239L
#define M_GRAB_PATH_OVERRIDE_DCF                      4240L
#define M_GRAB_PATH_PCI                               4241L
#define M_GRAB_AUTOMATIC_INPUT_GAIN                   4242L
#define M_GRAB_DISPLAY_SCALER_QUALITY                 4243L
#define M_GRAB_VALID                                  4244L
#define M_VIDCAP_SOURCE_DLG                           4245L
#define M_VIDCAP_FORMAT_DLG                           4246L
#define M_VIDCAP_DISPLAY_DLG                          4247L
#define M_GRAB_FIELD_START_THREAD_HANDLE              4248L
#define M_GRAB_FIELD_START_THREAD_ID                  4249L
#define M_GRAB_EXPOSURE_TRIGGER_MODE                  4250L
/* Reserve next 8 values                       from   4251L*/
/*                                             to     4258L*/
#define M_GRAB_FIELD_END_THREAD_HANDLE                4259L
#define M_GRAB_FIELD_END_THREAD_ID                    4260L
#define M_GRAB_FRAME_END_THREAD_HANDLE                4261L
#define M_GRAB_FRAME_END_THREAD_ID                    4262L
#define M_SET_VCOUNT                                  4263L
#define M_JPEG_ENCODING_MODE                          4264L
#define M_JPEG_DECODING_MODE                          4265L
#define M_JPEG_MARKERS_ENABLE                         4266L
#define M_JPEG_NUMBER_OF_SCAN_ENCODED                 4267L
#define M_JPEG_INPUT_COLOR_MODE                       4268L
#define M_JPEG_OUTPUT_COLOR_MODE                      4269L
#define M_JPEG_IMAGE_FORMAT                           4270L
#define M_JPEG_NAX                                    4271L
#define M_JPEG_NAY                                    4272L
#define M_JPEG_PAX                                    4273L
#define M_JPEG_PAY                                    4274L
#define M_JPEG_AUTO_START_MODE                        4275L
#define M_JPEG_COMPRESS_MODE                          4276L
#define M_JPEG_HW_PROG_MODE                           4277L
#define M_HOOK_MASTER_THREAD_HANDLE                   4278L
#define M_HOOK_MASTER_THREAD_ID                       4279L
#define M_GRAB_PATH_RR                                4280L
#define M_PIXCLK_JPEG_SIGNAL_PRESENT                  4281L
#define M_GRAB_VM                                     4282L
#define M_GARBAGE_UV_ADDRESS                          4283L
#define M_SET_EXPOSURE_ENABLE                         4290L
/* Reserve next 8 values                       from   4291L*/
/*                                             to     4298L*/
#define M_INPUT_SIGNAL_COLOR_LOCK                     4399L

#define M_JPEG_FIRST_FIELD_SIZEBYTE                   4301L
#define M_JPEG_SECOND_FIELD_SIZEBYTE                  4302L
#define M_JPEG_OFFSET_X                               4303L
#define M_JPEG_OFFSET_Y                               4304L
#define M_CURRENT_GRAB_BUFFER_HOST_ADDRESS            4305L
#define M_CURRENT_GRAB_BUFFER_PHYSICAL_ADDRESS        4306L
#define M_RESET_CONTINUOUS_GRABBER                    4307L
#define M_TIMER_INTERRUPT                             4308L
#define M_TIMER_INTERRUPT_LENGHT                      4309L
#define M_TIMER_SET_INTERRUPT                         4310L
#define M_GRAB_SAMPLING_POSITION                      4311L
#define M_JPEG_DMA_TRANSFER                           4312L
#define M_GRAB_FRAME_START_THREAD_HANDLE              4313L
#define M_GRAB_FRAME_START_THREAD_ID                  4314L
#define M_INTERNAL_GRAB_BUFFERS_NB                    4315L
#define M_INTERNAL_GRAB_BUFFERS_ID                    4316L
#define M_INTERNAL_GRAB_BUFFERS_FORMAT                4317L
#define M_KS0127_REV_ID                               4318L
#define M_DECODER_REV_ID                              M_KS0127_REV_ID
#define M_GRAB_SCALE_MODE                             4319L
#define M_GRAB_SCALE_MODE_X                           4320L
#define M_GRAB_SCALE_MODE_Y                           4321L
#define M_START_THREAD_HANDLE                         4322L
#define M_START_THREAD_ID                             4323L
#define M_SOURCE_COMPENSATION                         4324L
#define M_GRAB_COLOR                                  4325L
#define M_SYNCHRONIZE_CHANNEL                         4326L
#define M_ODD_EVEN_CORRECTION                         4327L
#define M_POLLING_FOR_END_OF_XFER                     4328L
#define M_FORCE_PSEUDO_LIVE_GRAB                      4329L
/* Free to use                                 from   4330*/
/*                                             to     4339*/
#define M_GRAB_EXPOSURE_CLOCK_SOURCE                  4340L
/* Reserve next 8 values                       from   4341L*/
/*                                             to     4348L*/
#define M_GRAB_EXPOSURE_CLOCK_FREQUENCY               4350L
/* Reserve next 8 values                       from   4351L*/
/*                                             to     4358L*/
#define M_HOOK_FOR_PSEUDO_LIVE_GRAB                   4360L
#define M_YIELD_FOR_END_OF_XFER                       4361L
#define M_GRAB_SCALE_QUALITY                          4362L
#define M_USER_BIT_INQUIRE_START                      4363L
#define M_USER_BIT                                    4087L
/* Reserve next 31 values                      from   4088L*/
/*                                             to     4118L*/
#define M_USER_BIT_COUNT                              4364L
#define M_USER_BIT_OPTOMODULE                         4365L
#define M_USER_BIT_INQUIRE_END                        4366L

#define M_GRAB_QUEUE_SIZE                             4369L
#define M_SECONDARY_GRAB_BUFFER                       4370L
#define M_GRAB_FRAME_END_TIME_STAMP_BUFFER            4371L
#define M_GRAB_BUF_MODIFIED                           4372L
#define M_RGB_PIXEL_SWAP                              4373L
#define M_PREFERRED_BUFFER_FORMAT                     4374L
#define M_LAST_GRAB_BUFFER_INDEX                      4375L
#define M_SYNCHRONIZE_GRAB_WITH_DISPLAY_REFRESH       4376L

// Map of UART defines
#define M_UART_PARITY                                 5001L
#define M_UART_STOP_BITS                              5002L
#define M_UART_DATA_LENGTH                            5003L
#define M_UART_SPEED                                  5004L
#define M_UART_WRITE_CHAR                             5005L
#define M_UART_READ_CHAR                              5006L
#define M_UART_DATA_PENDING                           5007L
#define M_UART_WRITE_STRING                           5008L
#define M_UART_WRITE_STRING_LENGTH                    5009L
#define M_UART_READ_STRING                            5010L
#define M_UART_READ_STRING_LENGTH                     5011L
#define M_UART_READ_STRING_MAXIMUM_LENGTH             5012L
#define M_UART_STRING_DELIMITER                       5013L
#define M_UART_TIMEOUT                                5014L
#define M_UART_ERROR_MESSAGE                          5015L // internal use only
#define M_UART_OUTPUT                                 5016L

#define M_UART_THREAD_HANDLE                          5017L
#define M_UART_THREAD_ID                              5018L
#define M_UART_DATA_RECEIVED_HANDLER_PTR              5019L
#define M_UART_DATA_RECEIVED_HANDLER_USER_PTR         5020L

/* defines for 1394*/
#define M_MIN_VALUE                                   2L
#define M_MAX_VALUE                                   1L

#define M_BRIGHTNESS                                  5100L/* Reserve all values between 5100 and 5159*/
#define M_AUTO_EXPOSURE                               5104L
#define M_SHARPNESS                                   5108L
#define M_WHITE_BALANCE                               5112L
#define M_HUE                                   0x00008000L
#define M_SATURATION                                M_GREEN
#define M_GAMMA                                       5116L
#define M_SHUTTER                                     5120L
#define M_GAIN                                        5124L
#define M_IRIS                                        5128L
#define M_FOCUS                                       5132L
#define M_TEMPERATURE                                 5136L
#define M_TRIGGER                                     5140L
#define M_ZOOM                                        5144L
#define M_PAN                                         5148L
#define M_TILT                                        5152L
#define M_OPTICAL_FILTER                              5156L
#define M_CAPTURE_SIZE                                5160L
#define M_CAPTURE_QUALITY                             5164L
#define M_WHITE_BALANCE_U                             5168L
#define M_WHITE_BALANCE_V                             5172L
#define M_TARGET_TEMPERATURE                          5176L
/* Reserve next 3 values                       from   5177L*/
/*                                             to     5179L*/
#define M_FORMAT_SUPPORTED                            5180L
#define M_FORMAT_SUPPORTED_NUM                        5181L
#define M_FORMAT_SUPPORTED_LENGTH                     5182L
#define M_TRIGGER_SUPPORTED                           5183L
#define M_INPUT_LOW_PASS_FILTER                       5184L
#define M_PIXCLK_FREQ                                 5185L
#define M_INPUT_FILTER                                5186L
#define M_DIGITIZER_CONTROL_LOG                       5187L
#define M_TARGET_BUFFER_UPDATE                        5188L
#define M_DUMP_REGISTERS                              5189L
#define M_FORMAT7_TILE_SIZE_X                         5190L
#define M_FORMAT7_TILE_SIZE_Y                         5191L

/* Reserve 3 values for M_SATURATION           from   8192*/
/*                                             to     8195*/

/* defines for camera link*/
#define M_CAMERALINK_CC1_SOURCE                       5200L
#define M_CAMERALINK_CC2_SOURCE                       5201L
#define M_CAMERALINK_CC3_SOURCE                       5202L
#define M_CAMERALINK_CC4_SOURCE                       5203L

/* defines for channel switch lock mechanism*/
#define M_CAMERA_LOCK                                 5300L
#define M_CAMERA_COLOR_LOCK                           5301L
#define M_CAMERA_LOCK_SENSITIVITY                     5302L
#define M_CAMERA_UNLOCK_SENSITIVITY                   5303L
#define M_CAMERA_LOCKED                               5304L
#define M_CAMERA_COLOR_LOCKED                         5305L
#define M_CAMERA_LOCK_MODE                            5306L

#define M_CAMERA_LOCK_HANDLER_PTR                     5307L
#define M_CAMERA_LOCK_HANDLER_USER_PTR                5308L
#define M_CAMERA_LOCK_THREAD_ID                       5309L
#define M_CAMERA_LOCK_THREAD_HANDLE                   5310L

/* defines for camera detect */
#define M_CAMERA_PRESENT_HANDLER_PTR                  5311L
#define M_CAMERA_PRESENT_HANDLER_USER_PTR             5312L
#define M_CAMERA_PRESENT_THREAD_ID                    5313L
#define M_CAMERA_PRESENT_THREAD_HANDLE                5314L
#define M_CAMERA_PRESENT                              5315L
#define M_CAMERA_PRESENT_SENSITIVITY                  5316L

#define M_WRITE_GRAB_VALIDATION_TAG                   5317L

#define M_INFO_FORMAT                                 5318L
#define M_HV_RESET                                    5319L
#define M_FORCE_INTERNAL_GRAB_BUFFER                  5320L
#define M_INITIALIZATION_DELAY                        5321L
#define M_SELECTED_FRAME_RATE                         5322L
#define M_VENDOR                                      5323L
#define M_VENDOR_LENGTH                               5324L
#define M_MODEL_LENGTH                                5325L


#define M_GRAB_LL_SEQ_CONTEXT                         5330L

#define M_HOOK_EVENT_BACKDOOR_INTERNAL                0x4444L // 17476
#define M_HOOK_CANCEL_EVENT_BACKDOOR_INTERNAL         0x4464L // 17508

/* Reserve 3 values for M_HUE                  from   32768*/
/*                                             to     32771*/
#define M_MODEL                                      0X10000L

#define M_START_REGISTER_ADDRESS                   0xF0000000
/*Reserve the values between 0xF000000 and 0xF0FFFFFF for 1394*/
#define M_END_REGISTER_ADDRESS                     0xF0FFFFFF


// !!! MAP FOR OLD DEFINES
#if OldDefinesSupport
#define M_DIG_TYPE                                    M_TYPE
#define M_DIG_NUMBER                                  M_NUMBER
#define M_DIG_FORMAT                                  M_FORMAT
#define M_DIG_INIT_FLAG                               M_INIT_FLAG
#define M_DIG_CHANNEL_NUM                             M_CHANNEL_NUM
#define M_DIG_LUT                                     M_LUT_ID
#define M_DIG_REF_BLACK                               M_BLACK_REF
#define M_DIG_REF_WHITE                               M_WHITE_REF
#define M_DIG_REF_HUE                                 M_HUE_REF
#define M_DIG_REF_SATURATION                          M_SATURATION_REF
#define M_DIG_REF_BRIGHTNESS                          M_BRIGHTNESS_REF
#define M_DIG_REF_CONTRAST                            M_CONTRAST_REF
#define M_DIG_BLACK_REF                               M_BLACK_REF
#define M_DIG_WHITE_REF                               M_WHITE_REF
#define M_DIG_HUE_REF                                 M_HUE_REF
#define M_DIG_SATURATION_REF                          M_SATURATION_REF
#define M_DIG_BRIGHTNESS_REF                          M_BRIGHTNESS_REF
#define M_DIG_CONTRAST_REF                            M_CONTRAST_REF
#define M_DIG_INPUT_MODE                              M_INPUT_MODE
#define M_DIG_GRAB_SCALE                              M_GRAB_SCALE
#define M_DIG_GRAB_SCALE_X                            M_GRAB_SCALE_X
#define M_DIG_GRAB_SCALE_Y                            M_GRAB_SCALE_Y
#define M_DIG_GRAB_SUBSAMPLE                          M_GRAB_SUBSAMPLE
#define M_DIG_GRAB_SUBSAMPLE_X                        M_GRAB_SUBSAMPLE_X
#define M_DIG_GRAB_SUBSAMPLE_Y                        M_GRAB_SUBSAMPLE_Y
#define M_DIG_GRAB_MODE                               M_GRAB_MODE
#define M_DIG_GRAB_FRAME_NUM                          M_GRAB_FRAME_NUM
#define M_DIG_GRAB_FIELD_NUM                          M_GRAB_FIELD_NUM
#define M_DIG_SOURCE_SIZE_X                           M_SOURCE_SIZE_X
#define M_DIG_SOURCE_SIZE_Y                           M_SOURCE_SIZE_Y
#define M_DIG_SOURCE_OFFSET_X                         M_SOURCE_OFFSET_X
#define M_DIG_SOURCE_OFFSET_Y                         M_SOURCE_OFFSET_Y
#define M_DIG_USER_BIT                                M_USER_BIT
#define M_DIG_INPUT_SIGNAL_PRESENT                    M_INPUT_SIGNAL_PRESENT
#define M_DIG_INPUT_SIGNAL_SOURCE                     M_INPUT_SIGNAL_SOURCE
#define M_DIG_SOUND_VOLUME_REF                        M_SOUND_VOLUME_REF
#define M_DIG_SOUND_VOLUME_RIGHT_REF                  M_SOUND_VOLUME_RIGHT_REF
#define M_DIG_SOUND_VOLUME_LEFT_REF                   M_SOUND_VOLUME_LEFT_REF
#define M_DIG_SOUND_TYPE_REF                          M_SOUND_TYPE_REF
#define M_DIG_SOUND_BASS_REF                          M_SOUND_BASS_REF
#define M_DIG_SOUND_TREBLE_REF                        M_SOUND_TREBLE_REF
#define M_DIG_FORMAT_UPDATE                           M_FORMAT_UPDATE
#define M_DIG_CLIP_SRC_SUPPORTED                      M_CLIP_SRC_SUPPORTED
#define M_DIG_CLIP_DST_SUPPORTED                      M_CLIP_DST_SUPPORTED
#define M_DIG_HOOK_FUNCTION_SUPPORTED                 M_HOOK_FUNCTION_SUPPORTED
#define M_GRAB_INTERLACED_MODE                        M_SCAN_MODE
#define M_GRAB_THREAD_PRIORITY                        M_THREAD_PRIORITY
#define M_HOOK_PRIORITY                               M_THREAD_PRIORITY
#define M_GRAB_WINDOWS_RANGE                          M_GRAB_WINDOW_RANGE
#define M_GRAB_WINDOWS_RANGE_SUPPORTED                M_GRAB_WINDOW_RANGE_SUPPORTED

#define M_HW_TRIGGER                                  M_HARDWARE_PORT0
#define M_SW_TRIGGER                                  M_SOFTWARE
#define M_VSYNC_TRIGGER                               M_VSYNC
#define M_HSYNC_TRIGGER                               M_HSYNC
#define M_DIG_CHANNEL                                 M_CHANNEL

#endif

// List of defines for CLLjpegControl
//==============================================================================
#define M_LOSSY                                          1L
#define M_AUTO_BIT_RATE_CONTROL                          2L
#define M_STATISTICAL                                    3L
#define M_BIT_RATE_CONTROL                               4L
#define M_TABLES_ONLY                                    5L
#define M_TABLES_PRELOAD                                 6L
#define M_LOSSLESS                                       7L
#define M_FAST_PREVIEW                                   8L

#define M_APP                                         0x00000001L
#define M_COM                                         0x00000002L
#define M_DRI                                         0x00000004L
#define M_DQT                                         0x00000008L
#define M_DHT                                         0x00000010L
#define M_DNL                                         0x00000020L
#define M_DQTI                                        0x00000040L
#define M_DHTI                                        0x00000080L

#define M_NSCN_1                                         0L
#define M_NSCN_2                                         1L
#define M_NSCN_3                                         2L
#define M_NSCN_4                                         3L
#define M_NSCN_5                                         4L
#define M_NSCN_6                                         5L
#define M_NSCN_7                                         6L
#define M_NSCN_8                                         7L

/* Inquire Values */
#define M_DIGITAL                                     0L
#define M_ANALOG                                      1L
#define M_INTERLACE                                   0L
#define M_PROGRESSIVE                                 1L
#define M_LINESCAN                                    2L
#define M_ACTIVATE                                    1L

/* Inquire Values for the color mode */
#define M_MONOCHROME                                  0L
#define M_COMPOSITE                                   1L
#define M_RGB                                         8L
#define M_YUV                                         4L
#define M_EXTERNAL_CHROMINANCE                        4137L
#define M_MONO8_VIA_RGB                               M_MONO32
#define M_SEPARATE                                    0x8000L

/************************************************************************/
/* Board types                                                          */
/************************************************************************/
#define M_BOARD_TYPE_MASK                             0x000000FFL

// Pulsar board type
#define M_PULSAR_XXX                                  19L
#define M_PULSAR                                      20L
#define M_PULSAR_WITH_RS422                           21L
#define M_PULSAR_RS422_JIG                            22L

// Module type
#define M_DIGITAL_MODULE                              0x0100L
#define M_LVDS_MODULE                                 M_RS422_MODULE
#define M_COMPRESSION_MODULE                          0x0200L
#define M_DAC_MODULE                                  0x0400L

// Corona board type
#define M_CORONA                                      20L
#define M_CORONA_LC                                   21L
#define M_CORONA_VIA                                  22L
#define M_CORONA_RR                                   23L
#define M_METEOR_II_MC                                24L
#define M_CORONA_II                                   25L
#define M_METEOR_II                                   27L

#define M_METEOR_II_STD                               M_METEOR_II
#define M_CORONA_WITH_DIG_MODULE                      (M_CORONA|M_DIGITAL_MODULE)
#define M_CORONA_II_WITH_DIG_MODULE                   (M_CORONA_II|M_DIGITAL_MODULE)
#define M_METEOR_II_WITH_COMPRESSION_MODULE           (M_METEOR_II|M_COMPRESSION_MODULE)
#define M_METEOR_II_STD_WITH_COMPRESSION_MODULE       (M_METEOR_II_STD|M_COMPRESSION_MODULE)
#define M_METEOR_II_MC_WITH_COMPRESSION_MODULE        (M_METEOR_II_MC|M_COMPRESSION_MODULE)

// Meteor board type
#define M_METEOR                                      20L
#define M_METEOR_TV                                   21L
#define M_METEOR_RGB                                  22L
#define M_METEOR_PRO                                  23L
#define M_METEOR_TV_PRO                               24L
#define M_METEOR_RGB_PRO                              25L

// Genesis board type
#define M_GENESIS                                     30L
#define M_GENESIS_PRO                                 31L
#define M_GENESIS_LC                                  32L
#define M_METEOR_II_DIG                               33L
#define M_GENESIS_PLUS                                34L
#define M_METEOR_II_CL                                35L
#define M_METEOR_II_DIG_WITH_MJPEG_MODULE             (M_METEOR_II_DIG|M_COMPRESSION_MODULE)
#define M_GENESIS_WITH_DAC_MODULE                     (M_GENESIS|M_DAC_MODULE)
#define M_GENESIS_LC_WITH_DAC_MODULE                  (M_GENESIS_LC|M_DAC_MODULE)

// MJPEG/JPEG module board type (internal use only)
#define M_MJPEG                                       1L
#define M_JPEG                                        5L
#define M_DEVICE_MJPEG                                M_MJPEG // with interlaced/progressive compression/decompression
#define M_DEVICE_JPEG                                 M_JPEG // with interlaced/progressive compression/decompression
                                                             // and progressive compression from interlaced timings
// Orion board type
#define M_ORION                                       40L
#define M_ORION_4SIGHT_II_STD                         41L
#define M_ORION_4SIGHT_II_RGB                         42L
#define M_ORION_4SIGHT_II_DUAL                        43L

// 1394 board type
#define M_METEOR_II_1394                              50L
#define M_1394_OHCI                                   51L
#define M_1394_PCILYNX                                52L
#define M_NON_MATROX_OHCI_BOARD                       51L

//Cronos board type
#define M_CRONOS                                      60L

//Cronos Plusboard type
#define M_CRONOSPLUS                                  70L

// !!! MAP FOR OLD DEFINES
#if OldDefinesSupport
#define M_MJPEG_MODULE                                M_COMPRESSION_MODULE
#define M_RS422_MODULE                                M_DIGITAL_MODULE
#define M_METEOR_II_WITH_MJPEG_MODULE                 M_METEOR_II_WITH_COMPRESSION_MODULE
#define M_METEOR_II_STD_WITH_MJPEG_MODULE             M_METEOR_II_STD_WITH_COMPRESSION_MODULE
#define M_METEOR_II_MC_WITH_MJPEG_MODULE              M_METEOR_II_MC_WITH_COMPRESSION_MODULE
#endif

/************************************************************************/
/* MdigControl() / MdigInquire() Values                                 */
/************************************************************************/

#define M_TIMER1                                      1L
#define M_TIMER2                                      2L
#define M_TIMER3                                      3L
#define M_TIMER4                                      4L
#define M_TIMER5                                      5L
#define M_TIMER6                                      6L
#define M_TIMER7                                      7L
#define M_TIMER8                                      8L

#define M_LOW                                         1L
#define M_HIGH                                        3L

#define M_ARM_CONTINUOUS                              9L
#define M_ARM_MONOSHOT                                10L
#define M_ARM_RESET                                   11L
#define M_EDGE_RISING                                 12L
#define M_EDGE_FALLING                                13L
#define M_LEVEL_LOW                                   14L
#define M_LEVEL_HIGH                                  15L
#define M_HARDWARE_PORT0                              16L
#define M_HARDWARE_PORT1                              17L
#define M_HARDWARE_PORT_CAMERA                        18L
#define M_START_EXPOSURE                              19L
#define M_SOFTWARE                                    20L
#define M_USER_DEFINED                                21L
#define M_HSYNC                                       22L
#define M_VSYNC                                       23L
#define M_HARDWARE_PORT2                              24L
#define M_HARDWARE_PORT3                              25L
#define M_SYSCLK                                      26L
#define M_PIXCLK                                      27L
#define M_URGENT                                      28L
#define M_NOW                                         29L
#define M_FRAME                                       30L

#define M_FILL_DESTINATION                            -1
#define M_FILL_DISPLAY                                -2
#define M_SYNCHRONOUS                                 1L
#define M_ASYNCHRONOUS                                2L
#define M_ASYNCHRONOUS_QUEUED                         3L

#define M_LUT_PALETTE0                                0L
#define M_LUT_PALETTE1                                1L
#define M_LUT_PALETTE2                                2L
#define M_LUT_PALETTE3                                3L
#define M_LUT_PALETTE4                                4L
#define M_LUT_PALETTE5                                5L
#define M_LUT_PALETTE6                                6L
#define M_LUT_PALETTE7                                7L

#define M_GAIN0                                       10L
#define M_GAIN1                                       11L
#define M_GAIN2                                       12L
#define M_GAIN3                                       13L
#define M_GAIN4                                       14L

#define M_TTL                                         1L
#define M_RS422                                       2L
#define M_LVDS                                        M_RS422

#define M_ENABLE                                      -9997L
#define M_FINAL_GRAB                                  -9998L
#define M_DISABLE                                     -9999L

// Uart parity values
#define M_ODD                                         1L
#define M_EVEN                                        2L

// Uart output mode
#define M_RS232                                       1L
#define M_RS485                                       2L


/************************************************************************/
/* MdigControl(): Grab VM stream ID                                     */
/************************************************************************/
#define M_VM_STREAM_ID_0                              0L
#define M_VM_STREAM_ID_1                              1L
#define M_VM_STREAM_ID_2                              2L
#define M_VM_STREAM_ID_3                              3L
#define M_VM_STREAM_ID_4                              4L
#define M_VM_STREAM_ID_5                              5L
#define M_VM_STREAM_ID_6                              6L
#define M_VM_STREAM_ID_7                              7L
#define M_VM_STREAM_ID_8                              8L
#define M_VM_STREAM_ID_9                              9L
#define M_VM_STREAM_ID_10                            10L
#define M_VM_STREAM_ID_11                            11L
#define M_VM_STREAM_ID_12                            12L
#define M_VM_STREAM_ID_13                            13L
#define M_VM_STREAM_ID_14                            14L


/************************************************************************/
/* MdigChannel()                                                        */
/************************************************************************/
#define M_TUNER_CHANNEL                               0x00100000L
/* Reserve next 126 values (M_TUNER_CHANNEL +   0L)   0x00100000L*/
/*                         (M_TUNER_CHANNEL + 126L)   0x0010007EL*/
#define M_TUNER_BAND                                  0x00200000L
/* Reserve next 2   values (M_TUNER_BAND | M_REGULAR) 0x00220000L*/
/*                         (M_TUNER_BAND | M_CABLE  ) 0x00220001L*/
#define M_DEFAULT                                     0x10000000L
#define M_CH0                                         0x20000000L
#define M_CH1                                         0x40000000L
#define M_CH2                                         0x80000000L
#define M_CH3                                         0x01000000L
#define M_CH4                                         0x02000000L
#define M_CH5                                         0x04000000L
#define M_CH6                                         0x08000000L
#define M_CH7                                         0x00200000L
#define M_CH8                                         0x00010000L
#define M_CH9                                         0x00020000L
#define M_CH10                                        0x00040000L
#define M_CH11                                        0x00080000L
#define M_CH12                                        0x00001000L
#define M_CH13                                        0x00002000L
#define M_CH14                                        0x00004000L
#define M_CH15                                        0x00008000L
#define M_CH16                                        0x00000100L
#define M_CH17                                        0x00000200L
#define M_CH18                                        0x00000400L
#define M_CH19                                        0x00000800L
#define M_CH20                                        0x00000010L
#define M_CH21                                        0x00000020L
#define M_CH22                                        0x00000040L
#define M_CH23                                        0x00000080L
#define M_SYNC                                        0x00400000L
#define M_SIGNAL                                      0x00800000L
#define M_CHANNEL_COLOR                               0x00000001L
#define M_RGB                                         8L
#define M_YC                                          9L
#define M_RCA                                         M_CH0
#define M_ALL_CHANNEL                                 (M_CH0|M_CH1|M_CH2|M_CH3|M_CH4|M_CH5|M_CH6|M_CH7|M_CH8|M_CH9|M_CH10|M_CH11)
#define M_ALL_CHANNELS                                M_ALL_CHANNEL
#define M_REGULAR                                     0x00020000L
#define M_CABLE                                       0x00020001L

// !!! MAP FOR OLD DEFINES
#if OldDefinesSupport
#define M_DIG_TUNER_CHANNEL                           M_TUNER_CHANNEL
#define M_DIG_TUNER_BAND                              M_TUNER_BAND
#endif


/************************************************************************/
/* MdigReference()                                                      */
/************************************************************************/
#define M_BLACK                                       0L
#define M_WHITE                                       1L
#define M_STEREO                                      0L
#define M_MONO                                        1L

/* See the Inquire for the M_CHx values */
#define M_CH0_REF                                     M_CH0
#define M_CH1_REF                                     M_CH1
#define M_CH2_REF                                     M_CH2
#define M_CH3_REF                                     M_CH3
#define M_CH4_REF                                     M_CH4
#define M_CH5_REF                                     M_CH5
#define M_CH6_REF                                     M_CH6
#define M_CH7_REF                                     M_CH7
#define M_ALL_REF                                     (M_CH0_REF | M_CH1_REF | M_CH2_REF | M_CH3_REF | M_CH4_REF | M_CH5_REF | M_CH6_REF | M_CH7_REF)
#define M_MIN_LEVEL                                   0L
#define M_MAX_LEVEL                                   255L

/************************************************************************/
/* MdigFocus()                                                          */
/************************************************************************/
#define M_NO_FILTER        0x00080000L
#define M_NO_SUBSAMPLING   0x00100000L
#define M_SMART_SCAN       0x00200000L
#define M_SCAN_ALL         0x00400000L
#define M_BISECTION        0x00800000L
#define M_REFOCUS          0x01000000L
#define M_EVALUATE         0x02000000L
#define M_CHANGE           0x00000001L
#define M_ON_FOCUS         0x00000002L

/************************************************************************/
/* MdigGrabWait()                                                       */
/************************************************************************/
#define M_GRAB_NEXT_FRAME                             1L
#define M_GRAB_NEXT_FIELD                             2L
#define M_GRAB_END                                    3L


/************************************************************************/
/* MdigHookFunction()                                                   */
/************************************************************************/
#define M_FIRST                                       0x10000000L
#define M_LAST                                        0x20000000L
#define M_UNHOOK                                      0x04000000L

#define M_GRAB_END                                    3L
#define M_GRAB_START                                  4L
#define M_GRAB_FRAME_END                              5L
#define M_GRAB_FIELD_END_ODD                          6L
#define M_GRAB_FIELD_END_EVEN                         7L
#define M_GRAB_FIELD_END                              8L
#define M_FRAME_START                                 9L
#define M_FIELD_START                                 10L
#define M_FIELD_START_ODD                             11L
#define M_FIELD_START_EVEN                            12L
#define M_GRAB_FRAME_START                            13L
#define M_GRAB_FIELD_START                            14L
#define M_GRAB_FIELD_START_ODD                        15L
#define M_GRAB_FIELD_START_EVEN                       16L
#define M_UART_DATA_RECEIVED                          17L
#define M_DCF_REALLOC                                 0x00000020L


/************************************************************************/
/* MgenLutFunction()                                                    */
/************************************************************************/
#define M_LOG                                         0x00000000L
#define M_EXP                                         0x00000001L
#define M_SIN                                         0x00000002L
#define M_COS                                         0x00000003L
#define M_TAN                                         0x00000004L
#define M_QUAD                                        0x00000005L

/************************************************************************/
/* MgenWarpParameter()                                                  */
/************************************************************************/
/* 8 bits reserved for number of fractional bits added to M_FIXED_POINT */
#define M_WARP_MATRIX                                 0x00100000L
#define M_WARP_POLYNOMIAL                             0x00200000L
#define M_WARP_LUT                                    0x00400000L
#define M_WARP_4_CORNER                               0x00800000L
#define M_WARP_4_CORNER_REVERSE                       0x01000000L
/* Optional controls */
#define M_FIXED_POINT                                 0x00004000L
#define M_OVERSCAN_ENABLE                             0x00008000L
#define M_OVERSCAN_DISABLE                            (M_ID_OFFSET_OF_DEFAULT_KERNEL >> 1L)
#define M_VERY_FAST                                   0x00010000L
#define M_REGULAR                                     0x00020000L
#define M_FAST                                        0x00040000L
/* Transforms */
#define M_RESIZE                                      1L
#define M_ROTATE                                      2L
#define M_SHEAR_X                                     3L
#define M_SHEAR_Y                                     4L
#define M_TRANSLATE                                   5L
#define M_SCALE                                 0x00008010L

/************************************************************************/
/* MbufBayer() defines                                                  */
/************************************************************************/
#define M_BAYER_MASK                                  224L
#define M_BAYER_GB                                    32L
#define M_BAYER_BG                                    64L
#define M_BAYER_RG                                    96L
#define M_BAYER_GR                                    128L
#define M_BAYER_GB_OLD                                7L
#define M_BAYER_BG_OLD                                8L
#define M_BAYER_RG_OLD                                9L
#define M_BAYER_GR_OLD                                10L
#define M_WHITE_BALANCE_CALCULATE                     16L
#define M_BAYER_BW_COMPAT                             256L
#define M_BAYER_NORMALIZE                             512L
#define M_BAYER_REVERSE                               M_REVERSE
#define M_BAYER_OVERSCAN_ENABLE                       M_OVERSCAN_ENABLE
#define M_BAYER_OVERSCAN_DISABLE                      M_OVERSCAN_DISABLE

/************************************************************************/
/* MimGetResult()                                                       */
/************************************************************************/
#define M_VALUE                                       0L
#define M_POSITION_X                                  0x00003400L
#define M_POSITION_Y                                  0x00004400L
#define M_NB_EVENT                                    5L

/************************************************************************/
/* MimInquire()                                                         */
/************************************************************************/
#define M_RESULT_SIZE                                 0L
#define M_RESULT_TYPE                                 1L

/************************************************************************/
/* MimFindExtreme()                                                     */
/************************************************************************/
#define M_MAX_VALUE                                   1L
#define M_MIN_VALUE                                   2L
#define M_MIN_ABS_VALUE                               4L
#define M_MAX_ABS_VALUE                               5L

/************************************************************************/
/* MimArith()                                                           */
/************************************************************************/
#define M_CONSTANT                                    0x8000L
#define M_FIXED_POINT                                 0x00004000L
#define M_ADD                                         0x0000L
#define M_ADD_CONST                                   (M_ADD | M_CONSTANT)
#define M_SUB                                         0x0001L
#define M_SUB_CONST                                   (M_SUB | M_CONSTANT)
#define M_NEG_SUB                                     0x000AL
#define M_CONST_SUB                                   (M_NEG_SUB | M_CONSTANT)
#define M_SUB_ABS                                     0x0011L
#define M_MIN                                         0x02000000L
#define M_MIN_CONST                                   (M_MIN | M_CONSTANT)
#define M_MAX                                         0x04000000L
#define M_MAX_CONST                                   (M_MAX | M_CONSTANT)
#define M_OR                                          0x0016L
#define M_OR_CONST                                    (M_OR  | M_CONSTANT)
#define M_AND                                         0x0017L
#define M_AND_CONST                                   (M_AND | M_CONSTANT)
#define M_XOR                                         0x0018L
#define M_XOR_CONST                                   (M_XOR | M_CONSTANT)
#define M_NOR                                         0x0019L
#define M_NOR_CONST                                   (M_NOR | M_CONSTANT)
#define M_NAND                                        0x001AL
#define M_NAND_CONST                                  (M_NAND | M_CONSTANT)
#define M_XNOR                                        0x001BL
#define M_XNOR_CONST                                  (M_XNOR | M_CONSTANT)
#define M_NOT                                         0x0014L
#define M_NEG                                         0x0023L
#define M_ABS                                         0x000CL
#define M_PASS                                        0x0002L
#define M_CONST_PASS                                  (M_PASS | M_CONSTANT)
#define M_MULT                                        0x0100L
#define M_MULT_CONST                                  (M_MULT | M_CONSTANT)
#define M_DIV                                         0x0101L
#define M_DIV_CONST                                   (M_DIV | M_CONSTANT)
#define M_INV_DIV                                     0x0102L
#define M_CONST_DIV                                   (M_INV_DIV | M_CONSTANT)


/************************************************************************/
/* MimArithMultiple()                                                   */
/************************************************************************/
#define M_OFFSET_GAIN                                 0x0000L
#define M_WEIGHTED_AVERAGE                            0x0001L
#define M_MULTIPLY_ACCUMULATE_1                       0x0002L
#define M_MULTIPLY_ACCUMULATE_2                       0x0004L

/************************************************************************/
/* MimFlip()                                                            */
/************************************************************************/
#define M_FLIP_VERTICAL                               1L
#define M_FLIP_HORIZONTAL                             2L

/************************************************************************/
/* MimBinarize(), MimClip(), MimLocateEvent()                           */
/* Some of these defines are also define in milutil.h                   */
/************************************************************************/
#define M_IN_RANGE                                    1L
#define M_OUT_RANGE                                   2L
#define M_EQUAL                                       3L
#define M_NOT_EQUAL                                   4L
#define M_GREATER                                     5L
#define M_LESS                                        6L
#define M_GREATER_OR_EQUAL                            7L
#define M_LESS_OR_EQUAL                               8L

/************************************************************************/
/* MimConvolve()                                                        */
/************************************************************************/
#define M_ID_OFFSET_OF_DEFAULT_KERNEL                 0x00100000L
#define M_ID_OFFSET_OF_EDGE_DETECTVAR                 0x00100100L
#define M_SMOOTH                                      (M_ID_OFFSET_OF_DEFAULT_KERNEL +  0L)
#define M_LAPLACIAN_EDGE                              (M_ID_OFFSET_OF_DEFAULT_KERNEL +  1L)
#define M_LAPLACIAN_EDGE2                             (M_ID_OFFSET_OF_DEFAULT_KERNEL +  2L)
#define M_SHARPEN                                     (M_ID_OFFSET_OF_DEFAULT_KERNEL +  3L)
#define M_SHARPEN2                                    (M_ID_OFFSET_OF_DEFAULT_KERNEL +  4L)
#define M_HORIZ_EDGE                                  (M_ID_OFFSET_OF_DEFAULT_KERNEL +  5L)
#define M_VERT_EDGE                                   (M_ID_OFFSET_OF_DEFAULT_KERNEL +  6L)
#define M_EDGE_DETECT                                 (M_ID_OFFSET_OF_DEFAULT_KERNEL +  7L)
#define M_EDGE_DETECT2                                (M_ID_OFFSET_OF_DEFAULT_KERNEL +  8L)
#define M_EDGE_DETECTVAR(Val)                         (M_ID_OFFSET_OF_EDGE_DETECTVAR + Val)
#define M_OVERSCAN_DISABLE                            (M_ID_OFFSET_OF_DEFAULT_KERNEL >> 1L)

/************************************************************************/
/* MimEdgeDetect()                                                      */
/************************************************************************/
#define M_SOBEL                                       M_EDGE_DETECT
#define M_PREWITT                                     M_EDGE_DETECT2
#define M_NOT_WRITE_ANGLE                             1L
#define M_NOT_WRITE_INT                               2L
#define M_FAST_ANGLE                                  4L
#define M_FAST_GRADIENT                               8L
#define M_FAST_EDGE_DETECT                            (M_FAST_ANGLE + M_FAST_GRADIENT)
#define M_REGULAR_ANGLE                               16L
#define M_REGULAR_GRADIENT                            64L
#define M_REGULAR_EDGE_DETECT                         (M_REGULAR_ANGLE + M_REGULAR_GRADIENT)


/************************************************************************/
/* MimRank()                                                            */
/************************************************************************/
#define M_MEDIAN                                      0x10000L
#define M_3X3_RECT                                    (M_ID_OFFSET_OF_DEFAULT_KERNEL + 20L)
#define M_3X3_CROSS                                   (M_ID_OFFSET_OF_DEFAULT_KERNEL + 21L)

/************************************************************************/
/* MimMorphic(), ...                                                    */
/************************************************************************/
#define M_ERODE                                       1L
#define M_DILATE                                      2L
#define M_THIN                                        3L
#define M_THICK                                       4L
#define M_HIT_OR_MISS                                 5L
#define M_MATCH                                       6L
#define M_HIT_THRESHOLD                              16L

/************************************************************************/
/* MimThin()                                                            */
/************************************************************************/
#define M_TO_SKELETON                                 -1L


/************************************************************************/
/* MimThick()                                                           */
/************************************************************************/
#define M_TO_IDEMPOTENCE                              M_TO_SKELETON

/************************************************************************/
/* MimDistance()                                                        */
/************************************************************************/
#define M_CHAMFER_3_4                                 0x01
#define M_CITY_BLOCK                                  0x02
#define M_CHESSBOARD                                  0x04
#define M_FORWARD                                     0x01
#define M_BACKWARD                                    0x02
#define M_OVERSCAN_TO_DO                              0x04
#define M_BOTH                                        0x07

/************************************************************************/
/* MimWatershed()                                                        */
/************************************************************************/
#define M_WATERSHED                                   0x0001
#define M_BASIN                                       0x0002
#define M_MINIMA_FILL                                 0x0004
#define M_MAXIMA_FILL                                 0x0008

#define M_4_CONNECTED                                 0x00000010L
#define M_8_CONNECTED                                 0x00000020L
#define M_REGULAR                                     0x00020000L
#define M_STRAIGHT_WATERSHED                          0x0080
#define M_SKIP_LAST_LEVEL                             0x0100
#define M_FILL_SOURCE                                 0x0200
#define M_LABELLED_MARKER                             0x0400

#define M_NEW_METHOD                                  0x0800

/************************************************************************/
/* MimProject()                                                         */
/************************************************************************/
#define M_0_DEGREE                                      0.0
#define M_90_DEGREE                                    90.0
#define M_180_DEGREE                                  180.0
#define M_270_DEGREE                                  270.0

/************************************************************************/
/* MimResize(), MimTranslate() and MimRotate()                          */
/************************************************************************/
#define M_OVERSCAN_DISABLE                            (M_ID_OFFSET_OF_DEFAULT_KERNEL >> 1L)
#define M_OVERSCAN_ENABLE                             0x00008000L
#define M_INTERPOLATE                                 0x00000004L
#define M_BILINEAR                                    0x00000008L
#define M_BICUBIC                                     0x00000010L
#define M_AVERAGE                                     0x00000020L
#define M_NEAREST_NEIGHBOR                            0x00000040L
#define M_OVERSCAN_CLEAR                              0x00000080L
#define M_FIT_ALL_ANGLE                               0x00000100L
#define M_BINARY                                      0x00001000L
#define M_REGULAR                                     0x00020000L
#define M_FAST                                        0x00040000L

/************************************************************************/
/* MimAverage                                                           */
/************************************************************************/
#define M_NORMAL                                      1L
#define M_WEIGHTED                                    2L
#define M_CONTINUOUS                                  -1L

/************************************************************************/
/* MimResize                                                            */
/************************************************************************/
#define M_FILL_DESTINATION                            -1 // DO NOT MODIFY, WITHOUT CODE MODIFICATION


/************************************************************************/
/* MimHistogramEqualize()                                               */
/************************************************************************/
#define M_UNIFORM                                     1
#define M_EXPONENTIAL                                 2
#define M_RAYLEIGH                                    3
#define M_HYPER_CUBE_ROOT                             4
#define M_HYPER_LOG                                   5


/************************************************************************/
/* MimConvert()                                                         */
/************************************************************************/
#define M_RGB_TO_HLS                                  1L
#define M_RGB_TO_L                                    2L
#define M_HLS_TO_RGB                                  3L
#define M_L_TO_RGB                                    4L
#define M_RGB_TO_Y                                    5L
#define M_RGB_TO_H                                    6L

// If the conversion type is set to M_DEFAULT, the conversion will be
//  choosen according to the type of buffers passed to the function.
#define M_DEFAULT                                    0x10000000L

// These can be added to the conversion type to speed-up the
//   process ( M_FAST ) or have a better precision ( M_REGULAR ).
//   Not all conversion are affected by this flag.
#define M_REGULAR                                     0x00020000L
#define M_FAST                                        0x00040000L

/************************************************************************/
/* MimWarp()                                                            */
/************************************************************************/
/* 8 bits reserved for number of fractional bits */
#define M_WARP_MATRIX                                 0x00100000L
#define M_WARP_POLYNOMIAL                             0x00200000L
#define M_WARP_LUT                                    0x00400000L
#define M_OVERSCAN_ENABLE                             0x00008000L
#define M_OVERSCAN_DISABLE                            (M_ID_OFFSET_OF_DEFAULT_KERNEL >> 1L)
#define M_OVERSCAN_CLEAR                              0x00000080L
#define M_FIXED_POINT                                 0x00004000L

/************************************************************************/
/* MimTransform()                                                       */
/************************************************************************/
#define M_FFT                                         1L
#define M_DCT8x8                                      2L
#define M_DCT                                         3L

#define M_FORWARD                                     0x01
#define M_REVERSE                                     4L
#define M_NORMALIZED                                  0x00000002L
#define M_NORMALIZE                                   M_NORMALIZED
#define M_1D_ROWS                                     0x00000010L
#define M_1D_COLUMNS                                  0x00000020L
#define M_REAL                                        0x00000040L
#define M_CENTER                                      0x00000080L
#define M_MAGNITUDE                                   0x00000100L
#define M_PHASE                                       0x00000200L
#define M_LOG_SCALE                                   0x00000400L


/************************************************************************/
/* MimPolarTransform()                                                  */
/************************************************************************/
#define M_RECTANGULAR_TO_POLAR                        0x00000001L
#define M_POLAR_TO_RECTANGULAR                        0x00000002L

/************************************************************************/
/* Buffer attributes                                                    */
/************************************************************************/
#define M_NO_ATTR                                     0x00000000L
#define M_IN                                          0x00000001L
#define M_OUT                                         0x00000002L
#define M_SRC                                         M_IN
#define M_DEST                                        M_OUT

#define M_IMAGE                                       0x00000004L
#define M_GRAB                                        0x00000008L
#define M_PROC                                        0x00000010L
#define M_DISP                                        0x00000020L
#define M_GRAPH                                       0x00000040L

#define M_LUT                                         0x00000100L
#define M_KERNEL                                      0x00000200L
#define M_STRUCT_ELEMENT                              0x00000400L
#define M_ARRAY                                       0x00000800L
#define M_BINARY                                      0x00001000L
#define M_HIST_LIST                                   0x00002000L
#define M_PROJ_LIST                                   0x00004000L
#define M_EVENT_LIST                                  0x00008000L
#define M_EXTREME_LIST                                0x00010000L
#define M_COUNT_LIST                                  0x00020000L
#define M_FILE_FORMAT                                 0x00040000L
#define M_WARP_COEFFICIENT                            0x00080000L
#define M_DIGITIZER                                   0x00100000L
#define M_DISPLAY                                     0x00200000L
#define M_APPLICATION                                 0x00400000L
#define M_SYSTEM                                      0x00800000L
#define M_GRAPHIC_CONTEXT                             0x01000000L
#define M_CALL_CONTEXT                                0x02000000L
#define M_ERROR_CONTEXT                               0x04000000L
#define M_THREAD_CONTEXT                              0x08000000L
#define M_EVENT_CONTEXT                               0x10000000L
#define M_USER_ATTRIBUTE                              0x20000000L
#define M_HOOK_CONTEXT                                0x40000000L


#define M_ALL_BUFFER_TYPES                           (M_IMAGE          | \
                                                      M_LUT            | \
                                                      M_KERNEL         | \
                                                      M_STRUCT_ELEMENT | \
                                                      M_ARRAY          | \
                                                      M_HIST_LIST      | \
                                                      M_PROJ_LIST      | \
                                                      M_EVENT_LIST     | \
                                                      M_EXTREME_LIST   | \
                                                      M_COUNT_LIST)

#define M_USER_OBJECT_1                               (M_USER_ATTRIBUTE | 0x00010000L)
#define M_USER_OBJECT_2                               (M_USER_ATTRIBUTE | 0x00020000L)
#define M_BLOB_OBJECT                                 (M_USER_ATTRIBUTE | 0x00040000L)
#define M_BLOB_FEATURE_LIST                           (M_BLOB_OBJECT    | 0x00000001L)
#define M_BLOB_RESULT                                 (M_BLOB_OBJECT    | 0x00000002L)
#define M_PAT_OBJECT                                  (M_USER_ATTRIBUTE | 0x00080000L)
#define M_PAT_MODEL                                   (M_PAT_OBJECT     | 0x00000001L)
#define M_PAT_RESULT                                  (M_PAT_OBJECT     | 0x00000002L)
#define M_OCR_OBJECT                                  (M_USER_ATTRIBUTE | 0x00100000L)
#define M_OCR_FONT                                    (M_OCR_OBJECT     | 0x00000001L)
#define M_OCR_RESULT                                  (M_OCR_OBJECT     | 0x00000002L)
#define M_OCR_MULTILINES_RESULT                       (M_OCR_OBJECT     | 0x00000003L)
#define M_MEAS_OBJECT                                 (M_USER_ATTRIBUTE | 0x00200000L)
#define M_MEAS_MARKER                                 (M_MEAS_OBJECT    | 0x00000001L)
#define M_MEAS_RESULT                                 (M_MEAS_OBJECT    | 0x00000002L)
#define M_MEAS_CONTEXT                                (M_MEAS_OBJECT    | 0x00000004L)
#define M_CAL_OBJECT                                  (M_USER_ATTRIBUTE | 0x00400000L)
#define M_CAL_PARENT                                  (M_CAL_OBJECT     | 0x00000001L)
#define M_CAL_CHILD                                   (M_CAL_OBJECT     | 0x00000002L)
#define M_CODE_OBJECT                                 (M_USER_ATTRIBUTE | 0x00800001L)
#define M_BGA_OBJECT                                  (M_USER_ATTRIBUTE | 0x01000001L)
#define M_FREE_OBJECT_1                               (M_USER_ATTRIBUTE | 0x02000000L)
#define M_MOD_OBJECT                                  (M_USER_ATTRIBUTE | 0x04000000L)
#define M_MOD_GEOMETRIC                               (M_MOD_OBJECT     | 0x00000001L)
#define M_MOD_GEOMETRIC_PREDEFINED                    (M_MOD_OBJECT     | 0x00000002L)
#define M_MOD_RESULT                                  (M_MOD_OBJECT     | 0x00000004L)
#define M_EDGE_OBJECT                                 (M_USER_ATTRIBUTE | 0x08000000L)
#define M_EDGE_CONTOUR                                (M_EDGE_OBJECT    | 0x00000001L)
#define M_EDGE_CREST                                  (M_EDGE_OBJECT    | 0x00000002L)
#define M_EDGE_RESULT                                 (M_EDGE_OBJECT    | 0x00000004L)

#define M_USER_DEFINE_LOW_ATTRIBUTE                   0x0000FFFFL

#define M_SYSTEM_ALLOCATED                            0x00000001L
#define M_USER_ALLOCATED                              0xFFFFFFFEL

#define M_SIGNED                                      0x80000000L
#define M_FLOAT                                      (0x40000000L | M_SIGNED)
#define M_DOUBLE                                     (0x20000000L | M_SIGNED)

// For M_IMAGE buffers only:
#define M_OVR                                         0x00000080L
#define M_COMPRESS                                    0x00004000L
#define M_READ_PREFETCH_ENABLED                       0x00008000L

//Keep only for backward compatibility.
#define M_MMX_ENABLED                                 M_READ_PREFETCH_ENABLED
#define M_SSE_ENABLED                                 M_READ_PREFETCH_ENABLED

#define M_FLIP                                        0x00010000L
#define M_PACKED                                      0x00020000L
#define M_PLANAR                                      0x00040000L
#define M_ON_BOARD                                    0x00080000L
#define M_OFF_BOARD                                   0x00100000L
#define M_NON_PAGED                                   0x00200000L
#define M_DIB                                         0x00400000L
#define M_DDRAW                                       0x00800000L
#define M_SINGLE                                      0x01000000L
#define M_VIA                                         M_SINGLE
#define M_PAGED                                       0x02000000L
#define M_NO_FLIP                                     0x04000000L
#define M_OVERSCAN_BUFFER                             0x08000000L
#define M_COMPLEX                                     0x10000000L
#define M_OFFSCREEN                                   M_OVR
#define M_UND                                         0x40000000L
#define M_USER_ATTRIBUTE                              0x20000000L
#define M_INTERNAL_ALLOCATION                         0x80000000L

#define M_COMPRESSION_FORMAT_MASK                     0x08c00000L
#define M_JPEG_LOSSLESS                               0x00400000L
#define M_JPEG_LOSSY                                  0x00800000L
#define M_JPEG_LOSSLESS_INTERLACED                    0x00C00000L
#define M_JPEG_LOSSY_INTERLACED                       0x08000000L
#define M_JPEG2000_LOSSY                              0x08400000L
#define M_JPEG2000_LOSSLESS                           0x08800000L
#define M_RESERVED_COMPRESSION_TYPE                   0x08C00000L
#define M_IS_JPEG(a)                                  ((((a) & M_COMPRESSION_FORMAT_MASK) >= M_JPEG_LOSSLESS) && \
                                                       (((a) & M_COMPRESSION_FORMAT_MASK) <= M_JPEG_LOSSY_INTERLACED))
#define M_IS_JPEG2000(a)                              ((((a) & M_COMPRESSION_FORMAT_MASK) >= M_JPEG2000_LOSSY) && \
                                                       (((a) & M_COMPRESSION_FORMAT_MASK) <= M_JPEG2000_LOSSLESS))
#define M_IS_COMPRESSED(a)                            (((a) & M_COMPRESS) != 0)
#define M_IS_INTERLACED(a)                            ((((a) & M_COMPRESSION_FORMAT_MASK) == M_JPEG_LOSSY_INTERLACED) || \
                                                       (((a) & M_COMPRESSION_FORMAT_MASK) == M_JPEG_LOSSLESS_INTERLACED))

/* 6 bits reserved for buffer internal format and format definitions */
#define M_INTERNAL_FORMAT             0x00003F00L
#define M_INTERNAL_FORMAT_SHIFT       8L
#define M_INTERNAL_COMPLETE_FORMAT    0x7FFFFF80L
#define M_ANY_INTERNAL_FORMAT         (0   << M_INTERNAL_FORMAT_SHIFT)

// RGB formats
#define M_MONO1                       (1   << M_INTERNAL_FORMAT_SHIFT)   // Force  1 bit  pixels in monochrome format
#define M_MONO8                       (2   << M_INTERNAL_FORMAT_SHIFT)   // Force  8 bits pixels in monochrome format
#define M_MONO16                      (3   << M_INTERNAL_FORMAT_SHIFT)   // Force 16 bits pixels in monochrome format
#define M_MONO32                      (4   << M_INTERNAL_FORMAT_SHIFT)   // Force 32 bits pixels in monochrome format
#define M_RGB15                       (6   << M_INTERNAL_FORMAT_SHIFT)   // Force 16 bits pixels in color XRGB  1.5.5.5  format
#define M_RGB16                       (7   << M_INTERNAL_FORMAT_SHIFT)   // Force 16 bits pixels in color RGB   5.6.5    format
#define M_RGB24                       (8   << M_INTERNAL_FORMAT_SHIFT)   // Force 24 bits pixels in color RGB   8.8.8    format
#define M_RGBX32                      (9   << M_INTERNAL_FORMAT_SHIFT)   // Force 32 bits pixels in color RGBX  8.8.8.8  format
#define M_RGB32                       M_RGBX32
#define M_XRGB32                      (10  << M_INTERNAL_FORMAT_SHIFT)   // Force 32 bits pixels in color XRGB  8.8.8.8  format
#define M_RGB48                       (11  << M_INTERNAL_FORMAT_SHIFT)   // Force 48 bits pixels in color RGB  16.16.16  format
#define M_RGB96                       (12  << M_INTERNAL_FORMAT_SHIFT)   // Force 96 bits pixels in color RGB  32.32.32  format
#define M_RGB3                        (13  << M_INTERNAL_FORMAT_SHIFT)   // Force  3 bits pixels in color RGB   1.1.1    format
#define M_BGR15                       (14  << M_INTERNAL_FORMAT_SHIFT)   // Force 16 bits pixels in color BGRX  5.5.5.1  format
#define M_BGR16                       (15  << M_INTERNAL_FORMAT_SHIFT)   // Force 16 bits pixels in color BGR   5.6.5    format
#define M_BGR24                       (16  << M_INTERNAL_FORMAT_SHIFT)   // Force 24 bits pixels in color BGR   8.8.8    format
#define M_BGRX32                      (17  << M_INTERNAL_FORMAT_SHIFT)   // Force 32 bits pixels in color BGRX  8.8.8.8  format
#define M_BGR32                       M_BGRX32
#define M_XBGR32                      (18  << M_INTERNAL_FORMAT_SHIFT)   // Force 32 bits pixels in color XBGR  8.8.8.8  format
#define M_BGR30                       (19  << M_INTERNAL_FORMAT_SHIFT)   // Force 32 bits pixels in color XBGR  2.10.10.10  format

// YUV formats
#define M_YUV_FORMAT_START            (21  << M_INTERNAL_FORMAT_SHIFT)
#define M_YUV9                        (21  << M_INTERNAL_FORMAT_SHIFT)   // Force  9 bits YUV pixels in color YUV 16:1:1 format
#define M_YUV12                       (22  << M_INTERNAL_FORMAT_SHIFT)   // Force 12 bits YUV pixels in color YUV  4:1:1 format
#define M_YUV16                       (23  << M_INTERNAL_FORMAT_SHIFT)   // Force 16 bits YUV pixels in color YUV  4:2:2 format
#define M_YUV24                       (27  << M_INTERNAL_FORMAT_SHIFT)   // Force 24 bits YUV pixels in color YUV  4:4:4 format
#define M_YUV16_YUYV                  (28  << M_INTERNAL_FORMAT_SHIFT)   // Force YUV16 packed buffers into a YUYV memory layout ( meteor, corona, meteor2 ) (FOURCC: YUY2).
#define M_YUV16_UYVY                  (29  << M_INTERNAL_FORMAT_SHIFT)   // Force YUV16 packed buffers into a UYVY memory layout ( meteor ) (FOURCC: UYVY).
#define M_YUV16_1394                  M_YUV16_UYVY
#define M_YUV12_1394                  (31  << M_INTERNAL_FORMAT_SHIFT)   // Force YUV12 packed buffers with the special memory layout of the 1394.
#define M_YUV_FORMAT_END              (39  << M_INTERNAL_FORMAT_SHIFT)
#define M_IS_FORMAT_YUV(f)            (((f&M_INTERNAL_FORMAT)>=M_YUV_FORMAT_START)&&((f&M_INTERNAL_FORMAT)<=M_YUV_FORMAT_END))
#define M_BIT_FIELD_FORMAT(f)         (1<<(((f&M_INTERNAL_FORMAT)>>M_INTERNAL_FORMAT_SHIFT)-1))
#define M_SINGLE_BAND                 (255 << M_INTERNAL_FORMAT_SHIFT)   // PutColor and GetColor specification for a single band

#define M_YUV422_16BIT                (24 << M_INTERNAL_FORMAT_SHIFT)



// The following MACRO takes a data format as input and returns the number
// of bits per pixel that it implies as an output.
// For an unknown data format, it returns -1.
#define NB_OF_BITS_PER_PIXEL(DataFormat,NbOfBits)            \
   switch( (DataFormat & M_INTERNAL_FORMAT) )                \
      {                                                      \
      case M_MONO1:        NbOfBits = 1;        break;       \
      case M_MONO8:        NbOfBits = 8;        break;       \
      case M_MONO16:       NbOfBits = 16;       break;       \
      case M_MONO32:       NbOfBits = 32;       break;       \
      case M_RGB15:        NbOfBits = 16;       break;       \
      case M_RGB16:        NbOfBits = 16;       break;       \
      case M_RGB24:        NbOfBits = 24;       break;       \
      case M_RGBX32:       NbOfBits = 32;       break;       \
      case M_XRGB32:       NbOfBits = 32;       break;       \
      case M_RGB48:        NbOfBits = 48;       break;       \
      case M_RGB96:        NbOfBits = 96;       break;       \
      case M_RGB3:         NbOfBits = 3;        break;       \
      case M_BGR15:        NbOfBits = 16;       break;       \
      case M_BGR16:        NbOfBits = 16;       break;       \
      case M_BGR24:        NbOfBits = 24;       break;       \
      case M_BGRX32:       NbOfBits = 32;       break;       \
      case M_XBGR32:       NbOfBits = 32;       break;       \
                                                             \
      case M_YUV9:         NbOfBits = 9;        break;       \
      case M_YUV12:        NbOfBits = 12;       break;       \
      case M_YUV16:        NbOfBits = 16;       break;       \
      case M_YUV24:        NbOfBits = 24;       break;       \
      case M_YUV16_YUYV:   NbOfBits = 16;       break;       \
      case M_YUV16_UYVY:   NbOfBits = 16;       break;       \
      case M_YUV12_1394:   NbOfBits = 12;       break;       \
      default:             NbOfBits = -1;       break;       \
      }

// The following MACRO takes a data format as input and returns the number
// of bits per pixel per plane that it implies as an output.
// For an unknown data format, it returns -1.
#define M_NB_BITS_PER_PIXEL_PER_PLANE(DataFormat,NbOfBits)      \
   if (DataFormat&M_PLANAR)                                     \
      {                                                         \
      switch( (DataFormat & M_INTERNAL_FORMAT) )                \
         {                                                      \
         case M_MONO1:        NbOfBits = 1;        break;       \
         case M_MONO8:        NbOfBits = 8;        break;       \
         case M_MONO16:       NbOfBits = 16;       break;       \
         case M_MONO32:       NbOfBits = 32;       break;       \
         case M_RGB3:         NbOfBits = 1;        break;       \
         case M_RGB24:        NbOfBits = 8;        break;       \
         case M_RGB48:        NbOfBits = 16;       break;       \
         case M_RGB96:        NbOfBits = 32;       break;       \
                                                                \
         case M_YUV9:         NbOfBits = 8;        break;       \
         case M_YUV12:        NbOfBits = 8;        break;       \
         case M_YUV16:        NbOfBits = 8;        break;       \
         case M_YUV24:        NbOfBits = 8;        break;       \
         case M_YUV12_1394:   NbOfBits = 8;        break;       \
         default:             NbOfBits = -1;       break;       \
         }                                                      \
      }                                                         \
   else                                                         \
      {                                                         \
      switch( (DataFormat & M_INTERNAL_FORMAT) )                \
         {                                                      \
         case M_RGB15:        NbOfBits = 16;       break;       \
         case M_RGB16:        NbOfBits = 16;       break;       \
         case M_RGB24:        NbOfBits = 24;       break;       \
         case M_RGBX32:       NbOfBits = 32;       break;       \
         case M_XRGB32:       NbOfBits = 32;       break;       \
         case M_BGR15:        NbOfBits = 16;       break;       \
         case M_BGR16:        NbOfBits = 16;       break;       \
         case M_BGR24:        NbOfBits = 24;       break;       \
         case M_BGRX32:       NbOfBits = 32;       break;       \
         case M_XBGR32:       NbOfBits = 32;       break;       \
                                                                \
         case M_YUV9:         NbOfBits = 9;        break;       \
         case M_YUV12:        NbOfBits = 12;       break;       \
         case M_YUV16:        NbOfBits = 16;       break;       \
         case M_YUV24:        NbOfBits = 24;       break;       \
         case M_YUV16_YUYV:   NbOfBits = 16;       break;       \
         case M_YUV16_UYVY:   NbOfBits = 16;       break;       \
         case M_YUV12_1394:   NbOfBits = 12;       break;       \
         default:             NbOfBits = -1;       break;       \
         }                                                      \
      }


// !!! MAP FOR OLD DEFINES
#if OldDefinesSupport
#define M_CHAR                        (M_MONO8     | M_SIGNED)
#define M_UCHAR                       (M_MONO8)
#define M_SHORT                       (M_MONO16    | M_SIGNED)
#define M_USHORT                      (M_MONO16)
#define M_LONG                        (M_MONO32    | M_SIGNED)
#define M_ULONG                       (M_MONO32)
#define M_RGB555                      (M_RGB15     | M_SIGNED)
#define M_URGB555                     (M_RGB15)
#define M_URGB888                     (M_RGB24)
#define M_BGR888                      (M_BGR24     | M_SIGNED)
#define M_RGB161616                   (M_RGB48     | M_SIGNED)
#define M_URGB161616                  (M_RGB48)
#define M_RGB323232                   (M_RGB96     | M_SIGNED)
#define M_URGB323232                  (M_RGB96)
#define M_YUV9_PLANAR                 (M_YUV9      | M_PLANAR)
#define M_YUV12_PLANAR                (M_YUV12     | M_PLANAR)
#define M_YUV16_PLANAR                (M_YUV16     | M_PLANAR)
#define M_YUV16_PACKED                (M_YUV16     | M_PACKED)
#define M_BGR15_PACKED                (M_BGR15     | M_PACKED)
#define M_RGB24_PACKED                (M_RGB24     | M_PACKED)
#define M_RGB32_PACKED                (M_RGB32     | M_PACKED)
#define M_BGR24_PACKED                (M_BGR24     | M_PACKED)
#define M_NODIBFLIP                   (M_FLIP)
#define M_DIB_BGR24_PACKED            (M_BGR24     | M_PACKED | M_FLIP | M_DIB)
#define M_BGR32_PACKED                (M_BGR32     | M_PACKED)
#endif

/************************************************************************/
/* MbufCreateColor() Values                                             */
/************************************************************************/
#define M_HOST_ADDRESS                                0x80000000L
#define M_PHYSICAL_ADDRESS                            0x40000000L
#define M_PITCH                                       0x20000000L
#define M_DEFAULT                                     0x10000000L
#define M_PITCH_BYTE                                  0x08000000L
#define M_BUF_ID                                      0x04000000L
#define M_BUF_ID_MODIFY                               0x02000000L
#define M_BUF_MD_ID                                   0x01000000L



/************************************************************************/
/* MbufBlit() Values                                                    */
/************************************************************************/
#ifdef M_USE_MBUFBLIT
#if !M_MIL_USE_PPC
#include <memory.h>  // For memset()
#include <mddraw.h>   // For LPDIRECTDRAWSURFACE
#endif

// A combination of flags that determine the valid members of the MBLTDESC structure.
#define M_BLT_REGION       0x00000001L  // Uses the lRegion member of the MBLTDESC structure to determine which region to copy.
#define M_BLT_MODE         0x00000002L  // Uses the lMode member of the MBLTDESC structure to determine if the blit is synchronous or not.
#define M_BLT_TYPE         0x00000004L  // Uses the lType member of the MBLTDESC structure to determine the type of the copy.
#define M_BLT_DESTRECT     0x00000008L  // Uses the lDestRect member of the MBLTDESC structure to determine the valid destination rectangle.
#define M_BLT_SRCRECT      0x00000010L  // Uses the lSrcRect member of the MBLTDESC structure to determine the valid source rectangle.

// Indicate which region (M_BLT_REGION) to copy from the source buffer to the destination buffer (the default is M_BLT_FRAME).
// The valid values for this member are:
#define M_BLT_FRAME        1  // Blit all lines of the source buffer in the destination buffer. ***DEFAULT***
#define M_BLT_ODD          2  // Blit all lines from the sources buffer to ODD lines of the destination buffer.
#define M_BLT_EVEN         3  // Blit all lines from the sources buffer to EVEN lines of the destination buffer.
#define M_BLT_ODD_ODD      4  // Blit ODD lines from the sources buffer to ODD lines of the destination buffer.
#define M_BLT_EVEN_EVEN    5  // Blit EVEN lines from the sources buffer to EVEN lines of the destination buffer.

// Indicate if the blit (M_BLT_MODE) is done asynchronously or synchronously (the default is synchronously). The valid value are:
#define M_BLT_ASYNC        10  // Performs this blit asynchronously.
#define M_BLT_SYNC         11  // Performs this blit synchronously. ***DEFAULT***

// Indicate which type (M_BLT_TYPE) of copy is performed (the default is a normal blit, M_SCRCOPY). The valid values are:
#define M_BLT_SRCCOPY               20  // Performs a normal blit. (only supported by M_BLT_FRAME) ***DEFAULT***
#define M_BLT_SRCKEYONBLACK         21  // Performs a blit with black keying. (only supported by M_BLT_FRAME)
#define M_BLT_SRCMIRRORLEFTRIGHT    22 // This blit mirrors the surface from left to right (y-axis).
#define M_BLT_SRCMIRRORUPDOWN       23 // This blit mirrors the surface from top to bottom (x-axis).
#define M_BLT_SRCMIRRORLRUPDN       24 // This blit mirrors the surface from top to bottom and from left to right.
#define M_BLT_SCALELINEAR           25
#define M_BLT_SCALENEAR             26
#define M_BLT_SCALECONSTANT         27
#define M_BLT_SCALEYUV2BGR          28
#define M_BLT_SCALEYUV2Y            29
#define M_BLT_SCALEYUV              30

// The MRECT structure defines the coordinates of the upper-left and lower-right corners of a rectangle.
typedef struct _MRECT {
   long left;
   long top;
   long right;
   long bottom;
   } MRECT;

typedef MRECT *LPMRECT;


// ****************************************************************************
//
// Description of the MBLTDESC_VER1 structure :
//
//    lSize :        Size of the structure, in bytes. This member must be
//                   initialized before the structure is used.
//    lValidMembers: A combination of flags that determine the valid members of
//                   the MBLTDESC structure.
//    lRegion:       Indicate which region to copy from the source buffer to
//                   the destiantion buffer (the default is M_BLT_FRAME).
//    lMode:         Indicate if the blit is done asynchronously or
//                   synchronously (the default is synchronously).
//    lType:         Indicate which type of copy is performed (the default
//                   is a normal blit, M_SCR_COPY).
//    DestRect:      RECT structure that defines the upper-left and lower-right
//                   points of the rectangle to blit to on the destination
//                   surface. If this parameter is set to ZERO, the entire
//                   destination surface is used.
//    SrcRect:       RECT structure that defines the upper-left and lower-right
//                   points of the rectangle to blit from on the source surface.
//                   If this parameter is set to ZERO, the entire source surface
//                   is used.
//    lpDDDestSurface: Address of the destination direct draw surface used for
//                   the copy. MIL will fill automaticaly this member is the blit
//                   is valid. Use this member if you want to know if an
//                   asynchronously blit is done (GetBltStatus(DDGBS_ISBLTDONE)).
//    lSrcType:      Indicate which type of protocole to use for the source (FB, PCI or AGP)
//    lDestType:     Indicate which type of protocole to use for the destination (FB, PCI or AGP)
//
// ****************************************************************************

#if !M_MIL_USE_PPC
typedef struct _MBLTDESC_VER1 {
   long        lSize;
   long        lValidMembers;
   long        lRegion;
   long        lMode;
   long        lType;
   MRECT       DestRect;
   MRECT       SrcRect;
   LPDIRECTDRAWSURFACE lpDDDestSurface;
   long        lSrcType;
   long        lDestType;
   } MBLTDESC_VER1;
typedef MBLTDESC_VER1 *LPMBLTDESC_VER1;

typedef MBLTDESC_VER1 MBLTDESC;

typedef MBLTDESC *LPMBLTDESC;
#endif // M_MIL_USE_PPC

#define M_INIT_STRUCT(x) (memset(&x,0,sizeof(x)), x.lSize=sizeof(x))
#endif // M_USE_MBUFBLIT


/************************************************************************/
/* MbufGet(), MbufPut(), MbufChild(), ...                               */
/************************************************************************/
#define M_RED                                         0x1000L
#define M_GREEN                                       0x2000L
#define M_BLUE                                        0x4000L
#define M_ALL_BAND                                    -1L
#define M_HUE                                         0x00008000L
#define M_SATURATION                                  M_GREEN
#define M_LUMINANCE                                   0x00020000L   // M_GRAB_INPUT_GAIN
#define M_CHROMINANCE                                 0x00040000L   // M_GRAB_INPUT_GAIN
#define M_Y                                           M_RED
#define M_U                                           M_GREEN
#define M_V                                           M_BLUE
#define M_DITHERING                                   0x2000L
#define M_CBCR                                        0x4000L

#define M_ALL_BITS                                    -1L
#define M_DONT_CARE                                   0x00008000L


/************************************************************************/
/* MbufImport(), MbufExport()                                           */
/************************************************************************/
#define M_RESTORE                                     0L
#define M_LOAD                                        1L

#define M_MIL                                         0L
#define M_RAW                                         1L
#define M_TIFF                                        2L
#define M_GIF                                         3L
#define M_BMP                                         4L
#define M_JPEG                                        5L // Internal use only
#define M_RIFF                                        6L // Internal use only
#define M_JPEG2K                                      7L // Internal use only

// See buffer attributes for the signification of the value of M_JPEG_LOSSLESS
//    and M_JPEG_LOSSY.
#define M_JPEG_LOSSLESS                               0x00400000L
#define M_JPEG_LOSSY                                  0x00800000L
#define M_JPEG_LOSSLESS_INTERLACED                    0x00C00000L
#define M_JPEG_LOSSY_INTERLACED                       0x08000000L
// This special file format for Import and Export only.
#define M_JPEG_LOSSY_RGB                              0x01000000L

#define M_PLANAR                                      0x00040000L

/************************************************************************/
/* MbufImportSequence(), MbufExportSequence()                           */
/************************************************************************/
#define M_RESTORE                                     0L
#define M_LOAD                                        1L

#define M_AVI_MIL                                     100L
#define M_AVI_DIB                                     101L // Standard Windows AVI files.
#define M_AVI_MJPG                                    102L
#define M_AVI_MJPEG                                   M_AVI_MJPG
#define M_DEFAULT                                     0x10000000L

// Import/Export Control Flags.
#define M_DEFAULT                                     0x10000000L         /* Create a file-Write/Read-Close           */
#define M_APPEND                                      0x20000000L         /* Open-Append-Close                        */
#define M_READ                                        1                   /* Read from an opened file.                */
#define M_WRITE                                       2                   /* Write into an opened file.               */
#define M_OPEN                                        0x00000010L         /* Open a file to Read/Write( with create ) */
#define M_CLOSE                                       0x00000020L         /* Close an open file.                      */
#define M_OPEN_APPEND                                 (M_OPEN + M_APPEND) /* Open an existing file to append into.    */

/************************************************************************/
/* MbufControlNeighborhood()                                            */
/************************************************************************/
#define M_ABSOLUTE_VALUE                              50L
#define M_NORMALIZATION_FACTOR                        52L
#define M_OVERSCAN                                    53L
#define M_OVERSCAN_REPLACE_VALUE                      54L
#define M_OFFSET_CENTER_X                             55L
#define M_OFFSET_CENTER_Y                             56L
#define M_ENABLE                                      -9997L
#define M_DISABLE                                     -9999L
#define M_TRANSPARENT                                 0x01000059L
#define M_REPLACE                                     0x01000060L
#define M_MIRROR                                      0x01000061L
#define M_REPLACE_MAX                                 0x01000063L
#define M_REPLACE_MIN                                 0x01000064L
#define M_SATURATION                                  M_GREEN


/************************************************************************/
/* MbufInquire() / MbufControl() Types                                  */
/************************************************************************/
#define M_OWNER_APPLICATION                           1000L
#define M_OWNER_SYSTEM                                1001L
#define M_SIZE_X                                      1002L
#define M_SIZE_Y                                      1003L
#define M_SIZE_Z                                      1004L
#define M_SIZE_BAND                                   1005L
#define M_SIZE_BAND_LUT                               1006L
#define M_SIZE_BIT                                    1007L
#define M_TYPE                                        1008L
#define M_NUMBER                                      1009L
#define M_FORMAT                                      1010L
#define M_FORMAT_SIZE                                 1011L
#define M_INIT_FLAG                                   1012L
#define M_ATTRIBUTE                                   1013L
#define M_SIGN                                        1014L
#define M_LUT_ID                                      1015L
#define M_NATIVE_ID                                   1016L
#define M_NATIVE_CONTROL_ID                           1017L
#define M_SURFACE                                     1021L
#define M_WINDOW_DDRAW_SURFACE                        1022L
#define M_OWNER_SYSTEM_TYPE                           1023L

#define M_INTER_SYSTEM_ID                             5000L
#define M_PARENT_ID                                   5001L
#define M_ANCESTOR_ID                                 5002L
#define M_PARENT_OFFSET_X                             5003L
#define M_PARENT_OFFSET_Y                             5004L
#define M_ANCESTOR_OFFSET_X                           5005L
#define M_ANCESTOR_OFFSET_Y                           5006L
#define M_PARENT_OFFSET_BAND                          5007L
#define M_ANCESTOR_OFFSET_BAND                        5008L
#define M_NB_CHILD                                    5009L
#define M_MODIFICATION_COUNT                          5010L
#define M_ANCESTOR_SIZE_X                             5012L
#define M_HOST_ADDRESS_FAR                            5013L
#define M_ASSOCIATED_LUT                              5014L
#define M_CURRENT_BUF_ID                              5015L
#define M_ASSOCIATED_BUFFER_ID                        5016L
#define M_MAP_BUFFER_TO_HOST                          5017L
#define M_HOST_ID                                     5020L
#define M_DMA_BUFFER                                  5021L
#define M_DMA_BUFFER_PTR                              5022L
#define M_DMA_BUFFER_PHYSICAL_PTR                     5023L
#define M_VALID_GRAB_BUFFER                           5025L
#define M_VALID_GRAB_BUFFER_OFFSET                    5026L
#define M_LOW_LEVEL_BUFFER_ID                         5027L
#define M_BUFFER_INFO                                 5028L
#define M_MEMBANK                                     5029L // Pulsar internal use only
#define M_LOCPOS_X                                    5030L // Pulsar internal use only
#define M_LOCPOS_Y                                    5031L // Pulsar internal use only
#define M_LOCPOS_BIT                                  5032L // Pulsar internal use only
#define M_ON_BOARD_DISP_BUFFER_NATIVE_ID              5033L // Pulsar internal use only
#define M_ON_BOARD_DISP_BUFFER_MIL_ID                 5034L // Pulsar internal use only
#define M_VGA_DISP_BUFFER_ID                          5035L // Pulsar internal use only
#define M_OVR_DISP_BUFFER_ID                          5036L // Pulsar internal use only
#define M_MEMORG                                      5037L // Pulsar internal use only
#define M_ANCESTOR_OFFSET_BIT                         5038L
#define M_DIB_MODE                                    5039L
#define M_FLIP_MODE                                   5040L
#define M_WINDOW_DC_ALLOC                             5041L
#define M_WINDOW_DC_FREE                              5042L
#define M_WINDOW_DC                                   5043L
#define M_MODIFIED                                    5044L
#define M_COMPRESSION_TYPE                            5045L
#define M_HUFFMAN_DC_LUMINANCE                        5046L // Buffer M_COMPRESS Jpeg
#define M_HUFFMAN_AC_LUMINANCE                        5047L // Buffer M_COMPRESS Jpeg
#define M_HUFFMAN_DC_CHROMINANCE                      5048L // Buffer M_COMPRESS Jpeg
#define M_HUFFMAN_AC_CHROMINANCE                      5049L // Buffer M_COMPRESS Jpeg
#define M_HUFFMAN_DC                                  5050L // Buffer M_COMPRESS Jpeg
#define M_HUFFMAN_AC                                  5051L // Buffer M_COMPRESS Jpeg
#define M_PREDICTOR                                   5052L // Buffer M_COMPRESS Jpeg
#define M_QUANTIZATION_LUMINANCE                      5053L // Buffer M_COMPRESS Jpeg
#define M_QUANTIZATION_CHROMINANCE                    5054L // Buffer M_COMPRESS Jpeg
#define M_QUANTIZATION_OLD                            5055L // Buffer M_COMPRESS Jpeg
#define M_Q_FACTOR_LUMINANCE                          5056L // Buffer M_COMPRESS Jpeg
#define M_Q_FACTOR_CHROMINANCE                        5057L // Buffer M_COMPRESS Jpeg
#define M_Q_FACTOR_OLD                                5058L // Buffer M_COMPRESS Jpeg
#define M_RESTART_INTERVAL                            5059L // Buffer M_COMPRESS Jpeg
#define M_JPEG_HW_PROG                                5060L // Buffer M_COMPRESS Jpeg
#define M_SIZE_BYTE                                   5061L
#define M_PROC_HOST_ID                                5062L
#define M_INTERNAL_COMPRESSION_BUFFER_ID              5063L
#define M_INTERNAL_BUFFER_HOST_ADDRESS                5064L
#define M_INTERNAL_JPEG_FRAME_SIZEBYTE                5065L
#define M_INTERNAL_COMPRESSION_BUFFER_SIZE_DIVISION_FACTOR  5066L
#define M_SIZE_BYTE_FIRST_FIELD                       5067L
#define M_SIZE_BYTE_SECOND_FIELD                      5068L
#define M_JPEG_COMPRESS                               5069L // Buffer M_COMPRESS Jpeg
#define M_JPEG_DECOMPRESS                             5070L // Buffer M_COMPRESS Jpeg
#define M_REGENERATE_HEADER                           5071L // Internal Use Only.
#define M_PARSE_JPEG_DATA                             5072L // Internal Use Only.
#define M_HEADER_MODIFIED                             5073L // Internal Use Only.
#define M_TARGET_SIZE                                 5074L // Set internal compression buffer size in byte
#define M_SIZE_BYTE_PER_PIXEL                         5075L
#define M_ATTACHED_BUFFER_0_ID                        5076L
#define M_ATTACHED_BUFFER_1_ID                        5077L
#define M_ASSOCIATED_VGA_BUFFER_ID                    5078L
#define M_FIELD_UPDATE_MODE                           5079L
#define M_YCRCB_RANGE                                 5080L
#define M_EXTRA_BUFFER_INFO                           5081L // Internal Use Only.
#define M_MODIFICATION_HOOK                           5082L

// MTXDMA reserved area
#define M_BUF_MTXDMA_START                            5100L
#define M_BUFFER_CACHE                                5100L
#define M_BUFFER_CACHE_FLUSH                          5101L
#define M_BUFFER_AGP_CAPABLE                          5102L
#define M_WRITE_COMBINING                             5103L
#define M_BUF_MTXDMA_END                              5150L

// The difference between the following defines must be >= 2. The bits
// 14, 13 and 12 (zero-based) of the flags must also always be cleared.
#define M_NUMBER_SUBBAND                             33000L
#define M_DECOMPOSITION_LEVEL                        33002L
#define M_Q_FACTOR                                   33004L
#define M_QUANTIZATION                               33006L

// Reserved    5098   M_SIZE_X_RED   5098
// Reserved    5099   M_SIZE_Y_RED   5098

#define M_HOST_ADDRESS                                0x80000000L
#define M_HOST_ADDRESS_RED                            M_HOST_ADDRESS + M_RED    // 0x80001000L
#define M_HOST_ADDRESS_GREEN                          M_HOST_ADDRESS + M_GREEN  // 0x80002000L
#define M_HOST_ADDRESS_BLUE                           M_HOST_ADDRESS + M_BLUE   // 0x80004000L

#define M_SIZE_X                                      1002L
#define M_SIZE_X_RED                                  M_SIZE_X + M_RED     // 0x000013eaL = 5098
#define M_SIZE_X_GREEN                                M_SIZE_X + M_GREEN   // 0x000023eaL = 9194
#define M_SIZE_X_BLUE                                 M_SIZE_X + M_BLUE    // 0x000043eaL = 17386

#define M_SIZE_Y                                      1003L
#define M_SIZE_Y_RED                                  M_SIZE_Y + M_RED     // 0x000013ebL = 5099
#define M_SIZE_Y_GREEN                                M_SIZE_Y + M_GREEN   // 0x000023ebL = 9195
#define M_SIZE_Y_BLUE                                 M_SIZE_Y + M_BLUE    // 0x000043ebL = 17387

#define M_PHYSICAL_ADDRESS                            0x40000000L
#define M_PITCH                                       0x20000000L
#define M_DEFAULT                                     0x10000000L
#define M_PITCH_BYTE                                  0x08000000L
#define M_BUF_ID                                      0x04000000L

// !!! MAP FOR OLD DEFINES
#if OldDefinesSupport
#define M_DMA_READ_HOST_ID                            M_HOST_ID
#define M_BUF_ASSOCIATED_BUFFER_ID                    M_ASSOCIATED_BUFFER_ID
#endif

/************************************************************************/
/* MbufControl() MbufInquire() Values                                   */
/************************************************************************/

#define M_ODD_FIELD                                   1L
#define M_EVEN_FIELD                                  2L
#define M_BOTH_FIELD                                  3L


/************************************************************************/
/* MbufDiskInquire()                                                    */
/************************************************************************/
#define M_LUT_PRESENT                                 6000L
#define M_ASPECT_RATIO                                6001L
#define M_FRAME_RATE                                  6002L
#define M_NUMBER_OF_IMAGES                            6003L
#define M_FORMAT_SUPPORTED                            5180L


/* Common with other Inquire/Control */
#define M_ABSOLUTE_VALUE                              50L
#define M_NORMALIZATION_FACTOR                        52L
#define M_OVERSCAN                                    53L
#define M_OVERSCAN_REPLACE_VALUE                      54L
#define M_OFFSET_CENTER_X                             55L
#define M_OFFSET_CENTER_Y                             56L
#define M_SIZE_X                                      1002L
#define M_SIZE_Y                                      1003L
#define M_SIZE_BAND                                   1005L
#define M_SIZE_BIT                                    1007L
#define M_TYPE                                        1008L
#define M_ATTRIBUTE                                   1013L
#define M_SIGN                                        1014L
#define M_GREEN                                       0x2000L
#define M_SATURATION                                  M_GREEN
#define M_FILE_FORMAT                                 0x00040000L
#define M_LUT                                         0x00000100L

/************************************************************************/
/* Lattice values                                                       */
/************************************************************************/
#define M_4_CONNECTED                                 0x00000010L
#define M_8_CONNECTED                                 0x00000020L


/************************************************************************/
/* Data types for results                                               */
/************************************************************************/
#define M_TYPE_CHAR                                   0x00010000L
#define M_TYPE_SHORT                                  0x00020000L
#define M_TYPE_LONG                                   0x00040000L
#define M_TYPE_FLOAT                                  0x00080000L
#define M_TYPE_DOUBLE                                 0x00100000L
#define M_TYPE_PTR                                    0x00200000L
#define M_TYPE_MIL_ID                                 0x00400000L
#define M_TYPE_STRING                                 0x00800000L
#define M_TYPE_STRING_PTR                             M_TYPE_STRING
#define M_TYPE_ASCII                                  M_TYPE_STRING
#define M_TYPE_BINARY                                 0x01000000L
#define M_TYPE_HEX                                    0x02000000L


/* Bit encoded image types */
#define M_GREYSCALE                                   0x0200L
#define M_GRAYSCALE                                   M_GREYSCALE

/************************************************************************/
/* MgraFont()                                                           */
/************************************************************************/
#define M_FONT_DEFAULT_SMALL                          0L
#define M_FONT_DEFAULT_MEDIUM                         1L
#define M_FONT_DEFAULT_LARGE                          2L
#define M_FONT_DEFAULT                                M_FONT_DEFAULT_SMALL

/************************************************************************/
/* Used by MgraControl() / MgraInquire() Types                          */
/************************************************************************/
#define M_GRAPHIC_POSITION_X                          3L
#define M_GRAPHIC_POSITION_Y                          4L
#define M_COLOR                                       5L
#define M_BACKCOLOR                                   6L
#define M_RGB_COLOR                                   0x40000000L
#define M_RGB888(r,g,b)                               (M_RGB_COLOR|((unsigned long)(((unsigned char)(r)|((unsigned long)((unsigned char)(g))<<8))|(((unsigned long)(unsigned char)(b))<<16))))
#define M_FONT                                        7L
#define M_FONT_X_SCALE                                8L
#define M_FONT_Y_SCALE                                9L
#define M_THICKNESS                                   10L
#define M_BACKGROUND_MODE                             12L
#define M_OPAQUE                                      0x01000058L
#define M_TRANSPARENT                                 0x01000059L
#define M_RGB_COLOR_MODE                              13L
#define M_RED_8_BIT                                   14L
#define M_GREEN_8_BIT                                 15L
#define M_BLUE_8_BIT                                  16L
#define M_BACK_RED_8_BIT                              17L
#define M_BACK_GREEN_8_BIT                            18L
#define M_BACK_BLUE_8_BIT                             19L

/************************************************************************/
/* MappGetError()                                                       */
/************************************************************************/
#define M_NULL_ERROR                                  0L
#define M_NO_ERROR                                    0L
#define M_CURRENT                                     1L
#define M_CURRENT_FCT                                 2L
#define M_CURRENT_SUB_NB                              3L
#define M_CURRENT_SUB                                 4L
#define M_CURRENT_SUB_1                               4L
#define M_CURRENT_SUB_2                               5L
#define M_CURRENT_SUB_3                               6L
#define M_GLOBAL                                      7L
#define M_GLOBAL_FCT                                  8L
#define M_GLOBAL_SUB_NB                               9L
#define M_GLOBAL_SUB                                  10L
#define M_GLOBAL_SUB_1                                10L
#define M_GLOBAL_SUB_2                                11L
#define M_GLOBAL_SUB_3                                12L
#define M_INTERNAL                                    13L
#define M_INTERNAL_FCT                                14L
#define M_INTERNAL_SUB_NB                             15L
#define M_INTERNAL_SUB                                16L
#define M_INTERNAL_SUB_1                              16L
#define M_INTERNAL_SUB_2                              17L
#define M_INTERNAL_SUB_3                              18L
#define M_PARAM_NB                                    19L
#define M_FATAL                                       40L
#define M_BUFFER_ID                                   41L
#define M_REGION_OFFSET_X                             42L
#define M_REGION_OFFSET_Y                             43L
#define M_REGION_SIZE_X                               44L
#define M_REGION_SIZE_Y                               45L

#define M_MODIFIED_BUFFER                             0x02000000L
#define M_UNHOOK                                      0x04000000L
#define M_PARAM_VALUE                                 0x08000000L
#define M_PARAM_TYPE                                  0x10000000L
#define M_MESSAGE                                     0x20000000L
#define M_ERROR                                       0x40000000L
#define M_NATIVE_ERROR                                0x80000000L
#define M_THREAD_RECURSIVE                            0x00800000L /* Bit field exclusive to M_TRACE  to M_PROCESSING        */
#define M_THREAD_CURRENT                              0x01000000L /*                        M_TRACE_START                   */
                                                                  /*                        M_TRACE_END                     */
                                                                  /*                        M_ERROR                         */
                                                                  /*                        M_MESSAGE                       */
                                                                  /*                        M_CURRENT to M_REGION_SIZE_Y    */
                                                                  /*                        M_MODIFIED_BUFFER               */
                                                                  /*                        M_UNHOOK                        */
#define M_ERROR_CURRENT                               (M_ERROR|M_CURRENT)
#define M_ERROR_GLOBAL                                (M_ERROR|M_GLOBAL)
#define M_ERROR_FATAL                                 (M_ERROR|M_FATAL)


/************************************************************************/
/* AppAlloc                                                             */
/************************************************************************/
#define M_USER_OBJECT                                 0x00000001L
#define M_SYSTEM_OBJECT                               0x00000002L
#define M_INHERITED                                   0x00000004L
#define M_NOT_INHERITED                               0x00000008L
#define M_BROADCASTED                                 0x00000010L
#define M_NOT_BROADCASTED                             0x00000020L

#define M_FUNCTION_NAME_SIZE                          32L
#define M_ERROR_FUNCTION_NAME_SIZE                    M_FUNCTION_NAME_SIZE
#define M_ERROR_MESSAGE_SIZE                          128L

#define M_NBFCTNAMEMAX                                445 /* max number of function codes     */
#define M_NBERRMSGMAX                                 100 /* max number of error messages     */
#define M_NBSUBERRMSGMAX                              10  /* max number of sub error messages */

#define M_FUNC_ERROR                                  (M_NBERRMSGMAX+1L) /* M_MFUNC error numbers   */


/************************************************************************/
/* MappHookFunction()                                                   */
/************************************************************************/
#define M_ERROR_CURRENT                               (M_ERROR|M_CURRENT)
#define M_ERROR_GLOBAL                                (M_ERROR|M_GLOBAL)
#define M_TRACE_START                                 1L
#define M_TRACE_END                                   2L
#define M_MODIFIED_BUFFER                             0x02000000L
#define M_ERROR_FATAL                                 (M_ERROR|M_FATAL)
#define M_UNHOOK                                      0x04000000L
#define M_THREAD_RECURSIVE                            0x00800000L /* Bit field exclusive to M_TRACE  to M_PROCESSING        */
#define M_THREAD_CURRENT                              0x01000000L /*                        M_TRACE_START                   */
#define M_INTERNAL_ALLOC                              0x00200000L /*                        M_TRACE_END                     */
#define M_INTERNAL_FREE                               0x00400000L /*                        M_ERROR                         */
                                                                  /*                        M_MESSAGE                       */
                                                                  /*                        M_CURRENT to M_REGION_SIZE_Y    */
                                                                  /*                        M_MODIFIED_BUFFER               */
                                                                  /*                        M_UNHOOK                        */

/************************************************************************/
/* MappGetHookInfo()                                                    */
/************************************************************************/
#define M_NULL_ERROR                                  0L
#define M_NO_ERROR                                    0L
#define M_CURRENT                                     1L
#define M_CURRENT_FCT                                 2L
#define M_CURRENT_SUB_NB                              3L
#define M_CURRENT_SUB                                 4L
#define M_CURRENT_SUB_1                               4L
#define M_CURRENT_SUB_2                               5L
#define M_CURRENT_SUB_3                               6L
#define M_GLOBAL                                      7L
#define M_GLOBAL_FCT                                  8L
#define M_GLOBAL_SUB_NB                               9L
#define M_GLOBAL_SUB                                  10L
#define M_GLOBAL_SUB_1                                10L
#define M_GLOBAL_SUB_2                                11L
#define M_GLOBAL_SUB_3                                12L
#define M_PARAM_NB                                    19L
#define M_BUFFER_ID                                   41L
#define M_REGION_OFFSET_X                             42L
#define M_REGION_OFFSET_Y                             43L
#define M_REGION_SIZE_X                               44L
#define M_REGION_SIZE_Y                               45L
#define M_OBJECT_ID                                   46L

#define M_MODIFIED_BUFFER                             0x02000000L
#define M_PARAM_VALUE                                 0x08000000L
#define M_PARAM_TYPE                                  0x10000000L
#define M_MESSAGE                                     0x20000000L



/************************************************************************/
/* MappInquire() / MappControl() Types                                  */
/************************************************************************/
#define M_VERSION                                     1L
#define M_TRACE                                       3L
#define M_PARAMETER                                   4L
#define M_MEMORY                                      5L
#define M_PROCESSING                                  6L
#define M_LAST_PLATFORM_USE                           7L
#define M_CURRENT_ERROR_HANDLER_PTR                   8L
#define M_CURRENT_ERROR_HANDLER_USER_PTR              9L
#define M_GLOBAL_ERROR_HANDLER_PTR                    10L
#define M_GLOBAL_ERROR_HANDLER_USER_PTR               11L
#define M_FATAL_ERROR_HANDLER_PTR                     12L
#define M_FATAL_ERROR_HANDLER_USER_PTR                13L
#define M_TRACE_START_HANDLER_PTR                     14L
#define M_TRACE_START_HANDLER_USER_PTR                15L
#define M_TRACE_END_HANDLER_PTR                       16L
#define M_TRACE_END_HANDLER_USER_PTR                  17L
#define M_IRQ_CONTROL                                 18L
#define M_ERROR_HANDLER_PTR                           19L
#define M_ERROR_HANDLER_USER_PTR                      20L
#define M_CURRENT_APPLICATION                         21L
#define M_MIL_UNIQUE_NUMBER                           23L
#define M_MIL_TRACE_FILENAME                          24L
#define M_FREE_ALL_DEFAULT                            25L
#define M_LICENSE_VALID_MODULES                       26L
#define M_LICENSE_UNLOCKED_MODULES                    M_LICENSE_VALID_MODULES
#define M_DEFAULT_VGA_SYSTEM                          27L
#define M_LCR_NUM                                     28L
#define M_LICENSE_TEMP_UNLOCKED_MODULES               29L
#define M_FORCE_DO_JOB                                30L
#define M_LST                                         31L
#define M_LSSTR                                       32L
#define M_LM6                                         33L
#define M_IN_VERSION                                  34L
#define M_LST_STR                                     35L
#define M_LIC_ADD_RES                                 36L
#define M_LICENSE_MODULES                             37L
#define M_MILCE_ALLOC_IN_DMA_SIZE                     40L
#define M_MILCE_ALLOC_IN_MMF_SIZE                     41L
#define M_MILCE_ALLOC_IN_MMF_AUTO_COMMIT              42L


/************************************************************************/
/* Licensing: Module information                                        */
/************************************************************************/
#define M_LICENSE_LITE               0x00000001L //0L
#define M_LICENSE_DEBUG              0x00000002L //1L
#define M_LICENSE_IM                 0x00000004L //2L
#define M_LICENSE_CODE               0x00000008L //3L
#define M_LICENSE_MEAS               0x00000010L //4L
#define M_LICENSE_PAT                0x00000020L //5L
#define M_LICENSE_MOD                0x00000040L //6L
#define M_LICENSE_JPEG2000           0x00000080L //7L
#define M_LICENSE_BGA                0x00000100L //8L
#define M_LICENSE_BLOB               0x00000200L //9L
#define M_LICENSE_CAL                0x00000400L //10L
#define M_LICENSE_OCR                0x00000800L //11L
#define M_LICENSE_JPEGSTD            0x00001000L //12L
#define M_LICENSE_INSP3X             0x00200000L //21L
#define M_LICENSE_INSP40             0x00400000L //22L
#define M_LICENSE_METEOR_II_1394     0x00800000L //23L
#define M_LICENSE_EDGE               0x01000000L //24L

#define M_LCRM                                        64L
/* Reserve next 31 values               from          65L*/
/*                                      to            95*/
#define M_LCRT                                        96L
/* Reserve next 31 values               from          97L*/
/*                                      to           127L*/
#define M_LCRID                                      128L
/* Reserve next 31 values               from         129L*/
/*                                      to           159L*/
#define M_LCRM_NOT                                   164L
/* Reserve next 31 values               from         165L*/
/*                                      to           195*/

#define M_LICENSE_FINGERPRINT                         224L
/* Reserve next 31 values               from          225L*/
/*                                      to            255L*/
#define M_MATROX_VGA_FINGERPRINT                      (M_LICENSE_FINGERPRINT+2)
#define M_ETHERNET_FINGERPRINT                        (M_LICENSE_FINGERPRINT+7)
#define M_HARD_ID_KEY_FINGERPRINT                     (M_LICENSE_FINGERPRINT+8)
#define M_METEOR_II_1394_FINGERPRINT                  (M_LICENSE_FINGERPRINT+21)
#define M_ORION_FINGERPRINT                           (M_LICENSE_FINGERPRINT+22)
#define M_CORONA_II_FINGERPRINT                       (M_LICENSE_FINGERPRINT+23)
#define M_MATROX_BOARD_FINGERPRINT                    (M_LICENSE_FINGERPRINT+31)

#define M_MODIFIED_BUFFER_HANDLER_PTR                 0x10000000L   // Must not interfere with M_ERROR
#define M_MODIFIED_BUFFER_HANDLER_USER_PTR            0x20000000L   // Must not interfere with M_ERROR
#define M_OBJECT_TYPE                                 0x80000000L


/************************************************************************/
/* MWrite() / MpatRead() Types                                          */
/************************************************************************/
#define M_FILE                                        25L


/************************************************************************/
/* MappInquire() / MappControl() Values                                 */
/************************************************************************/
#define M_PARAMETER_CHECK                             1L
#define M_PRINT_DISABLE                               0L
#define M_PRINT_ENABLE                                1L
#define M_CHECK_DISABLE                               2L
#define M_CHECK_ENABLE                                3L
#define M_COMPENSATION_DISABLE                        4L
#define M_COMPENSATION_ENABLE                         5L
#define M_PRINT_INTERNAL                              6L
#define M_THREAD_RECURSIVE                            0x00800000L /* Bit field exclusive to M_TRACE  to M_PROCESSING        */
#define M_THREAD_CURRENT                              0x01000000L /*                        M_TRACE_START                   */
                                                                  /*                        M_TRACE_END                     */
                                                                  /*                        M_ERROR                         */
                                                                  /*                        M_MESSAGE                       */
                                                                  /*                        M_CURRENT to M_REGION_SIZE_Y    */
                                                                  /*                        M_MODIFIED_BUFFER               */
                                                                  /*                        M_UNHOOK                        */

#define M_TIMER_ALLOC                                 1L
#define M_TIMER_FREE                                  2L
#define M_TIMER_RESOLUTION                            3L
#define M_TIMER_RESET                                 4L
#define M_TIMER_READ                                  5L
#define M_TIMER_WAIT                                  6L
#define M_TIMER_COMPENSATION                          7L
#define M_TIMER_MIL_NOP                               0x8000L


/************************************************************************/
/* MappModify()                                                         */
/************************************************************************/
#define M_SWAP_ID                1L

/************************************************************************/
/* Binary functions in BLOB module.                                     */
/************************************************************************/
#define M_LENGTH                                      0x00002000L

/************************************************************************/
/* MmeasCalculate(), MmeasGetResult(), MpatGetResult() */
/************************************************************************/
#define M_ANGLE                                       0x00000800L
#define M_ORIENTATION                                 0x00002400L

/************************************************************************/
/* MblobControl() and/or MblobInquire() values and MmeasControl()       */
/************************************************************************/
#define M_PIXEL_ASPECT_RATIO                          5L

/************************************************************************/
/* MfuncPrintMessage() defines                                          */
/************************************************************************/
#define M_RESP_YES                                    1L
#define M_RESP_NO                                     2L
#define M_RESP_CANCEL                                 4L
#define M_RESP_YES_NO                                 (M_RESP_YES|M_RESP_NO)
#define M_RESP_YES_NO_CANCEL                          (M_RESP_YES|M_RESP_NO|M_RESP_CANCEL)

/************************************************************************/
/* MfuncCalibrationInfo() defines                                       */
/************************************************************************/
#define M_COPY_CALIBRATION_INFO              3L
#define M_COMPARE_CALIBRATION_INFO           4L

#define M_GET_CALIBRATION_ID                 5L
#define M_GET_CORRECTION_STATE               7L
#define M_GET_PARENT_OFFSET_X                8L
#define M_GET_PARENT_OFFSET_Y                9L

#define M_DELETE_CALIBRATION_ID             10L
#define M_DELETE_OBJECT_ID                  11L

#define M_ADD_CALIBRATION_USE               20L
#define M_REMOVE_CALIBRATION_USE            21L
#define M_USE_CALIBRATION                   22L

#define M_AUTO_TRANSMISSION                 30L
#define M_SET_AUTO_TRANSMISSION             31L

#define M_DISABLE_OBJECT                    40L
#define M_ENABLE_OBJECT                     41L
#define M_OBJECT_ENABLED                    42L
#define M_FORCE_DISABLING_LEVEL             43L

#define M_SET_TRANSFORM_IMAGE_PTR           50L
#define M_TRANSFORM_IMAGE                   51L

/************************************************************************/
/* MfuncAlloc defines                                                   */
/************************************************************************/
#define M_USER_MODULE_1                     0x8000E000
#define M_USER_MODULE_2                     0x8000E200
#define M_USER_MODULE_3                     0x8000E400
#define M_USER_MODULE_4                     0x8000E600
#define M_USER_MODULE_5                     0x8000E800
#define M_USER_MODULE_6                     0x8000EA00
#define M_USER_MODULE_7                     0x8000EC00
#define M_USER_MODULE_8                     0x8000EE00
#define M_USER_MODULE_9                     0x8000F000
#define M_USER_MODULE_10                    0x8000F200

/************************************************************************/
/* MfuncControl/MfuncInquire() defines                                  */
/************************************************************************/


/************************************************************************/
/* Mfile() defines                                                      */
/************************************************************************/
#define M_NO_MEMORY                                   1L

/************************************************************************/
/* Special defines required to pass a pointer to a function that needs  */
/* a double. (use in McalControl to set a user string in the context)   */
/************************************************************************/
#define M_PTR_TO_DOUBLE(ptr)            ((double) MPtrToInt((void*)(ptr)))
#define M_STRING_TO_DOUBLE(ptr)         M_PTR_TO_DOUBLE((ptr))


/************************************************************************/
/* MIL OPTIONAL COMPILE DEFINES prefixes */
/************************************************************************/

#ifndef __midl /* IDL compiler used by ActiveMIL */

#if M_MIL_USE_DOS_32
// Much more to define for MS-DOS library generation under DOS_32
   #define MCTYPE                         // Class header type on DOS_32
   #define MFTYPE        cdecl            // Exported Function type (16 bits)
   #define MFHOOKTYPE    cdecl            // Same as MFTYPE, for internal use only.
   #define MFTYPE32                       // Exported Function type (32 bits)
   #define MFCTYPE       cdecl            // Exported C Function type (16 bits)
   #define MFCTYPE32                      // Exported C Function type (32 bits)
   #define MFTYPEHT                       // Non Exported Function type
   #define MPTYPE                         // Pointer and Reference type
   #define MFINLINE      inline           // Inline function type
   #define MHUGETYPE                      // To force HUGE pointers
   #define MFARTYPE                       // To force FAR type pointers
   #define MINTFTYPE     MFTYPE           // Interrupt Function type (16 bits)
   #define MREGTYPE      register         // Register type variables
   #define MCAPICSTTYPE  double           // constant type of 4.0 CAPI functions
#elif M_MIL_USE_QNX
// Much more to define for MS-DOS library generation under DOS_32
   #define MCTYPE                         // Class header type on DOS_32
   #define MFTYPE                         // Exported Function type (16 bits)
   #define MFHOOKTYPE                     // Same as MFTYPE, for internal use only.
   #define MFTYPE32                       // Exported Function type (32 bits)
   #define MFCTYPE                        // Exported C Function type (16 bits)
   #define MFCTYPE32                      // Exported C Function type (32 bits)
   #define MFTYPEHT                       // Non Exported Function type
   #define MPTYPE                         // Pointer and Reference type
   #define MFINLINE      inline           // Inline function type
   #define MHUGETYPE                      // To force HUGE pointers
   #define MFARTYPE                       // To force FAR type pointers
   #define MINTFTYPE                      // Interrupt Function type (16 bits)
   #define MREGTYPE      register         // Register type variables
   #define MCAPICSTTYPE  double           // constant type of 4.0 CAPI functions
#elif M_MIL_USE_WINDOWS
// Much more to define for MS-WINDOWS NT 3.1 library generation under NT
   #define MCTYPE                          // Class header type on NT
   #ifdef _MSC_VER
      #ifdef WINDOWS_95_DRIVER_COMPILATION
         #define MFTYPE    _stdcall              // Exported Function type (32 bits)
         #define MFHOOKTYPE _stdcall             // Same as MFTYPE, for internal use only.
         #define MFTYPE32                        // Exported Function type (32 bits)
         #define MFCTYPE   _stdcall              // Exported C Function type (32 bits)
         #define MFCTYPE32                       // Exported C Function type (32 bits)
      #else
         #define MFTYPE    _stdcall              // Exported Function type (32 bits)
         #define MFHOOKTYPE _stdcall             // Same as MFTYPE, for internal use only.
         #define MFTYPE32                        // Exported Function type (32 bits)
         #define MFCTYPE   _stdcall              // Exported C Function type (32 bits)
         #define MFCTYPE32                       // Exported C Function type (32 bits)
      #endif
   #endif
   #ifdef __TURBOC__
      #define MFTYPE    _stdcall _export _import   // Exported Function type (32 bits)
      #define MFHOOKTYPE _stdcall _export __import // Same as MFTYPE, for internal use only.
      #define MFTYPE32                             // Not used
      #define MFCTYPE   _stdcall _export           // Exported C Function type (32 bits)
      #define MFCTYPE32                            // Not used
   #endif
   #define MFTYPEHT    _stdcall            // Non Exported Function type
   #define MPTYPE                          // Pointer and Reference type
   #define MFINLINE    inline              // Inline function type
   #define MHUGETYPE                       // To force HUGE pointers
   #define MFARTYPE                        // To force FAR type pointers
   #define MINTFTYPE   _stdcall            // Interrupt Function type (16 bits)
   #define MREGTYPE    register            // Register type variables
   #define MCAPICSTTYPE double             // constant type of 4.0 CAPI functions
#elif M_MIL_USE_PPC
// Much more to define for MIL generation on PPC
   #define MCTYPE                         // Class header type on DOS_32
   #define MFTYPE                         // Exported Function type (16 bits)
   #define MFHOOKTYPE                     // Same as MFTYPE, for internal use only.
   #define MFTYPE32                       // Exported Function type (32 bits)
   #define MFCTYPE                        // Exported C Function type (16 bits)
   #define MFCTYPE32                      // Exported C Function type (32 bits)
   #define MFTYPEHT                       // Non Exported Function type
   #define MPTYPE                         // Pointer and Reference type
   #define MFINLINE      inline           // Inline function type
   #define MHUGETYPE                      // To force HUGE pointers
   #define MFARTYPE                       // To force FAR type pointers
   #define MINTFTYPE     MFTYPE           // Interrupt Function type (16 bits)
   #define MREGTYPE      register         // Register type variables
   #define MCAPICSTTYPE  double           // constant type of 4.0 CAPI functions
#else
   #error Operating system not supported in Mil.h!
#endif

/************************************************************************/
/* MIL OS support                                                       */
/************************************************************************/

#ifndef __midl /* IDL compiler used by ActiveMIL */
#include <milos.h>
#endif

/************************************************************************/
/* MIL error messages */
#if M_MIL_USE_ERROR_MESSAGE
#include <milerr.h>
#endif

/************************************************************************/
/* MIL command decoder functions */
#include <mildec.h>

/************************************************************************/
/* MIL library prototypes */
#include <milproto.h>

/************************************************************************/
/* MIL blob package defines prototypes */
#if M_MIL_USE_BLOB
#include <milblob.h>
#endif

/************************************************************************/
/* MIL pat package defines prototypes */
#if M_MIL_USE_PAT
#include <milpat.h>
#endif

/************************************************************************/
/* MIL ocr package defines prototypes */
#if M_MIL_USE_OCR
#include <milocr.h>
#endif

/************************************************************************/
/* MIL meas package defines prototypes */
#if M_MIL_USE_MEAS
#include <milmeas.h>
#endif

/************************************************************************/
/* MIL cal package defines prototypes */
#if M_MIL_USE_CAL
#include <milcal.h>
#endif

/************************************************************************/
/* MIL code package defines prototypes */
#if M_MIL_USE_CODE
#include <milcode.h>
#endif

/************************************************************************/
/* MIL geo and MIL edge package defines prototypes */
#if M_MIL_USE_MOD
#include <milmod.h>
#include <miledge.h>
#endif

/************************************************************************/
/* MIL Pulsar specific defines */
#if M_MIL_USE_PULSAR
#include <pulsar.h>
#endif

/************************************************************************/
/* MIL GENESIS specific defines */
#if M_MIL_USE_GENESIS
#include <genesis.h>
#endif

/************************************************************************/
/* MIL CORONA specific defines */
#if M_MIL_USE_CORONA
#include <corona.h>
#endif

/************************************************************************/
/* MIL METEOR2 specific defines */
#if M_MIL_USE_METEOR_II
#include <meteor2.h>
#endif

/************************************************************************/
/* MIL METEOR2DIG specific defines */
#if M_MIL_USE_METEOR_II_DIG
   #include <genesis.h>
#endif

/************************************************************************/
/* MIL METEOR2CL specific defines */
#if M_MIL_USE_METEOR_II_CL
   #include <genesis.h>
#endif

/************************************************************************/
/* Make sure that M_MIL_USE_NT_WINDOWS is not defined (obsolete)        */
#ifdef M_MIL_USE_NT_WINDOWS
   #error M_MIL_USE_NT_WINDOWS is obsolete use M_MIL_USE_WINDOWS instead
#endif

#endif
#endif /* __midl */
