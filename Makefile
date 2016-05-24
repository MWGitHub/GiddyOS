kernel := build/kernel.bin
iso := build/os.iso

linker_script := src/boot/linker.ld
grub_cfg := src/boot/grub.cfg
asm_source := $(wildcard src/boot/*.asm)
asm_object := $(patsubst src/boot/%.asm, build/%.o, $(asm_source))

.PHONY: all clean run iso

all: $(kernel)

clean:
		@rm -rf build

run: $(iso)
		@qemu-system-x86_64 -cdrom $(iso)

$(iso):	$(kernel) $(grub_cfg)
				@mkdir -p build/isofiles/boot/grub
				@cp $(kernel) build/isofiles/boot/kernel.bin
				@cp $(grub_cfg) build/isofiles/boot/grub
				@grub-mkrescue -o $(iso) build/isofiles 2> /dev/null
				@rm -r build/isofiles

$(kernel): $(asm_object) $(linker_script)
	@x86_64-elf-ld -n -o $(kernel) -T $(linker_script) $(asm_object)

# Compile assembly files
build/%.o: src/boot/%.asm
		@mkdir -p $(shell dirname $@)
		@nasm -f elf64 $< -o $@
