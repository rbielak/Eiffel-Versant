-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class ARGUMENT_CHECKER_CMD 

inherit
	
	PRIORITY_ARG_COMMAND
		rename
			execute as priorities_arg_cmd_execute
		end

feature

	minimum_args_count: INTEGER is
		deferred
		end


	priorities_arg_cmd_execute is
		local
			local_count : INTEGER
		do
			if args /= Void then
				local_count := args.count
			end

			if minimum_args_count > local_count then
				io.putstring (not_enough_args_msg)
				io.new_line
			else
				execute
			end
		end

	execute is
		deferred
		end

	not_enough_args_msg: STRING is
		deferred
		end

end
