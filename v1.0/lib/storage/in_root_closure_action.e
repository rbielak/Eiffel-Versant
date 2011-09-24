-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Closure action for fining all objects in one persistent root
--

class IN_ROOT_CLOSURE_ACTION

inherit
	
	POBJECT_ACTION_COMMAND 
		redefine
			execute
		end

creation
	
	make

feature
	
	execute (closure: TWO_WAY_LIST [POBJECT]; object: POBJECT) is
		do
			-- add object to the closure only if the object is in the
			-- same peristence root as the root of the closure
			if object.pobject_id /= 0 then
				if object.pobject_root_id = root.pobject_root_id then
					closure.extend (object)
					object.set_closure_position (closure.count)
				end
			end
		end

end -- IN_ROOT_CLOSURE_ACTION
