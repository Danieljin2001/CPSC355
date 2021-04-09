#include <stdio.h>
#include <stdlib.h>
#include <time.h>

//this function is used to swap and off the website: https://www.geeksforgeeks.org/bubble-sort/  
void swap(int *xp, int *yp) 
{ 
    int temp = *xp; 
    *xp = *yp; 
    *yp = temp; 
} 
//this function is used to sort and off the website: https://www.geeksforgeeks.org/bubble-sort/  
// A function to implement bubble sort 
void bubbleSort(int arr[], int n) 
{ 
   int i, j; 
   for (i = 0; i < n-1; i++)       
  
       // Last i elements are already in place    
       for (j = 0; j < n-i-1; j++)  
           if (arr[j] > arr[j+1]) 
              swap(&arr[j], &arr[j+1]); 
} 



//this function asks for the user to input a column to sort and checks if that is a valid column or not
//this function also returns an integer which will be the inputed column
//if the given input is 111 then the program will quit
int printSorted(int size, FILE *f){
    int sortCol;
    printf("\nEnter a column number: ");
    scanf("%d",&sortCol);

    if (sortCol == 111){
        fclose(f);
        exit(0);
    }
    if(sortCol > size-1 || sortCol < 0){
    while (sortCol > size-1 || sortCol < 0){
        printf("Enter a valid column number: ");
        scanf("%d",&sortCol);
        }
    }
    printf("\nTable sorted by column %d: ",sortCol);
    return sortCol;
}

//parameter1 is a column choses by the user
//the function then sorts out that column from least(at the top) to greatest (at the bottom)
void sort(int *table, int size, int chosen){
    int row;
    int cols;
    int array[size];
    for (row = 0; row < size; row ++){
        array[row] = *((table+row*size) + chosen);
    }
    bubbleSort(array, size);
    for (row = 0; row < size; row ++){
        *((table+row*size) + chosen) = array[row];
    }

}

//this function initializes the given array with random numbers (from 0 to 9)
void initialize(int *table, int size){
    int rows;
    int cols;
    int random;
    srand(time(0));

    for(rows = 0; rows < size; rows++){
        for(cols = 0; cols < size; cols++){
            random = rand() % 10;
            *((table+rows*size) + cols) = random;

        }
        
    }
}

//this function prints out the table onto the command prompt so the user can visually see it
void display(int *table, int size){
    int rows;
    int cols;
    for(rows = 0; rows < size; rows++){
        printf("\n");
        for(cols = 0; cols < size; cols++){
            printf("%d ", *((table+rows*size) + cols));
        }
    
    }
} 
//this function appends into the assign1.log file what the user sees and inputs
void logFile(int *table, int size, int chosen, FILE *f){
    int rows;
    int cols;

    if(chosen == 111){
        for(rows = 0; rows < size; rows++){
        fprintf(f,"\n");
        for(cols = 0; cols < size; cols++){
            fprintf(f,"%d ", *((table+rows*size) + cols));
        }
    
    }
        fprintf(f,"\n");
    }
    else{
         fprintf(f,"%d",chosen);
         fprintf(f,"\n");
    }
}

int main(int argc, char *argv[]){
    int rows, cols;
    int random;
    int size = atoi(argv[1]);
    int array[size][size];
    int *ptr = &array[0][0];
    int sortCol;
    FILE *f;
    
    f = fopen("assign1.log", "a+");
    initialize(ptr, size);
    display(ptr, size);
    logFile(ptr,size, 111 ,f);
    sortCol = printSorted(size, f);
    logFile(ptr,size, sortCol,f);
    sort(ptr, size, sortCol);
    display(ptr, size);
    logFile(ptr,size, 111,f);

    //keeps on asking for input untill 111 is inputed
    while (sortCol >= 0){
        sortCol = printSorted(size, f);
        logFile(ptr,size, sortCol,f);
        sort(ptr, size, sortCol);
        display(ptr, size);
        logFile(ptr,size, 111,f);
    }

    
    return 0;
}