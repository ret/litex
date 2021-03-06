ifeq ($(TRIPLE),--native--)
TARGET_PREFIX=
else
TARGET_PREFIX=$(TRIPLE)-
endif

RM ?= rm -f
PYTHON ?= python3

ifneq ($(CPU), lm32)
LTO = 0
else
LTO = 1
endif

ifeq ($(CLANG), 1)
CC_normal      := clang -target $(TRIPLE) -integrated-as
CX_normal      := clang++ -target $(TRIPLE) -integrated-as
else
CC_normal      := $(TARGET_PREFIX)gcc -std=gnu99
CX_normal      := $(TARGET_PREFIX)g++
endif
ifneq ($(LTO), 1)
AR_normal      := $(TARGET_PREFIX)gcc-ar
else
AR_normal      := $(TARGET_PREFIX)ar
endif
LD_normal      := $(TARGET_PREFIX)ld
OBJCOPY_normal := $(TARGET_PREFIX)objcopy

CC_quiet      = @echo " CC      " $@ && $(CC_normal)
CX_quiet      = @echo " CX      " $@ && $(CX_normal)
AR_quiet      = @echo " AR      " $@ && $(AR_normal)
LD_quiet      = @echo " LD      " $@ && $(LD_normal)
OBJCOPY_quiet = @echo " OBJCOPY " $@ && $(OBJCOPY_normal)

ifeq ($(V), 1)
	CC = $(CC_normal)
	CX = $(CX_normal)
	AR = $(AR_normal)
	LD = $(LD_normal)
	OBJCOPY = $(OBJCOPY_normal)
else
	CC = $(CC_quiet)
	CX = $(CX_quiet)
	AR = $(AR_quiet)
	LD = $(LD_quiet)
	OBJCOPY = $(OBJCOPY_quiet)
endif

# http://scottmcpeak.com/autodepend/autodepend.html
# Generate *.d Makefile dependencies fragments, include using;
# -include $(OBJECTS:.o=.d)
DEPFLAGS += -MD -MP

# Toolchain options
#
INCLUDES    = -I$(SOC_DIRECTORY)/software/include/base -I$(SOC_DIRECTORY)/software/include -I$(SOC_DIRECTORY)/common -I$(BUILDINC_DIRECTORY)
COMMONFLAGS = $(DEPFLAGS) -Os $(CPUFLAGS) -g3 -fomit-frame-pointer -Wall -fno-builtin -nostdinc $(INCLUDES)
COMMONFLAGS += -ffunction-sections -fdata-sections -nostartfiles -nostdlib -nodefaultlibs
ifeq ($(LTO), 1)
COMMONFLAGS += -flto -fuse-linker-plugin
endif
CFLAGS   = $(COMMONFLAGS) -fexceptions -Wstrict-prototypes -Wold-style-definition -Wmissing-prototypes
CXXFLAGS = $(COMMONFLAGS) -std=c++11 -I$(SOC_DIRECTORY)/software/include/basec++ -fexceptions -fno-rtti -ffreestanding
LDFLAGS  = -nostdlib -nodefaultlibs -Os $(CPUFLAGS) -L$(BUILDINC_DIRECTORY)

define compilexx
$(CX) -c $(CXXFLAGS) $(1) $< -o $@
endef

define compile
$(CC) -c $(CFLAGS) $(1) $< -o $@
endef

define assemble
$(CC) -c $(CFLAGS) -o $@ $<
endef
