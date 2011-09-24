-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SHARED_PRIMARY_CONTAINER

feature

	default_container: PRIMARY_CONTAINER is
		once
			!!Result.make
		end

end
