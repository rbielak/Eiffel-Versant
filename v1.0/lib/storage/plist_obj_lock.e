-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Lock for PLIST_OBJ[POBJECT]
-- 
class PLIST_OBJ_LOCK 

inherit

	DB_LOCK [PLIST_OBJ [POBJECT]]
		redefine
			refresh_eiffel_object
		end

creation 

	make

feature
		
	refresh_eiffel_object is
			-- lists are refreshed shallowly in locks
		do
			if object.pobject_id /= 0 then
				object.refresh_shallow
			end
		end

end
