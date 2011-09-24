-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--

class PUSUBS

inherit

	LINKED_LIST [SUBSCRIBER]
		rename
			make as linked_list_make
		end
	
	SHARED_POSTMAN

creation

	make, make_first

feature

	publisher: PUBLISHER

	publishing: INTEGER

	cache_to_subscribe, cache_to_unsubscribe: LINKED_LIST [SUBSCRIBER]

	make (lp: like publisher) is
		require
			has_publisher: lp /= void
		do
			debug
				io.putstring ("PUSUBS.make%N")
			end
			publisher := lp
			linked_list_make
			!!cache_to_subscribe.make
			!!cache_to_unsubscribe.make
			compare_references
		end

	make_first is
		do
			debug
				io.putstring ("PUSUBS.make_first%N")
			end
			linked_list_make
			compare_references
		end

	add_subscriber (ls: SUBSCRIBER) is
		do
			debug
				io.putstring ("PUSUBS.add_subscriber (...)%N")
			end
			if publishing > 0 then
				--io.putstring ("WARNING: subscribing during publish / ")
				--io.putstring (ls.generator)
				--io.putstring (" subscribe to ")
				--io.putstring (publisher.generator)
				--io.new_line
				cache_to_subscribe.extend (ls)
			else
				extend (ls)
			end
		end

	remove_subscriber (ls: SUBSCRIBER) is
		do
			debug
				io.putstring ("PUSUBS.remove_subscriber (...)%N")
			end
			if publishing > 0 then
				--io.putstring ("WARNING: unsubscribing during publish / ")
				--io.putstring (ls.generator)
				--io.putstring (" unsubscribe to ")
				--io.putstring (publisher.generator)
				--io.new_line
				cache_to_unsubscribe.extend (ls)
			else
				start
				search (ls)
				if not after then
					remove
				end
				if (not postman.bufferize) and (count = 0) then
					postman.remove_pusubs (Current)
				end
			end
		end

	publish (info: ANY) is
		local
			--pos: CURSOR
			old_active: LINKABLE [SUBSCRIBER]
			old_after, old_before: BOOLEAN
		do
			debug
				io.putstring ("PUSUBS.publish (...)%N")
			end
			publishing := publishing+1
			from
				if publishing > 1 then
					--pos := cursor
					old_active := active
					old_before := before
					old_after := after
				end

				start
			until
				after
			loop
				item.update_subscriber (publisher, info)
				forth
			end
			
			if publishing > 1 then
				--go_to (pos)
				before := old_before
				after := old_after
				if before then
					active := first_element
				elseif after then
					active := last_element
				else
					active := old_active
				end
				publishing := publishing-1
			else
				publishing := 0
				clean_cache
			end
		end

	clean_cache is
		do
			if cache_to_subscribe.count > 0 then
				from
					cache_to_subscribe.start
				until
					cache_to_subscribe.off
				loop
					extend (cache_to_subscribe.item)
					cache_to_subscribe.forth
				end
				cache_to_subscribe.wipe_out
			end
			if cache_to_unsubscribe.count > 0 then
				from
					cache_to_unsubscribe.start
				until
					cache_to_unsubscribe.off
				loop
					start
					search (cache_to_unsubscribe.item)
					if not after then
						remove
					end
					cache_to_unsubscribe.forth
				end
				cache_to_unsubscribe.wipe_out
				if (not postman.bufferize) and (count = 0) then
					postman.remove_pusubs (Current)
				end
			end
		end

end
