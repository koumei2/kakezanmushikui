package Kakezanmushikui;


use Clone 'clone';
use Time::HiRes qw( gettimeofday tv_interval );



sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {};
    bless($self, $class);
    return $self;
}


sub process {
    my ($self, $filename) = @_;
    my $starttime = [gettimeofday];
    $self->_read_question($filename);
    my $keta2 = $self->_get_target2_keta();
    my @stack = $self->_make_init_stack();
    for my $i (1..$keta2) {
        my @s = $self->_update_stack($i - 1, @stack);
        @stack = @s;
    }

    $self->_make_result(@stack);

    $self->{elapsedtime} = tv_interval($starttime);

    return $self;
}


sub print_result {
    my $self = shift;
    my $base_length = $self->{target1_keta} + 5;
    my $base_format = sprintf("%%%dd\n", $base_length);
    for my $i (@{$self->{result}}) {
        printf $base_format, $i->{target1};
        printf "%s\n", $self->{operation};
        printf $base_format, $i->{target2};
        print '-' x $base_length . "\n";
        my $n = 0;
        for my $line (@{$i->{line}}) {
            my $f = sprintf("%%%dd\n", $base_length + $n --);
            printf $f, $line;
        }
        print '-' x $base_length . "\n";
        printf $base_format, $i->{total};
    }
    print '=' x $base_length . "\n";
    printf "Filename: %s, Elapsed time: %f sec\n", $self->{filename}, $self->{elapsedtime};
    print '=' x $base_length . "\n";
}


sub _update_stack {
    my $self = shift;
    my $num = shift;
    my @stack = ();

    my $t2 = substr($self->{orig_target2}, -$num - 1, 1);
    my @current_target2 = $t2 eq '?' ? 1..9 : $t2;
    for my $s (@_) {
        for my $b (@current_target2) {
            my $line = $s->{target1} * $b;
            if ($line =~ /${$self->{lines}}[$num]/) {
                my $data = clone($s);
                $data->{target2}->[$num] = $b;
                $data->{line}->[$num] = $line;
                push @stack, $data;
            }
        }
    }
    return @stack;
}

sub _make_result {
    my $self = shift;
    my @result = ();
    for my $s (@_) {
        my $total = 0;
        my $weight = 1;
        for my $i (@{$s->{line}}) {
            $total += $i * $weight;
            $weight *= 10;
        }
        if ($total =~ /$self->{result}/) {
            $s->{total} = $total;
            $s->{target2} = join('', reverse(@{$s->{target2}}));
            push @result, $s;
        }
    }
    $self->{result} = \@result;
}


sub _read_question {
    my ($self, $filename) = @_;
    $self->{filename} = $filename;
    open(IN, $filename) || die "Cannot open " . $filename . "\n";
    chomp(my $line = <IN>);
    my ($target1, $operation, $target2) = split(' ', $line);
    # TODO: $operation check
    $self->{operation} = $operation;
    $self->{orig_target1} = $target1;
    $self->{orig_target2} = $target2;
    @{$self->{lines}} = ();
    while (<IN>) {
        chomp;
        push @{$self->{lines}}, $self->_make_re($_);
    }
    close(IN);

    $self->{result} = pop @{$self->{lines}};
}


sub _make_re {
    my ($self, $str) = @_;
    $str =~ s/\?/\\d/g;
    return '^' . $str  .'$';
}


sub _make_init_stack {
    $self = shift;
    die "Invalid target1 format." if $self->{orig_target1} !~ /^([\d\?]+)$/;

    $self->{target1_keta} = length($1);
    my @stack = $self->_make_stack_recursive(1, split('', $1));

    return @stack;
}


sub _make_stack_recursive {
    my ($self, $start, @target) = @_;
    my @stack = ();
    my $keta = $#target;
    if ($keta == -1) {
        return ({ target1 => 0 });
    }

    my $a = shift @target;
    my @pstack = $self->_make_stack_recursive(0, @target);
    my @current_target = $a eq '?' ? $start..9 : $a;


        for my $n (@current_target) {
            my $basenum = $n * (10 ** $keta);
            for my $s (@pstack) {
                push @stack, {
                    target1 => $basenum + $s->{target1},
                }
            }
        }


    return @stack;
}


sub _get_target2_keta {
    $self = shift;
    die "Invalid target2 format." if $self->{orig_target2} !~ /^([\d\?]+)$/;
    return length($1);
}

1;
