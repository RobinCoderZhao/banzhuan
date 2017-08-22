#ifndef _BANZHUAN_SERVER_H_
#define _BANZHUAN_SERVER_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#define THREAD_POLL_NUM 32

typedef struct bz_thread_s bz_thread_t;
typedef struct bz_comm_s bz_comm_t;

static void Banzhuan_Reconstruct_File(char *start, size_t size);
static void Start_worker_thread(); 

char *globle_cache;

struct bz_thread_s{
   bz_comm_t *comm; 
};

struct bz_comm_s{
    int listen_fd;

};

bz_comm_t *comm;
bz_thread_t threads_p[THREAD_POLL_NUM];


#endif
