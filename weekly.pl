#!/Users/brian/bin/perls/perl5.26.0
use v5.10.1;
use utf8;
use strict;
use warnings;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use DateTime;

=head1 NAME

weekly.pl - make the weekly virtue sheets

=head1 SYNOPSIS

	% weekly.pl N_WEEKS

=cut

my $weeks = $ARGV[0] // 1;
my $font_name = 'Helvetica-Bold';
my $font;
my $x = 50;
my $y0 = $x;
my $width = 60;
my $boxes = 7;
my $separation = int( $width / 2 );

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Setup the page
foreach my $weeks_in_future ( -1 .. $weeks ) {
	state $start_date = DateTime->now;
	my $next_date = get_next_sunday( $start_date, $weeks_in_future );
	my $title_text = get_week_string( $next_date );
	say $title_text;
	my( $pdf, $page ) = make_the_page();
	$font = $pdf->corefont( $font_name );

	make_the_boxes( $page );
	make_the_virtues( $page );
	make_the_title( $page, $title_text );
	save_page( $pdf, $title_text );
	}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Make the pages
sub make_the_page () {
	require PDF::API2;
	my $pdf  = PDF::API2->new;
	my $page = $pdf->page();

	$page->mediabox('Letter');

	( $pdf, $page );
	}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Make the boxes
sub make_the_boxes ( $page ) {
	my $x = 50;
	my $boxes = 7;

	my $content = $page->gfx();
	$content->strokecolor('#000');
	$content->fillcolor('#000');

	$content->linewidth(2);
	$content->strokecolor('black');

	my $y0 = 50;

	my $width = 60;
	my $separation = int( $width / 2 );

	for( my $n = 0; $n < $boxes; $n++ ) {
		my $y = $y0 + $n * ( $width + $separation );
		$content->rectxy($x, $y, $x + $width, $y + $width);
		$content->stroke;
		}
	}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Make the areas
sub make_the_virtues ( $page ) {
	my $virtues = $page->text;
	$virtues->strokecolor('#ccc');
	$virtues->fillcolor('#ccc');
	$virtues->font( $font, 30 );

	my @virtues = (
		'Art',
		'Running',
		'Home Improvement',
		'Cooking',
		'Restaurant',
		'Footprint',
		'Local Attraction',
		);

	my $x = $x + $width * 5 / 4;

	for( my $n = 0; $n < @virtues; $n++ ) {
		my $y = $y0 + $n * ( $width + $separation ) + int( $width / 5 );
		$virtues->translate( $x, $y );
		$virtues->text( $virtues[$n] );
		}
	}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Make the title
sub make_the_title ( $page, $title_text = get_week_string() ) {
	my $font_size = 50;
	my $title = $page->text;
	$title->strokecolor('#000');
	$title->fillcolor('#000');

	my $x_text = $x;
	my $y_text = $x + $boxes * $width + ($boxes + 1) * $separation;

	$title->translate( $x_text, $y_text );
	$title->font( $font, $font_size );

	$title->text( $title_text );

	return $title_text;
	}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# All done
sub save_page ( $pdf, $title_text ) {
	$pdf->saveas("/Users/brian/Desktop/$title_text.pdf");
	}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
sub get_next_sunday ( $dt = DateTime->now, $weeks = 1 ) {
	my $days_until_sunday = do {
		if( $dt->day_of_week == 7 ) { 0 }
		else {
			($weeks * 7 - $dt->day_of_week ) || $weeks * 7;
			}
		};

	$dt->clone->add( days => $days_until_sunday );
	}

sub get_week_string ( $dt = get_next_sunday() ) {
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
