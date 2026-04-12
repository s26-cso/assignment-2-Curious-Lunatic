#include<stdio.h>
#include<string.h>
#include<dlfcn.h> // for loading .so files
typedef int (*fptr)(int, int); // now given the function has signature int, int->int so the fptr must be of that type
int main(){
    char op[6]; // now it is given the string is at most 5 char so the 6 char for '/0'
    int n1,n2;
    // loop as long we get the required the 3 inputs always
    while(scanf("%5s %d %d",op,&n1,&n2)==3){
    char libname[20]; // array to build the shared library filename
    strcpy(libname, "./lib"); // need to start the filename with ./lib
    strcat(libname, op); // add the operation name to it
    strcat(libname, ".so"); // add .so to finish filename
    void *handle = dlopen(libname, RTLD_LAZY); // bring the library into the memory
    fptr fn = dlsym(handle, op); // get a pointer to the math function
    printf("%d\n", fn(n1,n2)); // print the answer
    dlclose(handle); // close the memory so it does not exceed the given constraint of 2GB
}
    return 0;
}
