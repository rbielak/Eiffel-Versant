/*

   Match wild card patterns agains a string. Wild card pattern
   is like this:  "foo*bar*", where "*" matches zero to infinity
   parameters.

*/

int match_wild_card (char *string, char* pattern) {
  int str_pos, pat_pos, star_pos;
  int match;
  
  str_pos = 0;
  pat_pos = 0; 
  star_pos = -1;
  match = 0;
  
  do
    {
	  /*
		printf ("     P_pos=%d S_pos=%d *_pos=%d\n", pat_pos, str_pos, star_pos);
		printf ("     String=<%s> Pat=<%s> \n", string, pattern);
	  */
      if (pattern[pat_pos] == '*') {
		/* Pattern has a wild star */
		star_pos = pat_pos;
		pat_pos++;
	  }
      else if (pattern[pat_pos] == string[str_pos]) {
		/* Character matches */
		pat_pos++; 
		str_pos++;
	  }
      else {
		/* Match failed - fall back in the pattern to an asterisk */
		if (star_pos >= 0) 
		  pat_pos = star_pos + 1;
		/* Otherwise, the match failed */
		else
		  return (0);
		/* Advance string position */
		str_pos++;
	  }

	  
      /* Got to the end of the pattern and the string - we have a match */
      if ((pattern[pat_pos] == '\0') && (string[str_pos] == '\0'))
		return (1);
      /* Got to the end of the string, but not the pattern */
      else if (string[str_pos] == '\0') {
		/* Still have a match if the pattern ends in a "*" */
		if ((pattern[pat_pos] == '*') && (pattern[pat_pos+1] == '\0'))
		  return (1);
		else
		  return (0);
      }
      /* Got to the end of pattern and there is no "*" to fall back to */
      else if ((pattern[pat_pos] == '\0') && (star_pos == -1))
		return (0);
    }
  while (1);
}


