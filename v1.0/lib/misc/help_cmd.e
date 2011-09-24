-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class HELP_CMD

inherit

	ARGUMENTS
		undefine
			is_equal
		end
	
	RAINBOW_CMD
		redefine
			do_not_connect_to_database
		end
		
creation
	
	make
	
feature

    do_not_connect_to_database: BOOLEAN is
            -- Redefine the value.
			-- Is true in NO_DATABASE_CMD
        do
			Result := true
        end

	processor: CMD_PROCESSOR [ARGUMENT_COMMAND]
			-- processor handling this and other commands
	
	set_processor (new_processor: CMD_PROCESSOR [ARGUMENT_COMMAND]) is
		require 
			new_processor /= Void
		do
			processor := new_processor
		end
	
	make (new_priority : INTEGER) is
		do
			help_text := "-help %N"        
			command_make (new_priority)
		end
    
	
	execute is
		local
		do
			io.putstring ("%NUsage:  ")
			io.putstring (command_name)
			io.new_line
			processor.help
		end

end -- HELP_CMD
