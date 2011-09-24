-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class DATABASE_COMMAND

inherit
	
	ARGUMENT_COMMAND

feature
	
	database_name: STRING

	execute is
		do
			database_name := args.i_th (1)
		end

end -- DATABASE_COMMAND
