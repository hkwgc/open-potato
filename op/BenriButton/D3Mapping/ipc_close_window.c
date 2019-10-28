#include <windows.h>
#include "mex.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static const int WM_SEND_LETTER_FOR_GUI = WM_APP + 1;
static const int WM_RECEIVE_LETTER_FROM_GUI = WM_APP + 2;

//ipc_close_window()
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
	WPARAM wParam;
	LPARAM lParam;
	WORD HiW,LoW,HiL,LoL;
	HiW=-1;
	LoW=0; HiL=0; LoL=0;
	wParam = MAKEWPARAM(LoW, HiW);
	lParam = MAKELPARAM(LoL, HiL);
	/* Check num of arg */
	if (nrhs!=0){
		mexErrMsgTxt("too many input argument.: no-argument requred.\n");
	} else if (nlhs !=0){
		mexErrMsgTxt("too many output argument.: no-argument requred.\n");
	}

	{
	HWND		hWnd;
	char buf[256] = {0};

	hWnd = FindWindow(NULL, "POTAToOpenGLControl");
	if (hWnd != NULL) {
	PostMessage(hWnd, WM_SEND_LETTER_FOR_GUI, wParam, lParam);
	}

  }
}
