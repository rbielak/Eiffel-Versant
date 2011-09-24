-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--

deferred class ABSTRACT_SORTER [T]

inherit

	SHARED_EXCEPTIONS
	
feature
	
	sort_list (a_list : RLIST[T]) is
		require
			list_there: a_list /= Void;
		deferred
		ensure
			-- is_sorted: list is sorted
		end
	
end
