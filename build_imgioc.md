
# Creating Imaging IOC from scratch

## Install RPMs

	sudo yum install gtk-doc glibmm24-devel


## Build aravis

Will install into __/usr/local__.

	cd $HOME
	curl -L -o ARAVIS_0_4_1.tar.gz https://github.com/AravisProject/aravis/archive/ARAVIS_0_4_1.tar.gz
	tar xf ARAVIS_0_4_1.tar.gz
	cd aravis-ARAVIS_0_4_1
	./autogen.sh
	make -j
	sudo make install

## Get the NG3E code

	git clone https://github.com/hinxx/ng3e.git
	cd ng3e/packages

## Build base

	make PKG=base RCP=R3.15.4 release

## Build packages

	make PKG=asyn RCP=ESS-R4-32+1 release
	make PKG=autosave RCP=R5-8 release
	make PKG=busy RCP=R1-6-1 release
	make PKG=sscan RCP=R2-10-2 release
	make PKG=calc RCP=R5-4-2 release
	make PKG=adsupport RCP=ESS-R1-3+1 release
	make PKG=adcore RCP=ESS-R3-1+1 release
	make PKG=adaravis RCP=ESS-master+2 release
	make PKG=adtlccs RCP=master+1 release

## Build IOC

	make PKG=imgioc RCP=master+1 release

## Configure IOC

Open the __$HOME/ng3e/root/R3.15.4/iocs/imgioc-master+1/iocBoot/iocImg/st.cmd__ and:

* adjust the camera ID:

	aravisCameraConfig("$(PORT)", "Allied Vision Technologies-50-0503355057")
	
* adjust the spectrometer ID:

	epicsEnvSet("RSCSTR", "USB::0x1313::0x8087::M00407309::RAW")

Start the IOC:

	LD_LIBRARY_PATH=/usr/local/lib ../../bin/linux-x86_64/imgApp st.cmd
