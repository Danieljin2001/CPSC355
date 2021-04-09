Name: Daniel Jin
UCID: 30107081
Project 1

Description:
This program is coded in C. The program is started with an integer (preferrably 5-20) in the command line (at argv[1]). 
The program asks the user if they want to see past scores, if they do, how many. (yes = 1, no = 0)
Then the programs asks the user for their name in order to store it into project1.log file.
Then the program generates random numbers from 0.01 to 15.00 in a N x N array (depending on commandline input).
The timer is started (timer = N * 12).
The program then shows the array to the user, and the user uncovers each element to add or decrease their score until either the score
is zero, timer is zero, every element is uncovered.

Functions:
In order to force quit, the user must type "111 111" when it asks for (x, y) coordinates.

Bonus:
This program implements the time package where, if the user uncovers an element with a symbol of "@"
then 30 seconds is added onto the timer.