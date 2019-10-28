function make_mexipc()
mex ipc_connect.c
mex ipc_close_window.c
mex CloseShareMem4GUI.c
mex SetShareMem4GUI.c
mex WriteShareMem4GUI.c
mex CreateProcess.c
%make ipc_send.c
%mex -v -f "D:\shoji\OpenGL_Mex\hogeOpt2.bat" CreateProcessTest.c

