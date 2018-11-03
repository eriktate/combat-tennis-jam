all: build run

build:
	nim c -o:bin/combat-tennis-jam src/main.nim

run:
	./bin/combat-tennis-jam

test:
	nim c -r src/math2d_test.nim

.PHONY = all build run test
