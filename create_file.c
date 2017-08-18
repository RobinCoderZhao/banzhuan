#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>

int main()
{
    struct timeval now;
    char a;
    int i, length, line, set;
    FILE *fp;
    char buf[200];

    gettimeofday(&now, NULL);
    srand(now.tv_sec + now.tv_usec * 1000*1000);
    fp = fopen("/tmp/robintest.txt", "w+");
    length = 1024 * 1024 * 1024;
    set = 0;
    i = 0;
    while(length > 0) {
        if(!set) {
            line = rand()%199+1;
            set = 1;
        }
        a = 0;
        while(a < 32) {
            a = rand()%128;
        }
        fputc(a, fp);
        i++;
        if(i == line) {
            //fprintf(fp, "%s\n", buf);
            //    printf("%s\n",buf);
            fputc('\n', fp);
            i = 0;
            set = 0;
            length -= line + 1;
            continue;
        }
    }
}
