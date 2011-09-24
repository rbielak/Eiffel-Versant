-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class STAMP 

inherit

	STAMPED

creation

	make

feature

	make (stamp_bit_pattern : INTEGER) is
		require
			valid_stamp: stamp_bit_pattern >= 0
		do
			reset_rights_stamp (stamp_bit_pattern)			
		ensure
			valid_rights: rights_stamp > 0
		end

	root_id : INTEGER

	database : DATABASE


end  -- class STAMP
