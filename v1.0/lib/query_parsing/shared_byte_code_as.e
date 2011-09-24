-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class SHARED_BYTE_CODE_AS

inherit

	BYTE_CODE_CONSTANT

feature 
	-- Building the interpreter

	build_byte_code (bc: BYTE_CODE_GENERATOR) is
		deferred
		end

end -- class SHARED_BYTE_CODE_AS
