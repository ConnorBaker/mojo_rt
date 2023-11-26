# Rule to format the code
format:
	@echo "make: Formatting code..."
	@mojo format --line-length 120 .
	@echo "make: Done."

debug:
	@echo "make: Building debug variant..."
	@mojo build main.mojo -o main --debug-level full
	@echo "make: Done."

build:
	@echo "make: Building..."
	@mojo build main.mojo -o main
	@echo "make: Done."

run: build
	@echo "make: Running..."
	@./main
	@echo "make: Done."

show: run
	@echo "make: Showing..."
	@open simple.ppm
	@echo "make: Done."

clean:
	@echo "make: Cleaning..."
	@rm -rf main main.dSYM *.ppm
	@echo "make: Done."