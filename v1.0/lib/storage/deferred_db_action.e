-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "Database related actions deferred to just before commit"

deferred class DEFERRED_DB_ACTION

feature

	action_on_commit is
			-- perform this routine just before commit
		deferred
		end

	action_on_abort is
			-- optional action on abort
		do
		end

end
