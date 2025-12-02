#include <stdio.h>
#include <stdlib.h>

#define FILENAME "input.txt"

void Part1() {
    FILE* f = fopen(FILENAME, "r");
    
    int password = 0;
    int rotation = 50;
    
    char rd;
    int ra;
    while (!feof(f)) {
        fscanf(f, "%c%d\n", &rd, &ra);
        
        if (rd == 'R') {
            rotation += ra;
        } else {
            rotation -= ra;
        }
        
        rotation %= 100;
        //int pr = rotation; // Debug stuff
        if (rotation < 0) {
            rotation = 100+rotation; // Make sure it wraps from 100
        }
        
        if (rotation == 0) {
            password++;
        }
        //printf("%c%d - %d %d\n", rd, ra, rotation, pr); // Debug
    }
    
    printf("Password: %d\n", password);
    fclose(f);
}

void Part2() {
    FILE* f = fopen(FILENAME, "r");
    
    int password = 0;
    int rotation = 50;
    
    char rd;
    int ra;
    while (!feof(f)) {
        fscanf(f, "%c%d\n", &rd, &ra);
        
        int d = 1;
        if (rd == 'L') {
            d = -1;
        }
        
        // Basically, brute force the fuck out of it, cuz I am lazy and it's too late..
        for (int i = 0; i < abs(ra); i++) {
            rotation += d;
            
            if (rotation < 0) {
                rotation = 99;
            } else if (rotation > 99) {
                rotation = 0;
            }
            
            if (rotation == 0) {
                password++;
            }
        }
    }
    
    printf("Password: %d\n", password);
    fclose(f);
}

int main() {
    Part1();
    Part2();
}