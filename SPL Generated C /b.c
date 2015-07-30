#include <stdio.h>
int main(void) {
int a, b, c;
float d, e;
char f;
scanf("%d", &a);
scanf("%d", &b);
if (a > b) { 
printf("%c", 'A');
}
else { 
printf("%c", 'B');
}
printf("\n");
scanf("%f", &d);
e = d * 2.3;
printf("%f", e);
printf("\n");
scanf(" %[^\n]c", &f);
printf("%c", f);
printf("\n");

return 0;
}