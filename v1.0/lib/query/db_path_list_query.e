-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Do a path query on a list of objects
-- 

class DB_PATH_LIST_QUERY [T -> POBJECT]

inherit
	
	DB_CLASS_QUERY [T]
		redefine
			execute
		select
			execute
		end
	
	DB_CLASS_QUERY [T]
		rename
			execute as db_class_query_execute
		end

creation
	
	make

feature
	
	list_to_query: like last_result
			-- list to query
	
	
	
	set_list_to_query (llist: like last_result) is
		do
			list_to_query := llist
		end
	
	
	execute is
			-- do a query on the list. The query returns
			-- Void list if the list_to_query is Void
		do
			if list_to_query /= Void then
				db_class_query_execute
				if last_result /= Void then
					last_result.intersect_with (list_to_query)
					-- If there is nothing left make the result Void
					if last_result.count = 0 then
						last_result := Void
					end
				end
			end
		end

end -- DB_PATH_LIST_QUERY
