# BanZhuan API Reference

This document provides comprehensive API documentation for the BanZhuan file processing system.

## Table of Contents

- [Header Files](#header-files)
- [Data Structures](#data-structures)
- [Constants](#constants)
- [Functions](#functions)
- [Global Variables](#global-variables)
- [Error Handling](#error-handling)
- [Threading Model](#threading-model)
- [Memory Management](#memory-management)

## Header Files

### BanZhuan_Server.h

Main server header file containing all public APIs and data structures.

```c
#include "BanZhuan_Server.h"
```

**Included Headers:**
- `<stdio.h>` - Standard I/O operations
- `<stdlib.h>` - Memory allocation and utilities
- `<string.h>` - String manipulation functions
- `<sys/mman.h>` - Memory mapping functions
- `<sys/types.h>` - System data types
- `<sys/stat.h>` - File status information
- `<unistd.h>` - POSIX system calls
- `<fcntl.h>` - File control options

## Data Structures

### bz_thread_t

Thread structure for worker threads in the thread pool.

```c
typedef struct bz_thread_s {
   bz_comm_t *comm; 
} bz_thread_t;
```

**Members:**
- `comm` (bz_comm_t*): Pointer to communication structure for this thread

**Usage:**
```c
bz_thread_t worker_thread;
worker_thread.comm = &communication_struct;
```

### bz_comm_t

Communication structure for managing server-client communication.

```c
typedef struct bz_comm_s {
    int listen_fd;
} bz_comm_t;
```

**Members:**
- `listen_fd` (int): File descriptor for the listening socket

**Usage:**
```c
bz_comm_t comm_struct;
comm_struct.listen_fd = socket_fd;
```

## Constants

### THREAD_POLL_NUM

Defines the maximum number of threads in the thread pool.

```c
#define THREAD_POLL_NUM 32
```

**Value:** 32 threads

**Usage:**
```c
// Access the thread pool size
int pool_size = THREAD_POLL_NUM;
```

## Functions

### File Processing Functions

#### Banzhuan_Reconstruct_File

Reconstructs a file from memory-mapped data.

```c
static void Banzhuan_Reconstruct_File(char *start, size_t size);
```

**Parameters:**
- `start` (char*): Pointer to the start of memory-mapped file data
- `size` (size_t): Size of the file data in bytes

**Return Value:** None (void)

**Description:** This function processes and reconstructs file data from memory-mapped content. It is designed to work with the thread pool for concurrent processing.

**Current Status:** Stub implementation - needs to be completed

**Usage Example:**
```c
#include "BanZhuan_Server.h"

int fd = open("input.txt", O_RDONLY);
struct stat st;
fstat(fd, &st);

char *mapped_data = mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
Banzhuan_Reconstruct_File(mapped_data, st.st_size);

munmap(mapped_data, st.st_size);
close(fd);
```

**Thread Safety:** This function should be thread-safe when implemented

### Thread Management Functions

#### Start_worker_thread

Initializes and starts the worker thread pool.

```c
static void Start_worker_thread(void);
```

**Parameters:** None

**Return Value:** None (void)

**Description:** Creates and starts the thread pool for concurrent file processing. This function initializes the `threads_p` array and starts all worker threads.

**Current Status:** Stub implementation - needs to be completed

**Usage Example:**
```c
#include "BanZhuan_Server.h"

// Initialize the system
Start_comm();
Start_read_thread();
Start_worker_thread();  // Start the thread pool
```

**Thread Safety:** This function should only be called once during system initialization

### Communication Functions

#### Start_comm

Initializes the communication system.

```c
void Start_comm(void);
```

**Parameters:** None

**Return Value:** None (void)

**Description:** Sets up the communication infrastructure for server-client communication. This function initializes the global `comm` structure and prepares the listening socket.

**Current Status:** Not implemented - function signature inferred from usage

**Usage Example:**
```c
#include "BanZhuan_Server.h"

// Initialize communication before starting threads
Start_comm();
```

#### Start_read_thread

Starts the read thread for handling incoming data.

```c
void Start_read_thread(void);
```

**Parameters:** None

**Return Value:** None (void)

**Description:** Creates and starts a dedicated thread for reading incoming data from clients or input sources.

**Current Status:** Not implemented - function signature inferred from usage

**Usage Example:**
```c
#include "BanZhuan_Server.h"

// Start the read thread after communication initialization
Start_comm();
Start_read_thread();
```

### Thread Initialization

#### thread_init

Initializes thread-related structures and resources.

```c
void thread_init(void);
```

**Parameters:** None

**Return Value:** None (void)

**Description:** Performs initialization tasks for the threading system, including setting up thread attributes, mutexes, and condition variables.

**Current Status:** Not implemented - function signature inferred from usage

**Usage Example:**
```c
#include "BanZhuan_Server.h"

// Initialize threading system
thread_init();
```

## Global Variables

### globle_cache

Global cache buffer for file data storage.

```c
extern char *globle_cache;
```

**Type:** char*

**Description:** Points to dynamically allocated memory for caching file contents. This buffer is shared across all threads and stores the processed file data.

**Memory Management:** Must be allocated with `malloc()` and freed with `free()` when no longer needed.

**Usage Example:**
```c
#include "BanZhuan_Server.h"

// Allocate global cache
struct stat file_stat;
fstat(fd, &file_stat);
globle_cache = malloc(file_stat.st_size);

// Use the cache
memcpy(globle_cache, source_data, file_stat.st_size);

// Clean up
free(globle_cache);
```

**Thread Safety:** Access to this variable should be synchronized when multiple threads are involved

### comm

Global communication structure instance.

```c
extern bz_comm_t *comm;
```

**Type:** bz_comm_t*

**Description:** Global instance of the communication structure used for server-client communication.

**Usage Example:**
```c
#include "BanZhuan_Server.h"

// Access the global communication structure
if (comm != NULL) {
    int listen_fd = comm->listen_fd;
    // Use the file descriptor
}
```

**Thread Safety:** Access to this variable should be synchronized when multiple threads are involved

### threads_p

Thread pool array containing all worker threads.

```c
extern bz_thread_t threads_p[THREAD_POLL_NUM];
```

**Type:** bz_thread_t[THREAD_POLL_NUM]

**Description:** Array of worker thread structures. The size is defined by `THREAD_POLL_NUM` (32 threads).

**Usage Example:**
```c
#include "BanZhuan_Server.h"

// Access a specific thread in the pool
bz_thread_t *thread = &threads_p[0];
bz_comm_t *thread_comm = thread->comm;

// Iterate through all threads
for (int i = 0; i < THREAD_POLL_NUM; i++) {
    // Process each thread
    bz_thread_t *current_thread = &threads_p[i];
}
```

**Thread Safety:** Individual thread structures should be accessed with proper synchronization

## Error Handling

The current implementation lacks comprehensive error handling. When implementing the stub functions, consider the following error scenarios:

### File Operations
- File not found
- Insufficient permissions
- Disk space issues
- Memory mapping failures

### Memory Management
- Memory allocation failures
- Memory mapping errors
- Buffer overflow protection

### Threading
- Thread creation failures
- Thread synchronization issues
- Deadlock prevention

### Network Communication
- Socket creation failures
- Connection timeouts
- Network errors

## Threading Model

The BanZhuan system uses a thread pool pattern with the following characteristics:

### Thread Pool Architecture
- **Fixed Size**: 32 threads (configurable via `THREAD_POLL_NUM`)
- **Worker Threads**: Each thread in `threads_p` array
- **Communication**: Each thread has access to a `bz_comm_t` structure
- **Shared Resources**: Global cache and communication structures

### Thread Lifecycle
1. **Initialization**: `thread_init()` sets up thread resources
2. **Creation**: `Start_worker_thread()` creates the thread pool
3. **Execution**: Threads process file data concurrently
4. **Cleanup**: Threads are joined and resources are freed

### Synchronization Requirements
- Global cache access must be synchronized
- Communication structure access must be protected
- File operations should be thread-safe

## Memory Management

The system employs several memory management strategies:

### Memory Mapping
```c
char *mapped_data = mmap(NULL, file_size, PROT_READ, MAP_PRIVATE, fd, 0);
```
- Efficient file reading without copying to user space
- Automatic cleanup when process terminates
- Must be explicitly unmapped with `munmap()`

### Dynamic Allocation
```c
globle_cache = malloc(file_size);
```
- Global cache allocation based on file size
- Must be explicitly freed with `free()`
- Check for allocation failures

### Memory Layout
```
Process Memory Layout:
┌─────────────────┐
│   Stack         │
├─────────────────┤
│   Heap          │ ← globle_cache allocated here
├─────────────────┤
│   Mapped Files  │ ← mmap() regions
├─────────────────┤
│   Code/Data     │
└─────────────────┘
```

### Best Practices
1. Always check return values from memory allocation functions
2. Free allocated memory when no longer needed
3. Unmap memory-mapped regions explicitly
4. Use appropriate memory alignment for performance
5. Consider memory fragmentation in long-running processes

## Performance Considerations

### Memory Mapping Benefits
- Reduced memory usage for large files
- Faster file access through page caching
- Automatic memory management by the OS

### Thread Pool Optimization
- Thread creation overhead is amortized
- Load balancing across available CPU cores
- Configurable pool size based on system resources

### Cache Management
- Global cache provides fast access to processed data
- Consider cache size limits for very large files
- Implement cache eviction policies if needed

## Future Enhancements

### Planned API Additions
- Configuration management functions
- Logging and debugging APIs
- Error reporting mechanisms
- Performance monitoring functions

### Potential Improvements
- Asynchronous I/O support
- Memory pool allocation
- Lock-free data structures
- NUMA-aware memory allocation