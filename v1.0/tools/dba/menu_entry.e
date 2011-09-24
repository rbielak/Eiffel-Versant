-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class MENU_ENTRY

inherit

creation

	make

feature {MENU}
	
	text: STRING;
	
	cmd: CMD
	
	make (new_text: STRING; new_cmd: CMD) is
		require
			new_text /= Void;
			new_cmd /= Void
		do
			text := new_text;
			cmd := new_cmd;
		end;

invariant

	text /= Void
	cmd /= Void

end -- MENU_ENTRY
