#!/Users/brian/bin/perls/perl5.26.0
use v5.10.1;
use utf8;
use strict;
use warnings;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use DateTime;

foreach (0 .. 24) {
	state $last_date = DateTime->now;
	say get_week_string( $last_date = get_next_sunday($last_date) );
	}

sub get_next_sunday ( $dt ) {
	my $days_until_sunday = (7 - $dt->day_of_week) || 7;

	$dt->clone->add( days => $days_until_sunday );
	}

sub get_week_string ( $dt ) {
	my $start = $dt->clone;
	my $end = $start->clone->add( days => 6 );

	my $string = do {
		# If the week is in the same month, use the full name
		if( $start->month == $end->month ) {
			my $string = $start->strftime( '%B %e, %Y' );
			my $end_date = $end->day;
			$string =~ s/,/-$end_date,/r;
			}
		# The week must be across months
		# If the week is in the same year, use the short month names
		elsif( $start->year == $end->year ) {
			join ' - ',
				$start->strftime( '%b %e' ),
				$end->strftime( '%b %e, %Y' )
			}
		# The week must be across years
		# use the short names for months and the years in each
		else {
			join ' - ',
				$start->strftime( '%b %e, %Y' ),
				$end->strftime( '%b %e, %Y' )
			}
		};

	$string =~ s/\s+/ /gr;
	}
