#define XMD_H
#include "jpeglib\\jpeglib.h"


BOOL JpegFromDib(HANDLE     hDib,     //Handle to DIB
                 int        nQuality, //JPEG quality (0-100)
                 CString    csJpeg,   //Pathname to target jpeg file
                 CString*   pcsMsg);  //Error msg to return


BOOL DibToSamps(HANDLE                      hDib,
                int                         nSampsPerRow,
                struct jpeg_compress_struct cinfo,
                JSAMPARRAY                  jsmpPixels,
                CString*                    pcsMsg);


BOOL BitsToSamps(LPVOID                      lpBits,
                int                         nSampsPerRow,
                struct jpeg_compress_struct cinfo,
                JSAMPARRAY                  jsmpPixels,
                CString*                    pcsMsg);

BOOL JpegFromBits(LPVOID     lpbits,     //Handle to DIB
                 int        nQuality, //JPEG quality (0-100)
                 CString    csJpeg,   //Pathname to jpeg file
                 CString*   pcsMsg);   //Error msg to return

BOOL JpegFromRaster(unsigned char*     lpbits,     //Handle to DIB
                    int        nQuality, //JPEG quality (0-100)
					int        width,
					int        height,
					int        nComponents,
                    CString    csJpeg,   //Pathname to jpeg file
                    CString*   pcsMsg);   //Error msg to return

RGBQUAD QuadFromWord(WORD b16);