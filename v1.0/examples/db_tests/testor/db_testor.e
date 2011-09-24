-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class DB_TESTOR

inherit
	
	SHARED_TEST_SESSION

creation
	
	make

feature
	
	args:  ARRAY [STRING] is
		local
			a: ARGUMENTS
		once
			!!a
			Result := a.argument_array
		end
	
	file_name: STRING
	
	db_name: STRING

	make is
		local 
			error_occurred : BOOLEAN
			n: INTEGER
			query_mode_set : BOOLEAN
		do
			if args.count < 4 then
				io.putstring ("Usage: db_testor -d <db-name> <-feed, -verify, -query> <file-name>%N")
			else
				!!file_processor.make
				make_commands
				if args.item (1).is_equal ("-d") then				
					db_name := args.item (2)
					file_name := args.item (4)
				    n:= 3
				else
					if args.item (3). is_equal ("-d") then
						db_name := args.item (4)
						file_name := args.item (2)
						n:= 1
					else
						error_occurred := True
					end
				end			
				
				if not error_occurred then					
					if args.item (n).is_equal ("-verify") then
						file_processor.set_verify_mode					
					elseif args.item (n).is_equal ("-query") then
						query_mode_set := True							
						-- to verify later on..
					elseif args.item (n) .is_equal ("-feed") then	
						--  feed data
					else	
						error_occurred := True
					end					
				end
				if not error_occurred then
					session.begin (db_name)
					session.start_transaction
					io.putstring ("--> Connected to db: ")
					io.putstring (db_name)
					io.new_line
					file_processor.process (file_name)
					roots.store_differences
					session.end_transaction
					if query_mode_set then
						--  second run for memory verification
						file_processor.set_verify_mode
						file_processor.process (file_name)
					end
					session.finish
				else
					io.putstring (" INVALID ENTRY : TRY AGAIN. %N")
				end
			end
		end
	
	file_processor: FILE_PROCESSOR

	roots: PERSISTENT_ROOTS is
		once
			!!Result
		end
	
	make_commands is
		local
			cmd: DB_TEST_COMMAND
		do
			!ADD_COMMAND!cmd
			file_processor.add_command (cmd, "add")
			!MARRY_COMMAND!cmd
			file_processor.add_command (cmd, "marry")
			!CHILD_COMMAND!cmd
			file_processor.add_command (cmd, "kid")
			!FRIEND_COMMAND!cmd
			file_processor.add_command (cmd, "buddy")
			!BEST_FRIEND_COMMAND!cmd
			file_processor.add_command (cmd, "best")
			!QUERY_COMMAND!cmd  
			file_processor.add_command (cmd, "query")			
		end

end -- DB_TESTOR
