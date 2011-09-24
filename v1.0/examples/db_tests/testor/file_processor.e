-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class FILE_PROCESSOR

inherit
	
	SHARED_TEST_SESSION
	SPLIT_STRING

creation
	
	make
	
feature
	
	separator: CHARACTER is ','
	
	
	add_command (cmd: DB_TEST_COMMAND; name: STRING) is
		require
			cmd /= Void
			name /= Void
		do
			name.to_lower
			cmd_table.put (cmd, name)
		end
	
	
	file: PLAIN_TEXT_FILE
			-- input file
	
	current_command: DB_TEST_COMMAND
			-- last command

	count: INTEGER
			-- number of lines processed

	verify_database : BOOLEAN

	set_verify_mode is
		do
			verify_database := True
		end

	process (fname: STRING) is
		local
			i: INTEGER
		do
			!!file.make_open_read (fname)
			from 
			until file.end_of_file
			loop
				file.read_line
				if (file.laststring.count >= 2) and not
					file.laststring.substring (1,2).is_equal ("--")
				 then
					process_line (split_into_parameters (file.laststring))
					count := count + 1
				end
				i:= i + 1
				if i > 100 then
					session.end_transaction
					session.start_transaction
					i := 0
				end
			end
		end

feature {NONE}
	
	cmd_table : HASH_TABLE [DB_TEST_COMMAND, STRING]
	
	make is
		do
			!!cmd_table.make (20)
		end
	
	process_line (parms: ARRAY [STRING]) is
		local
			cmd_name: STRING
		do
			cmd_name := parms @ 1
			cmd_name.to_lower
			current_command := cmd_table.item (cmd_name)
			if current_command = Void then
				io.putstring ("*** Error in the input file. No command:  <")
				io.putstring (parms @ 1)
				io.putstring ("> found. %N")
			else
				current_command.set_args (parms)
				if verify_database then 
					current_command.verify
				else
					current_command.execute
				end
			end
		end

invariant

end -- FILE_PROCESSOR
