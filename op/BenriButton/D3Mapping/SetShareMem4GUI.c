#include <windows.h>
#include "mex.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define SHM_SIZE 5120

//[Shmem hShare]=SetShareMem4GUI(Aso_size,HS_Vertex,HS_Edge,BS_Vertex,BS_Edge)
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{  
	double *Aso_size;
	double *d_p;
	char *HS_Vertex;
	char *HS_Edge;
	char *BS_Vertex;
	char *BS_Edge;
	HANDLE hShm;
	void *p;
	char *c_p;
	double *Shmem, *hShare;
	char buf[1024];
	int work;

  /* Check num of arg */
	if (nrhs!=5){
		mexErrMsgTxt("Error : 5 input parameters not specified.");
	} else if (nlhs !=2){
		mexErrMsgTxt("Error : 2 output parameters not specified.");
	}


	work = (int)mxGetNumberOfElements(prhs[0]);
	if(work!=9) {
		mexErrMsgTxt("Affine-Matrix Element-Number is less than 9.");
	}

	Aso_size = calloc(9, sizeof(double));
	Aso_size = mxGetPr(prhs[0]);
/*
sprintf(buf, "Aso_size[0]=(%e,%e,%e)\n", Aso_size[0],Aso_size[1],Aso_size[2]);
mexPrintf(buf);
sprintf(buf, "Aso_size[1]=(%e,%e,%e)\n", Aso_size[3],Aso_size[4],Aso_size[5]);
mexPrintf(buf);
sprintf(buf, "Aso_size[2]=(%e,%e,%e)\n", Aso_size[6],Aso_size[7],Aso_size[8]);
mexPrintf(buf);
*/
	HS_Vertex = calloc(1024, sizeof(char));
	HS_Vertex = mxArrayToString(prhs[1]);
	HS_Edge = calloc(1024, sizeof(char));
	HS_Edge = mxArrayToString(prhs[2]);
	BS_Vertex = calloc(1024, sizeof(char));
	BS_Vertex = mxArrayToString(prhs[3]);
	BS_Edge = calloc(1024, sizeof(char));
	BS_Edge = mxArrayToString(prhs[4]);
/*
sprintf(buf, "HS_Vertex=%s\n", HS_Vertex);
mexPrintf(buf);
sprintf(buf, "HS_Edge=%s\n", HS_Edge);
mexPrintf(buf);
sprintf(buf, "BS_Vertex=%s\n", BS_Vertex);
mexPrintf(buf);
sprintf(buf, "BS_Edge=%s\n", BS_Edge);
mexPrintf(buf);
*/

	hShm = CreateFileMappingA((HANDLE) -1, NULL, PAGE_READWRITE, 0, SHM_SIZE, "ShareMem4GUI");
	if (hShm == NULL) {
		mexErrMsgTxt("CreateFileMappingA failed.");
	}

	p = MapViewOfFile(hShm, FILE_MAP_WRITE, 0, 0, 0);
	if (p == NULL) {
		mexErrMsgTxt("MapViewOfFile failed.");
	}

//sprintf(buf, "hShm=%x,%d\n", hShm,hShm);
//mexPrintf(buf);
//sprintf(buf, "p=%x,%d\n", p,p);
//mexPrintf(buf);

	memcpy(((char *)p+   0), Aso_size, 9*sizeof(double));
//sprintf(buf, "memcpy(((char *)p+   0), Aso_size, 9*sizeof(double));\n");
//mexPrintf(buf);
	strcpy(((char *)p+1024), HS_Vertex);
//sprintf(buf, "strcpy(((char *)p+1024), HS_Vertex);\n");
//mexPrintf(buf);

	strcpy(((char *)p+2048), HS_Edge);
//sprintf(buf, "strcpy(((char *)p+2048), HS_Edge);\n");
//mexPrintf(buf);

	strcpy(((char *)p+3072), BS_Vertex);
//sprintf(buf, "strcpy(((char *)p+3072), BS_Vertex);\n");
//mexPrintf(buf);

	strcpy(((char *)p+4096), BS_Edge);
//sprintf(buf, "strcpy(((char *)p+4096), BS_Edge);\n");
//mexPrintf(buf);

/*
	if (!UnmapViewOfFile(p)) {
		CloseHandle(hShm);
		mexErrMsgTxt("UnmapViewOfFile failed.");
	}

	if (!CloseHandle(hShm)) {
		mexErrMsgTxt("CloseHandle failed.");
	}
*/
	
	Shmem = mxCalloc(1,sizeof(double));
	hShare = mxCalloc(1,sizeof(double));
	*Shmem=0.0; *hShare=0.0;
    memcpy(Shmem,&p,sizeof(void *));
    memcpy(hShare,&hShm,sizeof(HANDLE));
//sprintf(buf, "hShare=%lx\n", *hShare);
//mexPrintf(buf);
//sprintf(buf, "Shmem=%lx\n", *Shmem);
//mexPrintf(buf);

    plhs[0] = mxCreateDoubleScalar(*Shmem);
    plhs[1] = mxCreateDoubleScalar(*hShare);

}
