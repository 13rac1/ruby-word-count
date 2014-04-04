WC in Ruby
----------

This is a programming exercise to duplicate the functionality of the GNU
coreutils wc program in Ruby. It is many times slower than the original.

Missing functionality compared to original:
* Detection and correct count multi-byte Unicode characters.
* Tab length adjustments for line length counts.
* Equivalent counts for binary files.

Todo:
* Unit tests
