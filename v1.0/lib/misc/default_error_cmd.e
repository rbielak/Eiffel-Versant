-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DEFAULT_ERROR_CMD

inherit

	ARGUMENT_COMMAND

feature

	execute is
		do
			io.put_string ("*** Error in command line. Expected '-argument' instead found:")
			if args /= Void then
				from args.start
				until args.off
				loop
					io.put_string ("arg-->")
					io.put_string (args.item)
					io.new_line
					args.forth
				end
			else
				io.put_string ("*** no arguments.")
				io.new_line
			end
			io.put_string ("---------------%N")
			io.new_line
		end

invariant

end
