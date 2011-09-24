-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Lock for PLISTs
--

class PLIST_LOCK

inherit
	
	DB_LOCK [PLIST [POBJECT]]
		redefine
			refresh_eiffel_object
		end

	DB_INTERNAL

creation
	
	make

feature {NONE}
	
	refresh_eiffel_object is
		do
			if object.pobject_id /= 0 then
				object.refresh_shallow
			end
		end
	

end -- PLIST_LOCK
