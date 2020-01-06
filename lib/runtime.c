#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char * const EMPTY_STR = "";

void printInt(int n) {
    printf("%d\n", n);
}

void printString(char * s) {
    printf("%s\n", s);
}

int readInt() {
    int n;
    scanf("%d", &n);
    return n;
}

char * readString() {
    char * line = NULL;
    size_t size;
    int length;
    while ((length = getline(&line, &size, stdin)) <= 1) {
        if (length == -1) {
            return EMPTY_STR;
        }
    }
    line[length - 1] = '\0';
    return line;
}

char * __concat(char * s1, char * s2) {
    char *result = malloc(strlen(s1) + strlen(s2) + 1);
    strcpy(result, s1);
    strcat(result, s2);
    return result; 
}

int __strEq(char * s1, char * s2) {
    return strcmp(s1, s2) == 0; 
}

void error() {
    printf("%s\n", "runtime error");
    exit(1);
}
