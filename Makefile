# Rule to format the code
format:
	@echo "Formatting code..."
	@mojo format --line-length 120 .

debug:
	@echo "Building debug variant..."
	@mojo build main.mojo -o main --debug-level full

build:
	@echo "Building..."
	@mojo build main.mojo -o main

run: build
	@echo "Running..."
	@./main

show: run
	@echo "Showing..."
	@open simple.ppm

clean:
	@echo "Cleaning..."
	@rm -rf main main.dSYM *.ppm