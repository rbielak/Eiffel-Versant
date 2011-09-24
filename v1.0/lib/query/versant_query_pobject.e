-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class VERSANT_QUERY_POBJECT

inherit

	POBJECT
		redefine
			dispose
		end

creation

	make

feature

	make (obj_id: INTEGER) is
		do
			pobject_id := obj_id
		end

	dispose is
		do
			-- Do Nothing !!
		end

end
