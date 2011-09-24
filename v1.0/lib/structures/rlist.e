-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class RLIST [G]

inherit

	EDITABLE [G]

feature

	count: INTEGER is
			-- Number of items of the list.
		deferred
		ensure
			count_positive: Result >= 0
		end

	i_th (i: INTEGER): G is
			-- I-`th' item of the list (beginning at 0).
		require
			i_strickly_positive: i >= 1
			i_less_than_count: i <= count
		deferred
		ensure
			has_result: Result /= void
		end

	has (item: G): BOOLEAN is
			-- Is `item' in the list.
		require
			has_item: item /= void
		local
			lcount: INTEGER
			i: INTEGER
		do
			lcount := count
			from
				i := 1
			until
				(i > lcount) or (i_th (i) = item)
			loop
				i := i+1
			end
			Result := i <= lcount
		end

feature

	to_array: ARRAY [G] is
		local
			i: INTEGER
			list_count: INTEGER
		do
			list_count := count
			!!Result.make (1, list_count)
			from
				i := 1
			until
				i > list_count
			loop
				Result.put (i_th (i), i)
				i := i+1
			end
		ensure
			same_count: count = Result.count
		end

	tags: RLIST [STRING] is
			-- List of object's tags.
			-- Used to improve the user interface.
			-- If you implement this feature, you must :
			--	1. be sure that tag are unique (ie can be used as a key).
			--	2. implement `item_from_tag'.
			-- 3. all the objects are tagables.
		do
		ensure
			same_count: (Result /= void) implies (count = Result.count)
		end
 
	item_from_tag (a_tag: STRING): G is
			-- Element whose tag is same as `a_tag'.
			-- Void if no item is found.
		require
			has_tag: a_tag /= void
		do
		ensure
--			same_tag: (Result /= void) implies (a_tag.is_equal (Result.tag))
		end

	type_from_tag (a_tag: STRING): STRING is
			-- Generator of element whose tag is same as `a_tag'.
			-- Void if no item is found.
		require
			has_tag: a_tag /= void
		local
			g: G
		do
			g := item_from_tag (a_tag)
			if g /= void then
				Result := g.generator
			end
		end

end
