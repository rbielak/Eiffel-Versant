-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class ARGUMENT_COMMAND

inherit

	CMD

feature

	do_not_connect_to_database: BOOLEAN is
				-- Default value is false.
				-- That means that Rainbow connects to the database if nobody says no.
				-- Can be redefined.
		do
		end

	add_command_arg (new_arg: STRING) is
			-- Add an argument for this command
		require
			arg_valid: new_arg /= Void
		do
			if args = Void then
				!!args.make
			end
			args.extend (new_arg)
		ensure
			args.has (new_arg)
		end

	help_text: STRING
			-- help text, could be Void

feature {NONE}

	args: LINKED_LIST [STRING]
			-- Arguments passed on command line

end
