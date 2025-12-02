#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define FILENAME "input.txt"

long long int checkValueP1(long long int val) {
    char valText[16];
    sprintf(valText, "%lld", val);
    int length = strlen(valText);
    
    // Odd lengths are valid
    if (length%2 != 0) {
        return 0;
    }
    
    int patternExists = 1;
    // Loop over every division
    for (int j = 1; j < length; j++) {
        //printf("Division: %d\n", j);
        if (length%j != 0) {
            //printf("Cannot divide\n");
            continue; // If not able to divide, don't do anything
        }
        
        // Loop over each digit in the groups
        patternExists = 1;
        for (int k = 0; k < j; k++) {
            //printf("k: %d\n", k);
            // Check digit k of each group
            char digit = valText[k];
            int count = 0;
            for (int l = k+j; l < length; l += j) {
                count++;
                //printf("l: %d - %c %c\n", l, valText[k], digit);
                if (valText[l] != digit) {
                    patternExists = 0;
                    break;
                }
            }
            
            // Basically some hotfix to force it to be valid if there is more than one repetition
            if (count > 1) {
                patternExists = 0;
            }
        }
        if (patternExists == 1) {
            break;
        }
    }
    if (patternExists == 1) {
        //printf("%lld\n", val);
        return val;
    }
    return 0;
}

long long int checkValueP2(long long int val) {
    char valText[16];
    sprintf(valText, "%lld", val);
    int length = strlen(valText);
    
    // Ln=ength of 1 is valid
    if (length == 1) {
        return 0;
    }
    
    int patternExists = 1;
    // Loop over every division
    for (int j = 1; j < length; j++) {
        //printf("Division: %d\n", j);
        if (length%j != 0) {
            //printf("Cannot divide\n");
            continue; // If not able to divide, don't do anything
        }
        
        // Loop over each digit in the groups
        patternExists = 1;
        for (int k = 0; k < j; k++) {
            //printf("k: %d\n", k);
            // Check digit k of each group
            char digit = valText[k];
            int count = 0;
            for (int l = k+j; l < length; l += j) {
                count++;
                //printf("l: %d - %c %c\n", l, valText[k], digit);
                if (valText[l] != digit) {
                    patternExists = 0;
                    break;
                }
            }
        }
        if (patternExists == 1) {
            break;
        }
    }
    if (patternExists == 1) {
        //printf("%lld\n", val);
        return val;
    }
    return 0;
}

int main() {
    FILE* f = fopen(FILENAME, "r");
    
    long long int sumP1 = 0;
    long long int sumP2 = 0;
    long long int val1 = 0;
    long long int val2 = 0;
    
    while (!feof(f)) {
        fscanf(f, "%lld-%lld,", &val1, &val2);
        //printf("%lld-%lld\n", val1, val2);
        
        // Loop over every value in the range
        for (long long int i = val1; i <= val2; i++) {
            sumP1 += checkValueP1(i);
            sumP2 += checkValueP2(i);
        }
    }
    
    printf("%lld\n", sumP1);
    printf("%lld\n", sumP2);
    fclose(f);
}