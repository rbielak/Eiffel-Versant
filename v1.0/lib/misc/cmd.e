-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class CMD

feature

	execute is
			-- Execute command.
		deferred
		end

feature {NONE}

	undo is
			-- UNDO command. (redefine and export in heir)
		do
		end

end
