-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Query that runs in memory and in the server. It's not efficient,
-- but it's most flexible
--

class MIXED_PATH_QUERY

inherit
	
	IN_DB_PATH_QUERY 
		redefine
			execute
		end

feature
	
	execute (in_vstr: VSTR; parms: ARRAY [ANY]): VSTR is
		do
			debug ("query")
				io.putstring ("mixed_path_query on class: ")
				if class_name /= Void then
					io.putstring (class_name)
				else
					io.putstring ("<unknown>")
				end
				io.new_line
			end

			Result := root_predicate_block.evaluate_block (in_vstr)
		end
	

end -- MIXED_PATH_QUERY
