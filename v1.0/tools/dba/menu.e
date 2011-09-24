-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class MENU

creation
	make

feature
	
	put(text : STRING; cmd : CMD) is
		require
			text /= Void;
			cmd /= Void;
		local
			me : MENU_ENTRY;
		do
			!!me.make (text, cmd);
			last_item := last_item + 1
			items.put (me, last_item);
		end;
	
	display is
		local
			i : INTEGER;
			me : MENU_ENTRY;
		do
			from i := 1
			until i > last_item
			loop
				me := items.item(i);
				io.putstring ("    < ");
				io.putint (i);
				io.putstring (" >");
				if i < 10 then
					io.putstring ("  ");
				else
					io.putstring (" ");
				end;
				io.putstring (me.text);
				io.new_line;
				i := i + 1;
			end;
		end;
	
	item (number : INTEGER) : CMD is
		require
			number <= last_item
		do
			Result := items.item (number).cmd;
		end;
	
	make (max_item : INTEGER) is
		require
			max_item > 0;
		do
			!!items.make (1,max_item)
		end;
	
	last_item : INTEGER;

feature{NONE}
	
	items : ARRAY [MENU_ENTRY]


invariant

end -- MENU
