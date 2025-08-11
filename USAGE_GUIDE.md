# BanZhuan Usage Guide

This guide provides practical examples and step-by-step instructions for using the BanZhuan file processing system.

## Table of Contents

- [Quick Start](#quick-start)
- [Basic Usage](#basic-usage)
- [Advanced Usage](#advanced-usage)
- [Configuration Examples](#configuration-examples)
- [Troubleshooting](#troubleshooting)
- [Performance Tips](#performance-tips)
- [Integration Examples](#integration-examples)

## Quick Start

### Prerequisites

Ensure you have the following installed:
- GCC compiler (version 4.8 or later)
- Linux system with POSIX support
- Standard C libraries
- pthread library

### Step 1: Compile the System

```bash
# Compile the server
gcc -o banzhuan_server BanZhuan_Server.c -lpthread

# Compile the test file generator
gcc -o create_file create_file.c

# Verify compilation
ls -la banzhuan_server create_file
```

### Step 2: Generate Test Data

```bash
# Generate a 1GB test file
./create_file

# Verify the file was created
ls -lh /tmp/robintest.txt
```

### Step 3: Run the Server

```bash
# Start the BanZhuan server
./banzhuan_server
```

## Basic Usage

### Simple File Processing

Here's a basic example of how to use the BanZhuan system:

```c
#include "BanZhuan_Server.h"
#include <fcntl.h>
#include <sys/stat.h>

int main(void) {
    int fd;
    struct stat file_stat;
    char *start;
    
    // Step 1: Open the file to process
    fd = open("/tmp/robintest.txt", O_RDONLY);
    if (fd == -1) {
        perror("Failed to open file");
        return 1;
    }
    
    // Step 2: Get file information
    if (fstat(fd, &file_stat) == -1) {
        perror("Failed to get file stats");
        close(fd);
        return 1;
    }
    
    // Step 3: Allocate global cache
    globle_cache = malloc(file_stat.st_size);
    if (globle_cache == NULL) {
        perror("Failed to allocate memory");
        close(fd);
        return 1;
    }
    
    // Step 4: Memory map the file
    start = mmap(NULL, file_stat.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (start == MAP_FAILED) {
        perror("Failed to memory map file");
        free(globle_cache);
        close(fd);
        return 1;
    }
    
    // Step 5: Initialize the system
    Start_comm();
    Start_read_thread();
    Start_worker_thread();
    
    // Step 6: Process the file
    Banzhuan_Reconstruct_File(start, file_stat.st_size);
    
    // Step 7: Copy data to cache
    memcpy(globle_cache, start, file_stat.st_size);
    
    // Step 8: Cleanup
    munmap(start, file_stat.st_size);
    free(globle_cache);
    close(fd);
    
    return 0;
}
```

### Custom File Processing

To process a different file, modify the file path:

```c
// Process a custom file
fd = open("/path/to/your/file.txt", O_RDONLY);
```

### Thread Pool Configuration

Adjust the thread pool size by modifying the header file:

```c
// In BanZhuan_Server.h
#define THREAD_POLL_NUM 64  // Increase for more threads
```

## Advanced Usage

### Custom File Processing Function

Implement your own file processing logic:

```c
#include "BanZhuan_Server.h"
#include <pthread.h>

// Custom processing function
void custom_process_chunk(char *data, size_t size, int thread_id) {
    printf("Thread %d processing %zu bytes\n", thread_id, size);
    
    // Your custom processing logic here
    for (size_t i = 0; i < size; i++) {
        // Example: Convert to uppercase
        if (data[i] >= 'a' && data[i] <= 'z') {
            data[i] = data[i] - 32;
        }
    }
}

// Modified reconstruction function
void Banzhuan_Reconstruct_File_Custom(char *start, size_t size) {
    const int num_threads = THREAD_POLL_NUM;
    const size_t chunk_size = size / num_threads;
    
    pthread_t threads[THREAD_POLL_NUM];
    
    // Create threads for parallel processing
    for (int i = 0; i < num_threads; i++) {
        size_t offset = i * chunk_size;
        size_t current_chunk_size = (i == num_threads - 1) ? 
                                   (size - offset) : chunk_size;
        
        // Pass thread-specific data
        struct {
            char *data;
            size_t size;
            int thread_id;
        } thread_data = {
            .data = start + offset,
            .size = current_chunk_size,
            .thread_id = i
        };
        
        pthread_create(&threads[i], NULL, 
                      (void *(*)(void *))custom_process_chunk,
                      &thread_data);
    }
    
    // Wait for all threads to complete
    for (int i = 0; i < num_threads; i++) {
        pthread_join(threads[i], NULL);
    }
}
```

### Memory-Efficient Processing

For very large files, use streaming processing:

```c
#include "BanZhuan_Server.h"

#define CHUNK_SIZE (1024 * 1024)  // 1MB chunks

void process_large_file(const char *filename) {
    int fd = open(filename, O_RDONLY);
    if (fd == -1) {
        perror("Failed to open file");
        return;
    }
    
    struct stat st;
    fstat(fd, &st);
    
    // Allocate chunk buffer
    char *chunk = malloc(CHUNK_SIZE);
    if (!chunk) {
        close(fd);
        return;
    }
    
    size_t total_processed = 0;
    size_t remaining = st.st_size;
    
    while (remaining > 0) {
        size_t to_read = (remaining < CHUNK_SIZE) ? remaining : CHUNK_SIZE;
        
        ssize_t bytes_read = read(fd, chunk, to_read);
        if (bytes_read <= 0) break;
        
        // Process the chunk
        Banzhuan_Reconstruct_File(chunk, bytes_read);
        
        total_processed += bytes_read;
        remaining -= bytes_read;
        
        printf("Processed %zu/%zu bytes (%.1f%%)\n", 
               total_processed, st.st_size, 
               (double)total_processed / st.st_size * 100);
    }
    
    free(chunk);
    close(fd);
}
```

### Error Handling and Recovery

Implement robust error handling:

```c
#include "BanZhuan_Server.h"
#include <errno.h>

typedef enum {
    BZ_SUCCESS = 0,
    BZ_ERROR_FILE_OPEN,
    BZ_ERROR_MEMORY_ALLOC,
    BZ_ERROR_MMAP,
    BZ_ERROR_THREAD_CREATE
} bz_error_t;

bz_error_t banzhuan_process_file(const char *filename) {
    int fd = open(filename, O_RDONLY);
    if (fd == -1) {
        return BZ_ERROR_FILE_OPEN;
    }
    
    struct stat st;
    if (fstat(fd, &st) == -1) {
        close(fd);
        return BZ_ERROR_FILE_OPEN;
    }
    
    // Allocate memory with error checking
    globle_cache = malloc(st.st_size);
    if (!globle_cache) {
        close(fd);
        return BZ_ERROR_MEMORY_ALLOC;
    }
    
    // Memory map with error checking
    char *mapped_data = mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    if (mapped_data == MAP_FAILED) {
        free(globle_cache);
        close(fd);
        return BZ_ERROR_MMAP;
    }
    
    // Process the file
    Banzhuan_Reconstruct_File(mapped_data, st.st_size);
    
    // Copy to cache
    memcpy(globle_cache, mapped_data, st.st_size);
    
    // Cleanup
    munmap(mapped_data, st.st_size);
    close(fd);
    
    return BZ_SUCCESS;
}

// Usage with error handling
int main(void) {
    bz_error_t result = banzhuan_process_file("/tmp/robintest.txt");
    
    switch (result) {
        case BZ_SUCCESS:
            printf("File processed successfully\n");
            break;
        case BZ_ERROR_FILE_OPEN:
            printf("Error: Could not open file\n");
            break;
        case BZ_ERROR_MEMORY_ALLOC:
            printf("Error: Memory allocation failed\n");
            break;
        case BZ_ERROR_MMAP:
            printf("Error: Memory mapping failed\n");
            break;
        default:
            printf("Error: Unknown error occurred\n");
    }
    
    return (result == BZ_SUCCESS) ? 0 : 1;
}
```

## Configuration Examples

### Environment-Based Configuration

```c
#include "BanZhuan_Server.h"
#include <stdlib.h>

void load_configuration(void) {
    // Get thread pool size from environment
    const char *thread_pool_env = getenv("BZ_THREAD_POOL_SIZE");
    if (thread_pool_env) {
        int pool_size = atoi(thread_pool_env);
        if (pool_size > 0 && pool_size <= 128) {
            // Note: This would require modifying the header file
            // or making THREAD_POLL_NUM a variable
            printf("Using thread pool size: %d\n", pool_size);
        }
    }
    
    // Get cache size from environment
    const char *cache_size_env = getenv("BZ_CACHE_SIZE");
    if (cache_size_env) {
        size_t cache_size = atol(cache_size_env);
        printf("Cache size configured: %zu bytes\n", cache_size);
    }
}
```

### Configuration File Support

```c
#include "BanZhuan_Server.h"
#include <stdio.h>

typedef struct {
    int thread_pool_size;
    size_t cache_size;
    char input_file[256];
    char output_file[256];
} bz_config_t;

bz_config_t load_config_file(const char *config_path) {
    bz_config_t config = {
        .thread_pool_size = 32,
        .cache_size = 1024 * 1024 * 1024,  // 1GB default
        .input_file = "/tmp/robintest.txt",
        .output_file = "/tmp/output.txt"
    };
    
    FILE *fp = fopen(config_path, "r");
    if (!fp) {
        printf("Warning: Could not open config file, using defaults\n");
        return config;
    }
    
    char line[512];
    while (fgets(line, sizeof(line), fp)) {
        char key[64], value[256];
        if (sscanf(line, "%63[^=]=%255s", key, value) == 2) {
            if (strcmp(key, "thread_pool_size") == 0) {
                config.thread_pool_size = atoi(value);
            } else if (strcmp(key, "cache_size") == 0) {
                config.cache_size = atol(value);
            } else if (strcmp(key, "input_file") == 0) {
                strncpy(config.input_file, value, sizeof(config.input_file) - 1);
            } else if (strcmp(key, "output_file") == 0) {
                strncpy(config.output_file, value, sizeof(config.output_file) - 1);
            }
        }
    }
    
    fclose(fp);
    return config;
}
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Compilation Errors

**Error:** `undefined reference to 'pthread_create'`
```bash
# Solution: Link with pthread library
gcc -o banzhuan_server BanZhuan_Server.c -lpthread
```

**Error:** `fatal error: 'BanZhuan_Server.h' file not found`
```bash
# Solution: Ensure header file is in the same directory
ls -la BanZhuan_Server.h
```

#### 2. Runtime Errors

**Error:** `Failed to open file`
```bash
# Check file permissions and existence
ls -la /tmp/robintest.txt
# Generate test file if missing
./create_file
```

**Error:** `Memory allocation failed`
```bash
# Check available memory
free -h
# Reduce file size or use streaming processing
```

#### 3. Performance Issues

**Problem:** Slow processing
```bash
# Check CPU usage
top
# Monitor memory usage
htop
# Adjust thread pool size
```

### Debugging Tips

1. **Enable Verbose Output**
```c
#define DEBUG 1

#ifdef DEBUG
#define DEBUG_PRINT(fmt, ...) printf("[DEBUG] " fmt "\n", ##__VA_ARGS__)
#else
#define DEBUG_PRINT(fmt, ...)
#endif
```

2. **Memory Leak Detection**
```bash
# Use valgrind for memory leak detection
valgrind --leak-check=full ./banzhuan_server
```

3. **Performance Profiling**
```bash
# Use gprof for performance profiling
gcc -pg -o banzhuan_server BanZhuan_Server.c -lpthread
./banzhuan_server
gprof banzhuan_server gmon.out
```

## Performance Tips

### Optimization Strategies

1. **Memory Mapping Optimization**
```c
// Use MAP_POPULATE for better performance on large files
char *data = mmap(NULL, file_size, PROT_READ, MAP_PRIVATE | MAP_POPULATE, fd, 0);
```

2. **Thread Pool Tuning**
```c
// Optimal thread count is typically CPU cores * 2
#define THREAD_POLL_NUM (sysconf(_SC_NPROCESSORS_ONLN) * 2)
```

3. **Cache-Friendly Processing**
```c
// Process data in cache-line sized chunks
#define CACHE_LINE_SIZE 64
#define PROCESSING_CHUNK_SIZE (CACHE_LINE_SIZE * 1024)
```

### Benchmarking

```c
#include <time.h>

void benchmark_processing(const char *filename) {
    clock_t start = clock();
    
    bz_error_t result = banzhuan_process_file(filename);
    
    clock_t end = clock();
    double cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    
    struct stat st;
    stat(filename, &st);
    
    printf("Processed %ld bytes in %.2f seconds\n", st.st_size, cpu_time_used);
    printf("Processing rate: %.2f MB/s\n", 
           (double)st.st_size / (1024 * 1024) / cpu_time_used);
}
```

## Integration Examples

### Integration with Other Systems

#### 1. Web Server Integration

```c
#include "BanZhuan_Server.h"
#include <microhttpd.h>

static int request_handler(void *cls, struct MHD_Connection *connection,
                          const char *url, const char *method,
                          const char *version, const char *upload_data,
                          size_t *upload_data_size, void **con_cls) {
    
    if (strcmp(method, "POST") == 0 && strcmp(url, "/process") == 0) {
        // Process file using BanZhuan
        bz_error_t result = banzhuan_process_file("/tmp/upload.txt");
        
        const char *response = (result == BZ_SUCCESS) ? 
                              "{\"status\": \"success\"}" : 
                              "{\"status\": \"error\"}";
        
        struct MHD_Response *resp = MHD_create_response_from_buffer(
            strlen(response), (void*)response, MHD_RESPMEM_PERSISTENT);
        
        MHD_add_response_header(resp, "Content-Type", "application/json");
        int ret = MHD_queue_response(connection, MHD_HTTP_OK, resp);
        MHD_destroy_response(resp);
        return ret;
    }
    
    return MHD_NO;
}
```

#### 2. Database Integration

```c
#include "BanZhuan_Server.h"
#include <sqlite3.h>

void store_processing_result(const char *filename, bz_error_t result) {
    sqlite3 *db;
    sqlite3_stmt *stmt;
    
    if (sqlite3_open("banzhuan.db", &db) != SQLITE_OK) {
        return;
    }
    
    const char *sql = "INSERT INTO processing_log (filename, result, timestamp) "
                      "VALUES (?, ?, datetime('now'))";
    
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, filename, -1, SQLITE_STATIC);
        sqlite3_bind_int(stmt, 2, result);
        sqlite3_step(stmt);
        sqlite3_finalize(stmt);
    }
    
    sqlite3_close(db);
}
```

#### 3. Logging Integration

```c
#include "BanZhuan_Server.h"
#include <syslog.h>

void banzhuan_log_init(void) {
    openlog("banzhuan", LOG_PID | LOG_CONS, LOG_USER);
}

void banzhuan_log(const char *message, int priority) {
    syslog(priority, "%s", message);
}

void banzhuan_log_cleanup(void) {
    closelog();
}

// Usage in main processing function
bz_error_t banzhuan_process_file_with_logging(const char *filename) {
    banzhuan_log_init();
    
    banzhuan_log("Starting file processing", LOG_INFO);
    
    bz_error_t result = banzhuan_process_file(filename);
    
    if (result == BZ_SUCCESS) {
        banzhuan_log("File processing completed successfully", LOG_INFO);
    } else {
        banzhuan_log("File processing failed", LOG_ERR);
    }
    
    banzhuan_log_cleanup();
    return result;
}
```

This comprehensive usage guide provides practical examples and best practices for using the BanZhuan system effectively.