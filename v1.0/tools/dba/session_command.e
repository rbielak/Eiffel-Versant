-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SESSION_COMMAND

inherit

	ARGUMENT_CHECKER_CMD

	SESSION_ACTION
		undefine
			is_equal
		end
	

creation

	make

feature

	minimum_args_count : INTEGER is 1

	not_enough_args_msg : STRING is "database not specified"

	make (new_priority: INTEGER) is
		do
			help_text := "-d <database name1> [..<db_name2>..] %N"
			priority := new_priority
		end

	execute is
		local
			conn_cmd : CONNECT_DB_ACTION
		do		   
			args.start
			io.putstring ("Connecting database: ")
			io.putstring (args.item)
			io.new_line
			-- 
			set_db_name (args.item)
		    action			
			from
				args.forth
				!!conn_cmd
			until 
				args.off
			loop
				conn_cmd.set_connect_db (args.item)
				conn_cmd.action
				args.forth
			end
		end

end
