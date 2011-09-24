-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DEFAULT_VERSION_MISMATCH_HANDLER

inherit
	
	VERSION_MISMATCH_HANDLER
	
	EXCEPTIONS

feature
	
	handle (object : POBJECT): BOOLEAN is
		do
			io.putstring ("Version mismatch error. Object -> ");
			io.putint (object.pobject_version)
			io.putstring (" Database-> ");
			io.putint (object.cache_version)
			io.putstring (" LOID: ")
			io.putstring (object.external_object_id)
			io.putstring (" Type: ")
			io.putstring (object.generator)
			io.new_line;
			Result := False
		end

end -- DEFAULT_VERSION_MISMATCH_HANDLER
