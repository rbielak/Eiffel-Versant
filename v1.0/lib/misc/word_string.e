-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--|---------------------------------------------------------------
--| Author: Richie Bielak
--| Created: Wed Feb 20 11:19:39 1991
--|
--| WORD_STRING - a string of words separated by blanks or
--|             user specified delimiters.

class WORD_STRING 
   
inherit
	STRING
		rename
			make as string_make
		export
			{NONE} all;
			{ANY} item, count
		end
	

creation
	make
   
   
   
feature 
	
	set_delimiters (nd : STRING) is
			-- specify delimiters
		do
			delimiters.wipe_out;
			delimiters.append (nd);
		end; -- set_delimiters
	
	
	make (n : INTEGER) is
			-- Create a WORD_STRING
		do
			string_make (n);
			!!delimiters.make (10);
			-- by default " " is a delimiter
			delimiters.append (" ");
		end; -- Create
	
	
	last_delimiter : CHARACTER;
			-- last delimiter found
	
	
	set_word_string (s : STRING) is
			-- assign new value 
		require
			string_not_void : not (s = Void)
		do
			last_position := 1;
			wipe_out;
			append (s);
		end;
	
	remove_word : STRING is
			-- remove the first word from the word string
		require
			position_valid : last_position > 0;
		local
			word_start : INTEGER;
		do
			if count /= 0 then
				skip_delimiters;
				word_start := last_position;
				if word_start <= count then
					skip_non_delimiters;
					-- extract word
					Result := substring (word_start, last_position - 1);
				end; -- if
			end; -- if
			-- last word was extracted. 
			if (Result = Void) then
				last_position := 0
			end;
		end; -- remove_first_word
	
	
	last_position : INTEGER;
			-- last position scanned
	
	
feature {NONE}
	
	delimiters : SEQ_STRING;
			-- characters that delimit a word

	
	skip_delimiters is
			-- skip past delimiter characters
		do
			from
			until
				last_position > count or else
				delimiters.index_of (item (last_position), 1) = 0
			loop    
				last_position := last_position + 1
			end; -- loop
		end; -- skip_delimiters
	
	
	skip_non_delimiters is
			-- skip past non-delimiter characters
		do
			from
			until
				last_position > count or else
				delimiters.index_of (item (last_position), 1) /= 0
			loop    
				last_position := last_position + 1
			end; -- loop
			if last_position <= count then
				last_delimiter := item(last_position);
			end;
		end; -- skip_non_delimiters

end -- class WORD_STRING
