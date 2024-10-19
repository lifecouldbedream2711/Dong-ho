#include <graphics.h>
#include <iostream>
#include <cmath>
#include <ctime>

#define PI 3.14159265358979323846
using namespace std;


int main()
{
    initwindow(500,500,"ANALOG CLOCK");
    
    int page=0;
    settextstyle(DEFAULT_FONT,HORIZ_DIR,3
	);
    while(1)
    	{
         setactivepage(page);
         setvisualpage(1-page);
         cleardevice();
         setcolor(WHITE);
         circle(250,250,220);
         circle(250,250,5);
    
         time_t now = time(0);
         tm *ltm = localtime(&now);
         
         setcolor(RED);
         line(250,250,250+150*sin(ltm->tm_hour * PI/6),250-150*cos(ltm->tm_hour * PI/6));
         setcolor(GREEN);
         line(250,250,250+190*sin(ltm->tm_min * PI/30),250-190*cos(ltm->tm_min * PI/30));
         setcolor(WHITE);
         line(250,250,250+150*sin(ltm->tm_sec * PI/30),250-150*cos(ltm->tm_sec * PI/30));
         outtextxy(250+200*sin(1*PI/6)-13 , 250-200*cos(1*PI/6)-8 , "1");
         outtextxy(250+200*sin(2*PI/6)-15 , 250-200*cos(2*PI/6) -10, "2");
         outtextxy(250+200*sin(3*PI/6)-14 , 250-200*cos(3*PI/6)-12 , "3");
         outtextxy(250+200*sin(4*PI/6)-15 , 250-200*cos(4*PI/6)-10 , "4");
         outtextxy(250+200*sin(5*PI/6)-15 , 250-200*cos(5*PI/6) -16, "5");
         outtextxy(250+200*sin(6*PI/6)-15 , 250-200*cos(6*PI/6) -15, "6");
         outtextxy(250+200*sin(7*PI/6)-13 , 250-200*cos(7*PI/6) -16, "7");
         outtextxy(250+200*sin(8*PI/6)-9 , 250-200*cos(8*PI/6)-17 , "8");
         outtextxy(250+200*sin(9*PI/6)-8 , 250-200*cos(9*PI/6)-15 , "9");
         outtextxy(250+200*sin(10*PI/6)-10 , 250-200*cos(10*PI/6)-10 , "10");
         outtextxy(250+200*sin(11*PI/6)-10 , 250-200*cos(11*PI/6) -9, "11");
         outtextxy(250+200*sin(12*PI/6)-15 , 250-200*cos(12*PI/6) -9, "12");
         if(GetAsyncKeyState(VK_RETURN))
              break;
         delay(10);
         
         page = 1-page;
    }
	closegraph();
	return 0;
}
