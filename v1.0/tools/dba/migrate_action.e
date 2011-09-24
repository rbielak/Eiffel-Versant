-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class MIGRATE_ACTION

inherit

	DBA_TRANSACTION
	DB_CONSTANTS
	VERSANT_EXTERNALS

feature

	error_msg : STRING is "Cannot move object";

	from_db, to_db, loid : STRING

	from_menu_cmd : BOOLEAN

	set_the_info (source_db,destination_db,localid: STRING; menu_cmd: BOOLEAN) is
		do
			from_db := source_db
			to_db := destination_db
			loid := localid
			from_menu_cmd := menu_cmd
 		end

	object_id: INTEGER

	sub_action is
		local
			except : expanded EXCEPTIONS
			root_id: INTEGER

		do
			if sess.find_database (from_db) = Void then
				io.putstring ("Error: you are not connected to database:")
				io.putstring (from_db)
			elseif sess.find_database (to_db) = Void then
				io.putstring ("Error: you are not connected to database:")
				io.putstring (to_db)
			else
				-- Connected to both dbs - find the object
				object_id := c_scan_loid ($(loid.to_c))
				if object_id = 0 then
					io.putstring ("Error: cannot find object %N")
				else
					if o_migrateobj (object_id, 
							      $(from_db.to_c), 
							      $(to_db.to_c)) /= 0 then
						except.raise ("can't migrate object")
					end
					root_id := get_db_int_attr (object_id, $(("pobject_root_id").to_c))
					io.putstring ("Current root_is is [")
					io.putint (root_id)
					io.putstring ("]. DBID=")
					io.putint (root_id // max_roots_per_db)
					io.putstring (" Root Index=")
					io.putint (root_id \\ max_roots_per_db)
					io.new_line
					if from_menu_cmd then
						io.putstring ("Enter new ID or (-1) if you want to keep this one:")
						io.readint					
					end
				end
			end
			io.new_line
		end -- feature

end   -- class migrate
		
