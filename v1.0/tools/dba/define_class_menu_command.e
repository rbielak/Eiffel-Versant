-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DEFINE_CLASS_MENU_COMMAND

inherit

	CMD
	DEFINE_CLASS_ACTION
	
feature

	get_parents is
			-- Get parents for this class.
		local
			done : BOOLEAN;
		do
			!!parents.make;
			
			from
			until done
			loop
				io.putstring ("Enter parent name (CR to exit):");
				io.readline;
				if io.laststring.count > 0 then
					io.laststring.to_lower;
					parents.put_right (clone(io.laststring));
				else
					done := TRUE
				end;
			end; -- loop
		end; -- get_parents
	
	get_attributes is
			-- Get attributes for this class.
		local
			att_info : NEW_ATTR_INFO
		do		
			!!att_info
			attributes := att_info.get_the_attributes
		end
	
	
	
	execute is
		do
			io.putstring ("----> Defining a class. %N");
			io.putstring ("Enter class name: ");
			io.readline;
			cls_name := clone(io.laststring);
			get_parents
			get_attributes
			action
		end

end --class
