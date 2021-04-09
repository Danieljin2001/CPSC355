//Name: Daniel Jin
//UCID: 30107081
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

//this function asks to enter in the name and saves it in name in main
void getName(char *name){
    printf("Enter in your name: ");
    scanf("%s", name);
}

//this function initializes a 2D array (size * size)
void initialize(double *table, int size){
    int rows;
    int cols;
    double random;  //random will be a float
    int i; 
    int amount = (size*size) * 0.2; //this carrys the total amount of elements in the table
    int x;
    int y;
    int sign = 1; //this is used for making the positive and negative surprises

    srand(time(0)); 
    for(rows = 0; rows < size; rows++){ //for each row
        for(cols = 0; cols < size; cols++){ //for each column in that row
            random = (((double)rand() / (double)RAND_MAX) * 14.99) + 0.01; //inspired by: https://stackoverflow.com/questions/4310277/producing-random-float-from-negative-to-positive-range
            *((table+rows*size) + cols) = random; //making random element

        }  
    }

    //this is for negative doubles
    for (i=0; i < amount; i++){ //iterates for 20% of the total amount of elements
        x = rand() %size; //random x coordinate(range is from 0 to size of array - 1)
        y = rand() %size; //random y coordinate for the negative values
        double a = (*((table+x*size) + y)) * -1; //multiply element by -1
        *((table+x*size) + y) = a; //element is not negative
    }

    //this is for ! and $ surprises
    for (i=0; i < 2; i++){ //makes two surprises
        x = rand() %size; //random x coordinate (range is from 0 to size of array - 1)
        y = rand() %size; //random y coordinate for the surprises
        double a = 50 * sign; //making one positive surprise
        *((table+x*size) + y) = a; //make element equal surprise
        sign = sign * -1; //getting ready to make next negative surpirse
    }

    //this is for @ surprise
    x = rand() %size; //random x coordinate (range is from 0 to size of array - 1)
    y = rand() %size; //random y coordinate for the surprises
    double a = 60; //making one time surprise
    *((table+x*size) + y) = a; //make element equal surprise
}

//this function changes the timer
int changeTime(int constantTime, unsigned long currentTimer){ //constanttime is the time that is given to the play at the very start, currentTime is the current time of the system
    int changeTime;
    unsigned long newTime = time(0); //get current time of system
    changeTime = constantTime - (newTime - currentTimer); //(newTime - currentTime) is going to result in a positive number representing the time that has changed (in secs), you then get the difference between changed time and constant time
    if (changeTime <= 0){ //if timer <=0 then make it 0, or else it will keep changing into the negatives
        changeTime = 0;
    }
    return changeTime; //this is the result of the (given timer - seconds that passed)
}

//this function asks, checks and records the coordinate
//this function also prints out the result and updates the time
//also, if you input in 111 111 when a move is asked, it quits the game
double getCoo(double *table, int size, int * end, double *score, int *timer, unsigned long *startTime1){
    int x;  
    int y;
    int a; //used to temporarily store the score as an int, then LSR or LSL
    double element = 0; //returned amount of the hidden element
    int givenTime = 12*(size); //givenTime is a constant used for changetime() function
    unsigned long startTime = *startTime1; //startTime is used for change time, and startTime1 is used to change the time the program started by 30 seconds if the surprise is found
    printf("Enter in your move (x, y): \n");
    scanf("%d %d", &x, &y);

    *timer = changeTime(givenTime, startTime); //gets the timer right away right after user inputs something, takes into consideration of how long it took the user to decide
    if(*timer == 0){ //if timer is == 0, then return element (element = 0), because nothing after timer runs up will be added to the score
        return element;
    }

    if(x == 111 && y == 111){ //if the input is 111 111 it force quits the program
        *end = 1;   //changes value of end in main from 0 to 1
        return element; //returns element with value of zero so that score doesnt change but also breaks function
    }

    if((*((table+x*size) + y) >= -30) && (*((table+x*size) + y) <= 30)){ //if element is greater than -30 and less than 30, then its a new element (because elements go from ~0 to 15 but made it 30/-30 to easily read) 
        if(*((table+x*size) + y) > 0){//if the element is positive then its a gain
            printf("\n");
            printf("\nUncovered a reward of %0.2f points\n",*((table+x*size) + y) );
            element = *((table+x*size) + y);//returns element
            *((table+x*size) + y) = 100; //this element is then changed to 100 so that it cant be used again (100 is not less than 30)
        }
        else if(*((table+x*size) + y) < 0){ //this is if the element is negative
            printf("\n");
            printf("\nBang!! you lost %0.2f points\n",*((table+x*size) + y) * -1 );
            element = *((table+x*size) + y); //returns element
            *((table+x*size) + y) = -100; //this element is then changed to -100 so that it cant be used again (-100 is not greater than -30)
        }
    }
    else if (*((table+x*size) + y) == -50) //if the element is less than -30, and equals -50 then its indicated as a bad surprise
    {
        printf("Bad suprise! Half your score\n");
        *((table+x*size) + y) = -200; //this is then set to -200 so that it cannot be used again (-200 is less than -30 )
        a = *score; //temporarily sets "a" as dereference of score (value)
        a = a >> 1; //shifts int a LSR once
        *score = a; //score in main is now set to value of a
    }
    else if (*((table+x*size) + y) == 50) //same thing as above but for good surprise
    {
        printf("Good surprise! Double your score\n");
        *((table+x*size) + y) = 200;
        a = *score;
        a = a << 1;
        *score = a;
    }
    else if (*((table+x*size) + y) == 60) //same thing as above but for time surprise
    {
        printf("Time surprise! Add 30 seconds to the clock\n");
        *((table+x*size) + y) = 250;
        *startTime1 += 30;  //adds 30 seconds to the time the program started (minimizes difference)
        *timer = changeTime(givenTime, startTime); //updates time
    }
    

    else{
        printf("oops already tried that area!\n"); //if its >30 and <-30 but not 50 or -50, element has already been opened (element is either 100,-100,-200,200)
    }
    return element; //returns 0
}


//this function displays to the user what the table is looking like 
void display2(double *table, int size, double score, int timer){
    int rows;
    int cols;
    for(rows = 0; rows < size; rows++){
        printf("\n");
        for(cols = 0; cols < size; cols++){
            if( *((table+rows*size) + cols) > -100 && *((table+rows*size) + cols) < 100  ){ //if element is >-100 and <100 then it is not opened yet
            printf("*");    //prints * to indicated as not used
            }
            else if(*((table+rows*size) + cols) == -100){ //if element is -100 then its been opened and in it used to be a negative number
                printf("-"); //prints - to indicated opened and used to be negative
            }
            else if(*((table+rows*size) + cols) == +100){//if element is 100 then its been opened and in it used to be a positive number
                printf("+");//prints + to indicated opened and used to be positive
            }
            else if(*((table+rows*size) + cols) == -200){//if element is -200 then its been opened and in it used to be a negative surprise
                printf("!");//prints ! to indicated opened and used to be positive
            }
            else if(*((table+rows*size) + cols) == +200){//if element is +200 then its been opened and in it used to be a positive surprise
                printf("$");//prints $ to indicated opened and used to be positive surprise
            }
            else{
                printf("@");//if element is 250 then its been opened and in it used to be a timer surprise
            }               //prints @ to indicated opened and used to be time surprise
        }
    
    }
    printf("\nScore: %0.2f\n",score);
    printf("Time: %d\n",timer);
} 

//this function checks to see if the elements have all been opened, score is <= 0, if its the first turn or not
int exitGame(double *table, int size, int time, double score, int turn){
    int rows;
    int cols;
    int uncovered = 0; //set to (size*size) if every element has been uncovered
    int end = 0; //set to 1 if any of the "ending" requirements are met
    for(rows = 0; rows < size; rows++){
        for(cols = 0; cols < size; cols++){
            if( *((table+rows*size) + cols) <= -100 ||  *((table+rows*size) + cols) >= 100){ //checks if the element is opened or not 
                uncovered += 1; //if opened, uncovered is += 1
            }
        }
    }    
    if (uncovered == (size * size)){ //if uncovered amount == total amount of elements then its game over
        end = 1;
    }
    if (time == 0){ //if time is zero game over
        end = 1;
    }
    if (turn > 1){ //after first turn if score is less than or equal to zero, game over
        if (score <= 0){
            end = 1;
        }
    }
    return end;
}

//this function appends to file the name, highscore and time
void logScore(double score, int time, char *name, FILE *f){
    f = fopen("project1.log", "a+"); //opens the file to append
    fprintf(f,"%s :     Score: %0.2f      Time: %d \n", name, score, time); //appends this into it
    fclose(f);  //close file
}
//this function asks user if they want to see the scores, and if they do it asks how many score
void displayTopScore (FILE *f){
    int input; //yes = 1, no = 0
    int n; //amount of scores
    int i = 0; //counter
    char line[150]; //this gets printed out
    f = fopen("project1.log", "a"); //opens file (if there is no file, it makes a new one)
    fclose(f); //close file
    f = fopen("project1.log", "r"); //reads file
    printf("Would you like to see the top scores? (enter: 1 for yes, 0 for no): \n");
    scanf("%d", &input);
    if (input == 1){
        printf("How many scores would you like to see? \n");
        scanf("%d", &n);
        while(i < n){ //amount of lines to read
            fgets(line, 150, f); //reads 150 characters from file
            puts(line); //reads up to the end (including \n)
            i ++;
        }
    }
    fclose(f); //close file
}


int main(int argc, char *argv[]){
    int size = atoi(argv[1]);
    double score = 0.00;
    int timer = 12*(size);
    unsigned long startTime;
    int end = 0;
    int turn = 0;

    FILE *f;

    char name[30];
    double array[size][size];
    double *ptr = &array[0][0];
    displayTopScore (f);

    getName(name);
    printf("Enter in '111 111' to force quit game. \n");
    initialize(ptr, size);
    startTime = time(0);

    while(exitGame(ptr, size, timer, score, turn) == 0 && end == 0){ 
        display2(ptr, size, score, timer);
        score += getCoo(ptr, size, &end, &score, &timer, &startTime);
        turn += 1;
    }
    printf("Game over!\n");
    printf("Ended with a score of %0.2f and a time of %d\n", score, timer);
    logScore(score, timer, name, f);
    displayTopScore (f);
}
