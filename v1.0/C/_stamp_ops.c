#include <stdio.h>

/* 
   operations on rights stamps
*/

#define READ_MASK 1
#define WRITE_MASK 2
#define ADD_MASK 4
#define DELETE_MASK 8
#define DISPLAY_MASK 16

int c_check_read (int rights_stamp)
{
  return (rights_stamp & READ_MASK);
}

int c_check_write (int rights_stamp)
{
  return (rights_stamp & WRITE_MASK);
}

int c_check_add (int rights_stamp)
{
  return (rights_stamp & ADD_MASK);
}

int c_check_delete (int rights_stamp)
{
  return (rights_stamp & DELETE_MASK);
}

int c_check_display (int rights_stamp)
{
  return (rights_stamp & DISPLAY_MASK);
}

int c_and_stamps (int s1, int s2)
{
  return ( s1 & s2);
}

int c_or_stamps (int s1, int s2)
{
  return (s1 | s2);
}
