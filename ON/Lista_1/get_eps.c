//Igor Misiek
//Obliczenia naukowe - Lista 1

#include <stdio.h>
#include <float.h>

int main() {
    printf("Float16 (half) epsilon maszynowy: C nie obsługuje\n");
    printf("Float32 (single) epsilon maszynowy: %e\n", FLT_EPSILON);
    printf("Float64 (double) epsilon maszynowy: %e\n", DBL_EPSILON);
    
    return 0;
}
