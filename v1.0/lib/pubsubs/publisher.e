-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class PUBLISHER

inherit

	SHARED_POSTMAN

feature

	publish (info: ANY) is
		do
			postman.publish (Current, info)
		end

feature {SUBSCRIBER}

	add_subscriber (ls: SUBSCRIBER) is
		do
			postman.subscribe (ls, Current)
		end

	remove_subscriber (ls: SUBSCRIBER) is
		do
			postman.unsubscribe (ls, Current)
		end

end
