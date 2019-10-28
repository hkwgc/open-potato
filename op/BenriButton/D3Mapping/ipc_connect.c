#include <windows.h>
#include "mex.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static const int WM_SEND_LETTER_FOR_GUI = WM_APP + 1;
static const int WM_RECEIVE_LETTER_FROM_GUI = WM_APP + 2;

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
  double x,y;
  WPARAM wParam;
  LPARAM lParam;
  WORD HiW,LoW,HiL,LoL;
  
//  HiW=-10; LoW=1; HiL=100; LoL=10;
//  wParam = MAKEWPARAM(LoW, HiW);
//  lParam = MAKELPARAM(LoL, HiL);
  
  /* Check num of arg */
  if (nrhs!=4){
    mexErrMsgTxt("Errnor 1");
  } else if (nlhs >1){
    mexErrMsgTxt("Error : Too many arg");
  }
  
  x=mxGetScalar(prhs[0]);
  y=2*x;
  
  HiW=mxGetScalar(prhs[0]);
  LoW=mxGetScalar(prhs[1]);
  HiL=mxGetScalar(prhs[2]);
  LoL=mxGetScalar(prhs[3]);
  wParam = MAKEWPARAM(LoW, HiW);
  lParam = MAKELPARAM(LoL, HiL);

  {
    HWND		hWnd;
    int dummy;
	char buf[256] = {0};
	
    hWnd = FindWindow(NULL, "POTAToOpenGLControl");
    if (hWnd == NULL) { // do nothing
 //   	SecureZeroMemory(buf, sizeof(buf));
//		sprintf(buf, "can not find %s\n", "POTAToOpenGLControl");
//		mexErrMsgTxt(buf);
	} else {
		PostMessage(hWnd, WM_SEND_LETTER_FOR_GUI, wParam, lParam);
//		PostMessage(hWnd, WM_SEND_LETTER_FOR_GUI, 0, 0);
	}
	dummy = (int)hWnd;
    plhs[0] = mxCreateDoubleScalar((double) dummy);
  }
}
