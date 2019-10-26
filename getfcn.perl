#!/usr/bin/perl

$count = 2;
$step = 1;
$line0  = 1;
$commode = 0;

while (<>){
    #if ( /^function*=\s*(\w*)[(]/ ) {
    if ( /^function*(\w*)[(]*/ ) {
	printf("\n\n");
	printf("\</pre\>\</code\>");
	printf("\<h3\>\<font color=\"#0000FF\"\> Line : $line0\</font\>\</h3\>\<br\>\n");
	printf("\<code\>\<pre\>");
	print ;
	$commode = 1;
	} else {
	    if ( /^%/){
		if ($commode==1) {
		    print ;
		}
	    } else {
		$commode = 0;
	    }
	}
    $line0++;
}
