s=serial('COM5', 'BaudRate', 115200, 'Parity', 'none');
fopen(s);
patriot_test(s,2000);

fclose(s);
clear s;
