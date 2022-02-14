use strict;
use warnings;
use Test::More;

use Kakezanmushikui;


my @targets = (
  {
    filename  => '../example/test1.txt',
    result    => [
      {
        'target1' => 666666,
        'target2' => 1711,
        'line' => [
          666666,
          666666,
          4666662,
          666666
        ],
        'total' => 1140665526,
      }
    ],
  },
  {
    filename  => '../example/test4.txt',
    result    => [
      {
        'target1' => 27,
        'target2' => 35,
        'line' => [
          135,
          81,
        ],
        'total' => 945,
      }
    ]
  }
);

for my $t (@targets) {
  my $obj = Kakezanmushikui->new->process($t->{filename});
  is(@{$obj->{result}}, @{$t->{'result'}});
}

done_testing;
