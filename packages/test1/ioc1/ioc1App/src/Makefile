TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#=============================
# Build the IOC application

PROD_IOC = ioc1
# ioc1.dbd will be created and installed
DBD += ioc1.dbd

# ioc1.dbd will be made up from these files:
ioc1_DBD += base.dbd

# Include dbd files from all support applications:
#ioc1_DBD += xxx.dbd

# Add all the support libraries needed by this IOC
#ioc1_LIBS += xxx

# ioc1_registerRecordDeviceDriver.cpp derives from ioc1.dbd
ioc1_SRCS += ioc1_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
ioc1_SRCS_DEFAULT += ioc1Main.cpp
ioc1_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#ioc1_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
ioc1_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

