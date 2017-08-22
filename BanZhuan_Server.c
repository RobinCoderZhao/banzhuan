#include "BanZhuan_Server.h"


static void
Banzhuan_Reconstruct_File(char *start, size_t size)
{

}

static void
Start_worker_thread_pool()
{
    thread_init()
}

int main(void)
{
    int fd, ret;
    char *start,  *p;
    struct stat file_stat;

    fd = open("/tmp/robintest.txt", 0);
    //fd = open("/tmp/tunnelblick-downscript-needs-to-be-run.txt", O_CREAT, O_RDWR);

    fstat(fd, &file_stat);
    globle_cache = malloc(file_stat.st_size);

    //printf("len = %d\n", (int)file_stat.st_size);

    start = mmap(NULL, file_stat.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    ret = 0;
    p = globle_cache;

    Start_comm();

    Start_read_thread();
    Start_worker_thread_pool();
    Banzhuan_Reconstruct_File(start, file_stat.st_size);
    /*
    do {
       *p = start[ret++]; 
       p++;
    } while(ret < file_stat.st_size);
    */
    memcpy(globle_cache, start, file_stat.st_size);
    //printf("%s\n", start);
    //start_workers();

    return 1;
}
