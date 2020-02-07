ARCH = elf32
CROSSCOMPILER = 

# As
AS = $(CROSSCOMPILER)as
ASFLAGS =

# C
CC = $(CROSSCOMPILER)gcc
CFLAGS = -c -ffreestanding $(foreach INCDIR, $(INCLUDES), -I$(INCDIR)) -std=c99 -Wall -nostdlib -nostartfiles #-fstack-protector-all -g -fsanitize=undefined

# C++
CXX = $(CROSSCOMPILER)g++
CXXFLAGS = -c -ffreestanding -fno-builtin -fno-exceptions -fno-rtti -fno-stack-protector $(foreach INCDIR, $(INCLUDES), -I $(INCDIR)) -std=c++0x -Wall

# Assembler
ASM = yasm
ASMFLAGS = -f $(ARCH)

# LD
LD = ld
LDFLAGS = --warn-unresolved-symbols

# Sources
INCLUDES = include
SOURCES = src

# Directorys
SOURCESDIRS = src
OBJECTSDIR = obj
ISODIR = iso

HEADERS = $(foreach DIR, $(INCLUDES), $(wildcard $(DIR)/*.h))
SOURCES = $(foreach DIR, $(SOURCESDIRS), $(wildcard $(DIR)/*.asm $(DIR)/*.S $(DIR)/*.c $(DIR)/*.cpp))
OBJECTS = $(foreach OBJECT, $(patsubst %.asm, %.elf, $(patsubst %.S, %.O, $(patsubst %.c, %.o, $(patsubst %.cpp, %.o, $(SOURCES))))), $(OBJDIR)/$(OBJECT))

TARGET = mixo

build: clean initialize $(TARGET)
	@echo You succesfully compiled Mixo!

initialize:
	@mkdir $(OBJECTSDIR)
	@mkdir $(ISODIR)

all: build

run:
	qemu-system-i386 -kernel kernel

clean: 
	rm -rf $(ISODIR)
	rm -rf $(OBJECTSDIR)

$(TARGET): $(OBJECTS)
	$(LD) -Tsrc/arch/$(ARCH)/link.ld -o $@ $+

# Rules

$(OBJECTSDIR)/%.elf: %.asm
	@echo ASM $< $@
	$(ASM) $(ASMFLAGS) -o $@ $<

$(OBJECTSDIR)/%.o : %.c
	@echo CC $< $@
	@$(CC) $(CFLAGS) $< -o $@

$(OBJECTSDIR)/%.o : %.cpp
	@echo CXX $< $@
	$(CXX) $(CXXFLAGS) $< -o $@