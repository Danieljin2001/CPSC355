#include<stdio.h>
int main(int argc, char *argv[]){
    char fname[30];
    char lname[30];

    if (argc == 3){
        printf("Your name is: %s %s \n", argv[1], argv[2]);
        printf("Located at: %p %p", &argv[1], &argv[2]);
    }
    else{
        printf("What is your First name? ");
        scanf("%s", fname);
        printf("What is your Last name? ");
        scanf("%s", lname);
        printf("Your full name is %s %s",fname, lname);

    }
    return 0;
}