# BanZhuan - File Processing System

BanZhuan is a C-based file processing system designed for high-performance file reconstruction and processing. The system consists of server and client components with thread pooling capabilities.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [API Reference](#api-reference)
- [Data Structures](#data-structures)
- [Usage Examples](#usage-examples)
- [Build and Installation](#build-and-installation)
- [Configuration](#configuration)

## Overview

BanZhuan provides a multi-threaded file processing system with the following key features:

- **File Reconstruction**: Efficient file reconstruction using memory mapping
- **Thread Pooling**: Configurable thread pool for concurrent processing
- **Memory Management**: Optimized memory allocation and caching
- **Client-Server Architecture**: Distributed processing capabilities

## Architecture

The system is composed of several key components:

```
BanZhuan/
├── BanZhuan_Server.h    # Server header with public APIs
├── BanZhuan_Server.c    # Server implementation
├── BanZhuan_Client.h    # Client header (placeholder)
├── BanZhuan_Client.c    # Client implementation (placeholder)
├── create_file.c        # Test file generation utility
└── README.md           # This documentation
```

## API Reference

### Server APIs

#### Data Structures

##### `bz_thread_t`
Thread structure for worker threads.

```c
typedef struct bz_thread_s {
   bz_comm_t *comm; 
} bz_thread_t;
```

**Members:**
- `comm`: Pointer to communication structure

##### `bz_comm_t`
Communication structure for server-client communication.

```c
typedef struct bz_comm_s {
    int listen_fd;
} bz_comm_t;
```

**Members:**
- `listen_fd`: File descriptor for listening socket

#### Global Variables

##### `globle_cache`
Global cache buffer for file data storage.

```c
extern char *globle_cache;
```

**Description:** Points to dynamically allocated memory for caching file contents.

##### `comm`
Global communication structure instance.

```c
extern bz_comm_t *comm;
```

**Description:** Global instance of the communication structure.

##### `threads_p`
Thread pool array.

```c
extern bz_thread_t threads_p[THREAD_POLL_NUM];
```

**Description:** Array of worker thread structures.

#### Constants

##### `THREAD_POLL_NUM`
Maximum number of threads in the thread pool.

```c
#define THREAD_POLL_NUM 32
```

**Description:** Defines the size of the thread pool (32 threads).

#### Functions

##### `Banzhuan_Reconstruct_File()`
Reconstructs a file from memory-mapped data.

```c
static void Banzhuan_Reconstruct_File(char *start, size_t size);
```

**Parameters:**
- `start`: Pointer to the start of memory-mapped file data
- `size`: Size of the file data in bytes

**Description:** Processes and reconstructs file data from memory-mapped content. Currently implemented as a stub function.

**Usage Example:**
```c
char *file_data = mmap(NULL, file_size, PROT_READ, MAP_PRIVATE, fd, 0);
Banzhuan_Reconstruct_File(file_data, file_size);
```

##### `Start_worker_thread()`
Initializes and starts the worker thread pool.

```c
static void Start_worker_thread(void);
```

**Description:** Creates and starts the thread pool for concurrent file processing. Currently implemented as a stub function.

**Usage Example:**
```c
Start_worker_thread();
```

### Utility Functions

#### `create_file.c` - Test File Generator

The `create_file.c` utility generates test files for the BanZhuan system.

##### `main()` (in create_file.c)
Generates a test file with random content.

```c
int main(void);
```

**Description:** Creates a 1GB test file (`/tmp/robintest.txt`) with random printable characters organized in lines of random length (1-199 characters).

**Features:**
- Generates 1GB of test data
- Uses random line lengths (1-199 characters)
- Only uses printable ASCII characters (32-127)
- Seeds random number generator with current time

**Usage Example:**
```bash
gcc -o create_file create_file.c
./create_file
```

## Data Structures

### Thread Management

The system uses a thread pool pattern with the following components:

1. **Thread Pool Array**: `threads_p[THREAD_POLL_NUM]` - Array of worker threads
2. **Communication Structure**: `bz_comm_t` - Manages server-client communication
3. **Global Cache**: `globle_cache` - Shared memory buffer for file data

### Memory Management

The system employs several memory management strategies:

1. **Memory Mapping**: Uses `mmap()` for efficient file reading
2. **Dynamic Allocation**: `malloc()` for global cache buffer
3. **Shared Memory**: Global cache accessible by all threads

## Usage Examples

### Basic Server Usage

```c
#include "BanZhuan_Server.h"

int main(void) {
    int fd;
    struct stat file_stat;
    char *start;
    
    // Open file for processing
    fd = open("/tmp/robintest.txt", O_RDONLY);
    fstat(fd, &file_stat);
    
    // Allocate global cache
    globle_cache = malloc(file_stat.st_size);
    
    // Memory map the file
    start = mmap(NULL, file_stat.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    
    // Initialize communication
    Start_comm();
    
    // Start processing threads
    Start_read_thread();
    Start_worker_thread();
    
    // Process the file
    Banzhuan_Reconstruct_File(start, file_stat.st_size);
    
    // Copy data to cache
    memcpy(globle_cache, start, file_stat.st_size);
    
    return 0;
}
```

### File Processing Workflow

1. **File Opening**: Open target file with appropriate permissions
2. **Memory Mapping**: Map file into memory for efficient access
3. **Cache Allocation**: Allocate global cache buffer
4. **Thread Initialization**: Start communication and worker threads
5. **File Processing**: Reconstruct file using worker threads
6. **Data Transfer**: Copy processed data to global cache

## Build and Installation

### Prerequisites

- GCC compiler
- Linux system with POSIX support
- Standard C libraries

### Compilation

```bash
# Compile server
gcc -o banzhuan_server BanZhuan_Server.c -lpthread

# Compile test file generator
gcc -o create_file create_file.c

# Compile client (when implemented)
gcc -o banzhuan_client BanZhuan_Client.c
```

### Running the System

```bash
# Generate test file
./create_file

# Run server
./banzhuan_server

# Run client (when implemented)
./banzhuan_client
```

## Configuration

### Thread Pool Configuration

Modify `THREAD_POLL_NUM` in `BanZhuan_Server.h` to adjust the number of worker threads:

```c
#define THREAD_POLL_NUM 64  // Increase for more concurrent processing
```

### File Paths

The system currently uses hardcoded file paths:

- Test file: `/tmp/robintest.txt`
- Output location: Global cache in memory

### Memory Configuration

The global cache size is dynamically allocated based on the input file size:

```c
globle_cache = malloc(file_stat.st_size);
```

## Development Status

### Implemented Features

- [x] Basic server structure
- [x] Thread pool framework
- [x] Memory mapping for file access
- [x] Global cache system
- [x] Test file generator

### Pending Implementation

- [ ] `Start_comm()` function
- [ ] `Start_read_thread()` function
- [ ] `thread_init()` function
- [ ] `Banzhuan_Reconstruct_File()` implementation
- [ ] Client-side functionality
- [ ] Error handling and validation
- [ ] Configuration management
- [ ] Logging and debugging

## Notes

- The client components (`BanZhuan_Client.h` and `BanZhuan_Client.c`) are currently empty placeholders
- Several functions are declared but not yet implemented
- The system is designed for Linux environments with POSIX support
- Memory management should be enhanced with proper cleanup and error handling

## License

This project appears to be in development. Please check with the project maintainers for licensing information.
