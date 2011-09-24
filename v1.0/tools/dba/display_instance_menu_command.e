-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DISPLAY_INSTANCE_MENU_COMMAND

inherit
	
	DISPLAY_INSTANCE_ACTION
	CMD

feature

	execute is
		local
			s:STRING
		do
			io.putstring ("Enter LOID : ")
			io.readline
			set_id (io.laststring)
			action
		end

end 
	

	
