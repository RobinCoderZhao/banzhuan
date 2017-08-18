#include "BanZhuan_Server.h"


int main(void)
{
    int fd, ret;
    char *start, *buf, *p;
    struct stat file_stat;

    fd = open("/tmp/robintest.txt", 0);
    //fd = open("/tmp/tunnelblick-downscript-needs-to-be-run.txt", O_CREAT, O_RDWR);

    fstat(fd, &file_stat);
    buf = malloc(file_stat.st_size);

    //printf("len = %d\n", (int)file_stat.st_size);

    start = mmap(NULL, file_stat.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    ret = 0;
    p = buf;
    do {
       *p = start[ret++]; 
       p++;
    } while(ret < file_stat.st_size);

    //printf("%s\n", start);
    //start_workers();

    return 1;
}
