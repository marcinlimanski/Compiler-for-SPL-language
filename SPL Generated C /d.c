#include <stdio.h>
int main(void) {
float r1, r2, r3;
r1 = -2.4;
r2 = -34.989;
r3 = r1 * r2 / 7.4;
printf("%f", r3);
printf("\n");
scanf("%f", &r1);
r3 = r1 + r3;
printf("%f", r3);
printf("\n");

return 0;
}