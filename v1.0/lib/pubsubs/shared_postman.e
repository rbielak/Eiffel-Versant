-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SHARED_POSTMAN

feature {PUBLISHER, SUBSCRIBER}

	postman: POSTMAN is
		once
			!!Result.make
		ensure
			has_postman: Result /= void
		end

end
