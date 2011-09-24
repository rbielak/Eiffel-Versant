-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Retrieves lists of database names
--

class DB_LIST_RETRIEVER

creation
	
	make 

feature
	
	database_names (pattern : STRING) : FAST_LIST [STRING] is
			-- List of database names matching the
			-- specified patten (pattern can contain "*")
		require
			patter_ok: pattern /= Void
		local
			context : POINTER
			done : BOOLEAN
			one_db : STRING
		do
			context := c_db_list_start ($(database.name.to_c), $(pattern.to_c));
			!!Result.make;
			from 
			until done
			loop
				one_db := c_db_list_next (context)
				if one_db /= Void then
					Result.extend (one_db)
				else
					done := True
				end
			end
			c_db_list_end (context)
		ensure
			result_there: Result /= Void
		end
	
feature {NONE}
	
	make (db : DATABASE) is
			-- Make a db_list_retriever for databases in the
			-- same db-id space as the input db
		require
			db_not_void: db /= Void
		do
			database := db
		end
	
	database : DATABASE
	
feature {NONE} -- external
	
	c_db_list_start (db_name : POINTER; pattern : POINTER) : POINTER is
		external "C"
		end
	
	c_db_list_end (context : POINTER) is
		external "C"
		end

	c_db_list_next (context : POINTER) : STRING is
			-- return Void if no more
		external "C"
		end
		
	

end -- DB_LIST_RETRIEVER
