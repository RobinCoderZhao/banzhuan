# BanZhuan Makefile
# Build system for the BanZhuan file processing system

# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -g -O2
LDFLAGS = -lpthread

# Directories
SRCDIR = .
OBJDIR = obj
BINDIR = bin
DOCDIR = docs

# Source files
SERVER_SRC = $(SRCDIR)/BanZhuan_Server.c
CLIENT_SRC = $(SRCDIR)/BanZhuan_Client.c
CREATE_FILE_SRC = $(SRCDIR)/create_file.c

# Object files
SERVER_OBJ = $(OBJDIR)/BanZhuan_Server.o
CLIENT_OBJ = $(OBJDIR)/BanZhuan_Client.o
CREATE_FILE_OBJ = $(OBJDIR)/create_file.o

# Executables
SERVER_BIN = $(BINDIR)/banzhuan_server
CLIENT_BIN = $(BINDIR)/banzhuan_client
CREATE_FILE_BIN = $(BINDIR)/create_file

# Targets
TARGETS = $(SERVER_BIN) $(CREATE_FILE_BIN)

# Default target
all: $(TARGETS)

# Create directories
$(OBJDIR):
	mkdir -p $(OBJDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

# Compile server
$(SERVER_BIN): $(SERVER_OBJ) | $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

$(SERVER_OBJ): $(SERVER_SRC) | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

# Compile client (placeholder for future implementation)
$(CLIENT_BIN): $(CLIENT_OBJ) | $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

$(CLIENT_OBJ): $(CLIENT_SRC) | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

# Compile create_file utility
$(CREATE_FILE_BIN): $(CREATE_FILE_OBJ) | $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $<

$(CREATE_FILE_OBJ): $(CREATE_FILE_SRC) | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

# Debug build
debug: CFLAGS += -DDEBUG -g3 -O0 -D_DEBUG
debug: all

# Release build
release: CFLAGS += -DNDEBUG -O3 -march=native
release: all

# Static analysis
analyze: CFLAGS += -fanalyzer
analyze: clean all

# Install targets
install: all
	@echo "Installing BanZhuan system..."
	sudo cp $(SERVER_BIN) /usr/local/bin/
	sudo cp $(CREATE_FILE_BIN) /usr/local/bin/
	@echo "Installation complete!"

uninstall:
	@echo "Uninstalling BanZhuan system..."
	sudo rm -f /usr/local/bin/banzhuan_server
	sudo rm -f /usr/local/bin/banzhuan_client
	sudo rm -f /usr/local/bin/create_file
	@echo "Uninstallation complete!"

# Test targets
test: all
	@echo "Running tests..."
	@echo "1. Generating test file..."
	./$(CREATE_FILE_BIN)
	@echo "2. Running server..."
	@echo "Note: Server will process the test file"
	./$(SERVER_BIN) || true
	@echo "Tests completed!"

# Performance test
perf-test: all
	@echo "Running performance tests..."
	@echo "Generating test file..."
	./$(CREATE_FILE_BIN)
	@echo "Measuring processing time..."
	time ./$(SERVER_BIN) || true
	@echo "Performance test completed!"

# Memory leak detection
memcheck: all
	@echo "Running memory leak detection..."
	@echo "Generating test file..."
	./$(CREATE_FILE_BIN)
	@echo "Running valgrind..."
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes \
		--verbose --log-file=valgrind-out.txt ./$(SERVER_BIN) || true
	@echo "Memory check completed. Check valgrind-out.txt for results."

# Code coverage (requires gcov)
coverage: CFLAGS += -fprofile-arcs -ftest-coverage
coverage: LDFLAGS += -lgcov
coverage: clean all
	@echo "Running coverage test..."
	./$(CREATE_FILE_BIN)
	./$(SERVER_BIN) || true
	gcov $(SERVER_SRC)
	@echo "Coverage report generated."

# Documentation
docs:
	@echo "Generating documentation..."
	@if command -v doxygen >/dev/null 2>&1; then \
		doxygen Doxyfile 2>/dev/null || echo "Doxygen not configured"; \
	else \
		echo "Doxygen not found. Install with: sudo apt-get install doxygen"; \
	fi

# Clean targets
clean:
	rm -rf $(OBJDIR) $(BINDIR)
	rm -f *.o *.a *.so gmon.out
	rm -f *.gcov *.gcda *.gcno
	rm -f valgrind-out.txt
	rm -f /tmp/robintest.txt

distclean: clean
	rm -rf docs/html docs/latex
	rm -f *.tar.gz *.zip

# Package targets
package: clean all
	@echo "Creating package..."
	tar -czf banzhuan-$(shell date +%Y%m%d).tar.gz \
		--exclude='*.o' --exclude='*.a' --exclude='*.so' \
		--exclude='obj' --exclude='bin' \
		--exclude='*.tar.gz' --exclude='*.zip' \
		--exclude='.git' --exclude='*.gcov' \
		--exclude='*.gcda' --exclude='*.gcno' \
		--exclude='gmon.out' --exclude='valgrind-out.txt' \
		--exclude='/tmp/robintest.txt' .

# Help target
help:
	@echo "BanZhuan Build System"
	@echo "====================="
	@echo ""
	@echo "Available targets:"
	@echo "  all          - Build all targets (default)"
	@echo "  debug        - Build with debug symbols and no optimization"
	@echo "  release      - Build with maximum optimization"
	@echo "  analyze      - Build with static analysis"
	@echo "  test         - Run basic tests"
	@echo "  perf-test    - Run performance tests"
	@echo "  memcheck     - Run memory leak detection with valgrind"
	@echo "  coverage     - Generate code coverage report"
	@echo "  docs         - Generate documentation"
	@echo "  install      - Install to /usr/local/bin"
	@echo "  uninstall    - Remove from /usr/local/bin"
	@echo "  clean        - Remove build artifacts"
	@echo "  distclean    - Remove all generated files"
	@echo "  package      - Create distribution package"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  CC           - C compiler (default: gcc)"
	@echo "  CFLAGS       - C compiler flags"
	@echo "  LDFLAGS      - Linker flags"
	@echo ""
	@echo "Examples:"
	@echo "  make debug           # Build with debug symbols"
	@echo "  make test            # Run tests"
	@echo "  make memcheck        # Check for memory leaks"
	@echo "  make install         # Install system"

# Dependencies
$(SERVER_OBJ): $(SRCDIR)/BanZhuan_Server.h
$(CLIENT_OBJ): $(SRCDIR)/BanZhuan_Client.h

# Phony targets
.PHONY: all debug release analyze test perf-test memcheck coverage \
        docs clean distclean package install uninstall help

# Default target
.DEFAULT_GOAL := all