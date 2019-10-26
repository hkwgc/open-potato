CLFALGS = -O3 -wall
CC   = gcc
MAKEFILE = makefile
MAKE = gmake
LOADNAME = hoge
LD       = $(CC)
LIBS = 

#########  Library version  #########
IFILE = 


.c.o    :
	$(CC) -c $(CFLAGS) $(INCLUDE) $<

.PRECIOUS : $(LOADNAME) ;

etags	:
	etags /usr/local/matlab7/toolbox/matlab/*/*.m *.m */*.m */*/*.m \
	/home/shoji/OpticalTopography/spm99/*.m \
	/home/shoji/OpticalTopography/TSP-G_V202_SP/*.m \
	/home/shoji/OpticalTopography/TSP_V205/*.m
clean   :
	-rm -f *.asv */*.asv
	-rm -f *.log */*.log */*/*.log OSP_Debug.txt
	-rm -f $(IFILE) *~ */*~ */*/*~ *.csv $(LOADNAME) hoge* 
	-rm -f ospData/sd_*.m ospData/gd_*.m
cleanall:
	${MAKE} clean
	/bin/rm -rf old ospData_L test
	/bin/rm -rf CVS */CVS */*/CVS */*/*/CVS */*/*/*/CVS 
	/bin/rm -rf preprocessor/dust
	/bin/rm -rf DataGroupMarge
	/bin/rm -f ospData/ProjectData.mat ospData/SettingInfo.mat
	/bin/rm -f 050603_1052_02HB.TXT
	/bin/rm -f Analysis/ETG7000anova16.m
	/bin/rm -f Analysis/osp_anova.m
	/bin/rm -f Analysis/osp_peacksearch2.m
	/bin/rm -f BlockFilter/ETG7000motion_check7.m
	/bin/rm -f tmp* hoge* peack_* test* *.xls TAGS
	/bin/rm -f *.p */*.p */*/*.p */*/*/*.p
	/bin/rm -rf PluginDir/MyTest
	/bin/rm -rf TestSuite/ExampleProject1/OspDataDir
	/bin/rm -rf P3 Schedule chk_OSP_DATA.perl ck_with_func.sh old  ospData_L \
	test Analysis/Data_AnalyzedData.m \
	Analysis/ETG7000anova16.m \
	Analysis/osp_anova.m \
	Analysis/osp_distribute.m.bk \
	Analysis/osp_peaksearch2.m \
	BlockFilter/ETG7000motion_check7.m \
	BlockFilter/tmp \
	PluginDir/Example \
	PluginDir/HelloWorld \
	PluginDir/MaxDivide.m \
	PluginDir/MyTest \
	PluginDir/PlugInWrap_Multitest.m \
	PluginDir/PlugInWrap_PE2.m \
	PluginDir/PlugInWrap_TDDICA.m \
	PluginDir/PlugInWrap_TEST_PLOT_BLOCK.m \
	PluginDir/PlugInWrap_TemporalityFileIO.m \
	PluginDir/PlugInWrap_Test1.m \
	PluginDir/PlugInWrap_template.m \
	PluginDir/TDDICA \
	PluginDir/dust \
	PluginDir/mextest1 \
	PluginDir/TTest2 \
	PluginUserfile/ck.sh \
	ProbePosition/testDir \
	ProbePosition/test_clickdata.m \
	UserCommand/osp_uc_check2.bk \
	UserCommand/wk \
	UserCommand/wk2 \
	ospData/DataFileInfo.mat \
	ospData/FilterBookMarkData.mat \
	ospData/GUI_COLOR_FILE0.mat \
	ospData/GUI_COLOR_FILE1.mat \
	ospData/ProjectData.mat \
	ospData/SettingInfo.mat \
	preprocessor/dust \
	preprocessor/preproETG7000_2.m \
	preprocessor/test.fig \
	user_tools/pt.m \
	user_tools/uiputfile_osp.m.bk

cvsupdate:
	@echo "Update File" 
	cvs -q update | grep "^M"
cvsunknown:
	cvs -q update | grep "^\?"
dbg	:
	${MAKE} clean
	${MAKE} CC="gcc" CFLAGS="-g -Wall"
mkzip:
	rm -rf /home/shoji/OpticalTopography/dust/OSP OSP.tar.gz
	cp -pr /home/shoji/OpticalTopography/OSP /home/shoji/OpticalTopography/dust/OSP
	cd /home/shoji/OpticalTopography/dust/OSP; ${MAKE} cleanall
	cd /home/shoji/OpticalTopography/dust; \
	gtar zcf /home/shoji/OpticalTopography/OSP/OSP.tar.gz OSP 
new30:
	find ./ -name '*.m' -cmin -30

verlistnow: 
	cvs -q status >verlist.txt
	cp -p verlist.txt cvs_status/verlist.txt.bk
verlistck: 
	cvs -q status >verlist.txt
	diff verlist.txt cvs_status/verlist.txt.bk
check1102: verlistnow
	grep Repository verlist.txt > verlistXX.txt
	grep Repository cvs_status/R20061102.cvs_status > hoge.txt
	@ echo "----------------------------------------------"
	@ echo "Difference between 20061102 and your Directory"
	@ echo "----------------------------------------------"
	/usr/bin/diff hoge.txt verlistXX.txt
	/bin/rm -f hoge.txt verlistXX.txt
mod_kidachi:
	cvs -q log | grep -E 'kidachi|Working' | grep -B 1 kidachi 
mod_yyamada:
	cvs -q log | grep -E 'yyamada|Working' | grep -B 1 yyamada
mod_shoji:
	cvs -q log | grep -E 'shoji|Working' | grep -B 1 shoji
