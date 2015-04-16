my class MapIter                { ... }
my class Pair                   { ... }
my class Range                  { ... }
my class X::Bind                { ... }
my class X::Bind::Slice         { ... }
my class X::Bind::ZenSlice      { ... }
my class X::Item                { ... }
my class X::Match::Bool         { ... }
my class X::Pairup::OddNumber   { ... }
my class X::Subscript::Negative { ... }

my role  Numeric { ... }

my class Any { # declared in BOOTSTRAP
    # my class Any is Mu {

    multi method ACCEPTS(Any:D: Mu \a) { self === a }

    method invoke(|c) {
        DEPRECATED('CALL-ME',|<2015.03 2016.03>);
        self.CALL-ME(|c);
    }

    method exists_key(|c) {
        DEPRECATED('EXISTS-KEY',|<2015.03 2016.03>);
        self.EXISTS-KEY(|c);
    }

    proto method EXISTS-KEY(|){ * }
    multi method EXISTS-KEY(Any:U: $) { False }
    multi method EXISTS-KEY(Any:D: $) { False }

    method delete_key(|c) {
        DEPRECATED('DELETE-KEY',|<2015.03 2016.03>);
        self.DELETE-KEY(|c);
    }

    proto method DELETE-KEY(|) { * }
    multi method DELETE-KEY(Any:U: $) { Nil }
    multi method DELETE-KEY(Any:D: $) {
        fail "Can not remove values from a {self.^name}";
    }

    method delete_pos(|c) {
        DEPRECATED('DELETE-POS',|<2015.03 2016.03>);
        self.DELETE-POS(|c);
    }

    proto method DELETE-POS(|) { * }
    multi method DELETE-POS(Any:U: $pos) { Nil }
    multi method DELETE-POS(Any:D: $pos) {
        fail "Can not remove elements from a {self.^name}";
    }

    proto method list(|) { * }
    multi method list(Any:U:) { nqp::p6list(nqp::list(),     List, Mu) }
    multi method list(Any:D:) { nqp::p6list(nqp::list(self), List, Mu) }

    proto method flat(|) { * }
    multi method flat(Any:U:) { nqp::p6list(nqp::list(),     List, Bool::True) }
    multi method flat(Any:D:) { nqp::p6list(nqp::list(self), List, Bool::True) }

    proto method eager(|) { * }
    multi method eager(Any:U:) {
        nqp::p6list(nqp::list(),     List, Mu).eager;
    }
    multi method eager(Any:D:) {
        nqp::p6list(nqp::list(self), List, Mu).eager;
    }

    proto method hash(|) { * }
    multi method hash(Any:U:) { my % = () }
    multi method hash(Any:D:) { my % = self }
    method Hash() { self.hash }

    # derived from .list
    method Parcel() { self.list.Parcel }
    method List() { self.list }

    proto method elems(|) { * }
    multi method elems(Any:U:) { 0 }
    multi method elems(Any:D:) { self.list.elems }

    proto method end(|) { * }
    multi method end(Any:U:) { -1 }
    multi method end(Any:D:) { self.list.end }

    proto method keys(|) { * }
    multi method keys(Any:U:) { ().list }
    multi method keys(Any:D:) { self.list.keys }

    proto method kv(|) { * }
    multi method kv(Any:U:) { ().list }
    multi method kv(Any:D:) { self.list.kv }

    proto method values(|) { * }
    multi method values(Any:U:) { ().list }
    multi method values(Any:D:) { self.list }

    proto method pairs(|) { * }
    multi method pairs(Any:U:) { ().list }
    multi method pairs(Any:D:) { self.list.pairs }

    proto method antipairs(|) { * }
    multi method antipairs(Any:U:) { ().list }
    multi method antipairs(Any:D:) { self.list.antipairs }

    proto method invert(|) { * }

    proto method pairup(|) { * }
    multi method pairup(Any:U:) { ().list }
    multi method pairup(Any:D:) {

        my $list := self.list;
        my int $i;
        my int $elems = self.elems;

        gather while $i < $elems {
            my Mu $it := $list.AT-POS($i++);
            if nqp::istype($it,Enum) {
                take $it.key => $it.value;
            }
            elsif nqp::istype($it,EnumMap) and !nqp::iscont($it) {
                take $it.pairs;
            }
            elsif $i < $elems {
                take $it => $list.AT-POS($i++);
            }
            else {
                X::Pairup::OddNumber.new.throw;
            }
        }
    }

    method squish(|c) { self.list.squish(|c) }
    method rotor(|c) { self.list.rotor(|c) }
    method reverse() { self.list.reverse }
    method sort($by = &infix:<cmp>) { self.list.sort($by) }
    method reduce(&with) { self.list.reduce(&with) }
    method combinations(|c) { self.list.combinations(|c) }
    method permutations(|c) { self.list.permutations(|c) }

    method unique(|c) { self.list.unique(|c) }
    method uniq(|c) {
        DEPRECATED('unique', |<2014.11 2015.11>);
        self.unique(|c);
    }

    proto method pick(|) { * }
    multi method pick()   { self.list.pick     }
    multi method pick($n) { self.list.pick($n) }

    proto method roll(|) { * }
    multi method roll()   { self.list.roll     }
    multi method roll($n) { self.list.roll($n) }

    proto method classify(|) { * }
    multi method classify($test)   {
        Hash.^parameterize(Any,Any).new.classify-list( $test, self.list );
    }
    multi method classify($test, :$into!)   {
        ( $into // $into.new ).classify-list( $test, self.list );
    }

    proto method categorize(|) { * }
    multi method categorize($test) {
        Hash.^parameterize(Any,Any).new.categorize-list( $test, self.list );
    }
    multi method categorize($test, :$into!) {
        ( $into // $into.new ).categorize-list( $test, self.list );
    }

    # derived from MapIter/list
    method lol()  {
        MapIter.new(self.list, { .item }, Mu).list
    }
    proto method map (|) { * }
    multi method map(Whatever) is rw { self }
    multi method map($block, :$label) is rw {
        MapIter.new(self, $block, Bool::True, :$label).list
    }
    proto method for (|) { * }
    multi method for(Whatever) is rw { self }
    multi method for($block, :$label) is rw {
        MapIter.new(self, $block, Bool::True, :$label).list
    }
    method flatmap($block) is rw { flatmap($block, self) }
    method duckmap($block) is rw { duckmap($block, self) }
    method deepmap($block) is rw { deepmap($block, self) }

    proto method tree(|) { * }
    multi method tree(Any:U:) { self }
    multi method tree(Any:D:) {
        nqp::istype(self,Positional)
            ?? LoL.new(|MapIter.new(self.list, { .tree }, Mu).list).item
            !! self
    }
    multi method tree(Any:D: Whatever ) { self.tree }
    multi method tree(Any:D: Int(Cool) $count) {
        nqp::istype(self,Positional) && $count > 0
            ?? LoL.new(|MapIter.new(self.list, { .tree($count - 1) }, Mu).list).item
            !! self
    }
    multi method tree(Any:D: *@ [&first, *@rest]) {
        nqp::istype(self,Positional)
            ?? @rest ?? first MapIter.new(self.list, { .tree(|@rest) }, Mu).list
                     !! first self.list
            !! self
    }

    method Array() { Array.new(self.flat) }

    # auto-vivifying
    proto method push(|) { * }
    multi method push(Any:U \SELF: *@values) {
        SELF = nqp::istype(SELF,Positional) ?? SELF.new !! Array.new;
        SELF.push(@values);
    }

    proto method unshift(|) { * }
    multi method unshift(Any:U \SELF: *@values) {
        SELF = Array.new;
        SELF.unshift(@values);
    }

    proto method grep(|) { * }
    multi method grep(Bool:D $t) is rw {
        fail X::Match::Bool.new( type => '.grep' );
    }
    multi method grep(Regex:D $test) is rw {
        self.map({ next unless .match($test); $_ });
    }
    multi method grep(Callable:D $test) is rw {
        self.map({ next unless $test($_); $_ });
    }
    multi method grep(Mu $test) is rw {
        self.map({ next unless $_ ~~ $test; $_ });
    }

    proto method grep-index(|) { * }
    multi method grep-index(Bool:D $t) is rw {
        fail X::Match::Bool.new( type => '.grep-index' );
    }
    multi method grep-index(Regex:D $test) {
        my int $index = -1;
        self.map: {
            $index = $index+1;
            next unless .match($test);
            nqp::box_i($index,Int);
        };
    }
    multi method grep-index(Callable:D $test) {
        my int $index = -1;
        self.map: {
            $index = $index + 1;
            next unless $test($_);
            nqp::box_i($index,Int);
        };
    }
    multi method grep-index(Mu $test) {
        my int $index = -1;
        self.map: {
            $index = $index + 1;
            next unless $_ ~~ $test;
            nqp::box_i($index,Int);
        };
    }

    proto method first(|) { * }
    multi method first(Bool:D $t) is rw {
        fail X::Match::Bool.new( type => '.first' );
    }
    multi method first(Regex:D $test) is rw {
        self.map({ return-rw $_ if .match($test) });
        Nil;
    }
    multi method first(Callable:D $test) is rw {
        self.map({ return-rw $_ if $test($_) });
        Nil;
    }
    multi method first(Mu $test) is rw {
        self.map({ return-rw $_ if $_ ~~ $test });
        Nil;
    }

    proto method first-index(|) { * }
    multi method first-index(Bool:D $t) is rw {
        fail X::Match::Bool.new( type => '.first-index' );
    }
    multi method first-index(Regex:D $test) {
        my int $index = -1;
        self.map: {
            $index = $index + 1;
            return nqp::box_i($index,Int) if .match($test);
        };
        Nil;
    }
    multi method first-index(Callable:D $test) {
        my int $index = -1;
        self.map: {
            $index = $index + 1;
            return nqp::box_i($index,Int) if $test($_);
        };
        Nil;
    }
    multi method first-index(Mu $test) {
        my int $index = -1;
        self.map: {
            $index = $index + 1;
            return nqp::box_i($index,Int) if $_ ~~ $test;
        };
        Nil;
    }

    proto method last-index(|) { * }
    multi method last-index(Bool:D $t) is rw {
        fail X::Match::Bool.new( type => '.last-index' );
    }
    multi method last-index(Regex:D $test) {
        my $elems = self.elems;
        return Inf if $elems == Inf;

        my int $index = $elems;
        while $index {
            $index = $index - 1;
            return nqp::box_i($index,Int) if self.AT-POS($index).match($test);
        }
        Nil;
    }
    multi method last-index(Callable:D $test) {
        my $elems = self.elems;
        return Inf if $elems == Inf;

        my int $index = $elems;
        while $index {
            $index = $index - 1;
            return nqp::box_i($index,Int) if $test(self.AT-POS($index));
        }
        Nil;
    }
    multi method last-index(Mu $test) {
        my $elems = self.elems;
        return Inf if $elems == Inf;

        my int $index = $elems;
        while $index {
            $index = $index - 1;
            return nqp::box_i($index,Int) if self.AT-POS($index) ~~ $test;
        }
        Nil;
    }

    method join($separator = '') {
        my $list = (self,).flat.eager;
        my Mu $rsa := nqp::list_s();
        $list.gimme(4);        # force reification of at least 4 elements
        unless $list.infinite {  # presize array
            nqp::setelems($rsa, nqp::unbox_i($list.elems));
            nqp::setelems($rsa, 0);
        }
        my $tmp;
        while $list.gimme(0) {
            $tmp := $list.shift;
            nqp::push_s($rsa,
              nqp::unbox_s(nqp::istype($tmp, Str) && nqp::isconcrete($tmp) ?? $tmp !! $tmp.Str));
        }
        nqp::push_s($rsa, '...') if $list.infinite;
        nqp::p6box_s(nqp::join(nqp::unbox_s($separator.Str), $rsa))
    }

    proto method min (|) { * }
    multi method min(Any:D:) {
        my $min;
        for self {
            $min = $_ if .defined and !$min.defined || $_ cmp $min < 0;
        }
        $min // Inf;
    }
    multi method min(Any:D: $by) {
        my $cmp = $by.arity == 2 ?? $by !! { $by($^a) cmp $by($^b) }
        my $min;
        for self {
            $min = $_ if .defined and !$min.defined || $cmp($_, $min) < 0;
        }
        $min // Inf;
    }

    proto method max (|) { * }
    multi method max(Any:D:) {
        my $max;
        for self {
            $max = $_ if .defined and !$max.defined || $_ cmp $max > 0;
        }
        $max // -Inf;
    }
    multi method max(Any:D: $by) {
        my $cmp = $by.arity == 2 ?? $by !! { $by($^a) cmp $by($^b) }
        my $max;
        for self {
            $max = $_ if .defined and !$max.defined || $cmp($_, $max) > 0;
        }
        $max // -Inf;
    }

    proto method minmax (|) { * }
    multi method minmax(Any:D: $by = &infix:<cmp>) {
        my $cmp = $by.arity == 2 ?? $by !! { $by($^a) cmp $by($^b) };

        my $min;
        my $max;
        my $excludes-min = Bool::False;
        my $excludes-max = Bool::False;

        for @.list {
            .defined or next;

            if .isa(Range) {
                if !$min.defined || $cmp($_.min, $min) < 0 {
                    $min = .min;
                    $excludes-min = $_.excludes-min;
                }
                if !$max.defined || $cmp($_.max, $max) > 0 {
                    $max = .max;
                    $excludes-max = $_.excludes-max;
                }
            } elsif Positional.ACCEPTS($_) {
                my $mm = .minmax($by);
                if !$min.defined || $cmp($mm.min, $min) < 0 {
                    $min = $mm.min;
                    $excludes-min = $mm.excludes-min;
                }
                if !$max.defined || $cmp($mm.max, $max) > 0 {
                    $max = $mm.max;
                    $excludes-max = $mm.excludes-max;
                }
            } else {
                if !$min.defined || $cmp($_, $min) < 0 {
                    $min = $_;
                    $excludes-min = Bool::False;
                }
                if !$max.defined || $cmp($_, $max) > 0 {
                    $max = $_;
                    $excludes-max = Bool::False;
                }
            }
        }
        Range.new($min // Inf,
                  $max // -Inf,
                  :excludes-min($excludes-min),
                  :excludes-max($excludes-max));
    }

    method exists_pos(|c) {
        DEPRECATED('EXISTS-POS',|<2015.03 2016.03>);
        self.EXISTS-POS(|c);
    }

    proto method EXISTS-POS(|) { * }
    multi method EXISTS-POS(Any:U: Any:D $) { False }
    multi method EXISTS-POS(Any:U: Any:U $pos) is rw {
        die "Cannot use '{$pos.^name}' as an index";
    }

    multi method EXISTS-POS(Any:D: int \pos) {
        nqp::p6bool(nqp::iseq_i(pos,0));
    }
    multi method EXISTS-POS(Any:D: Int:D \pos) {
        pos == 0;
    }
    multi method EXISTS-POS(Any:D: Num:D \pos) {
        X::Item.new(aggregate => self, index => pos).throw
          if nqp::isnanorinf(pos);
        self.AT-POS(nqp::unbox_i(pos.Int));
        pos == 0;
    }
    multi method EXISTS-POS(Any:D: Any:D \pos) {
        pos.Int == 0;
    }
    multi method EXISTS-POS(Any:D: Any:U \pos) {
        die "Cannot use '{pos.^name}' as an index";
    }

    method at_pos(|c) is rw {
        DEPRECATED('AT-POS',|<2015.03 2016.03>);
        self.AT-POS(|c);
    }

    proto method AT-POS(|) {*}
    multi method AT-POS(Any:U \SELF: int \pos) is rw {
        nqp::bindattr(my $v, Scalar, '$!whence',
            -> { SELF.defined || (SELF = Array.new);
                 SELF.BIND-POS(pos, $v) });
        $v
    }
    multi method AT-POS(Any:U \SELF: Int:D \pos) is rw {
        nqp::bindattr(my $v, Scalar, '$!whence',
            -> { SELF.defined || (SELF = Array.new);
                 SELF.BIND-POS(nqp::unbox_i(pos), $v) });
        $v
    }
    multi method AT-POS(Any:U: Num:D \pos) is rw {
        fail X::Item.new(aggregate => self, index => pos)
          if nqp::isnanorinf(pos);
        self.AT-POS(nqp::unbox_i(pos.Int));
    }
    multi method AT-POS(Any:U: Any:D \pos) is rw {
        self.AT-POS(nqp::unbox_i(pos.Int));
    }

    multi method AT-POS(Any:D: int \pos) is rw {
        fail X::OutOfRange.new(:what<Index>, :got(pos), :range<0..0>)
          unless nqp::not_i(pos);
        self;
    }
    multi method AT-POS(Any:D: Int:D \pos) is rw {
        fail X::OutOfRange.new(:what<Index>, :got(pos), :range<0..0>)
          if pos != 0;
        self;
    }
    multi method AT-POS(Any:D: Num:D \pos) is rw {
        fail X::Item.new(aggregate => self, index => pos)
          if nqp::isnanorinf(pos);
        self.AT-POS(nqp::unbox_i(pos.Int));
    }
    multi method AT-POS(Any:D: Any:D \pos) is rw {
        self.AT-POS(nqp::unbox_i(pos.Int));
    }

    multi method AT-POS(Any:   Any:U \pos) is rw {
        die "Cannot use '{pos.^name}' as an index";
    }

    method bind_pos(|c) is rw {
        DEPRECATED('BIND-POS',|<2015.03 2016.03>);
        self.BIND-POS(|c);
    }

    method assign_pos(|c) {
        DEPRECATED('ASSIGN-POS',|<2015.03 2016.03>);
        self.ASSIGN-POS(|c);
    }

    proto method ASSIGN-POS(|) { * }
    multi method ASSIGN-POS(Any:U \SELF: \pos, Mu \assignee) {
       SELF.AT-POS(pos) = assignee;                     # defer < 0 check
    }

    multi method ASSIGN-POS(Any:D: int \pos, Mu \assignee) {
        self.AT-POS(pos) = assignee;                    # defer < 0 check
    }
    multi method ASSIGN-POS(Any:D: Int:D \pos, Mu \assignee) {
        self.AT-POS(pos) = assignee;                    # defer < 0 check
    }
    multi method ASSIGN-POS(Any:D: Num:D \pos, Mu \assignee) {
        fail X::Item.new(aggregate => self, index => pos)
          if nqp::isnanorinf(pos);
        self.AT-POS(nqp::unbox_i(pos.Int)) = assignee;  # defer < 0 check
    }
    multi method ASSIGN-POS(Any:D: Any:D \pos, Mu \assignee) {
        self.AT-POS(nqp::unbox_i(pos.Int)) = assignee;  # defer < 0 check
    }
    multi method ASSIGN-POS(Any:D: Any:U \pos, Mu \assignee) {
        die "Cannot use '{pos.^name}' as an index";
    }

    method all() { all(self.list) }
    method any() { any(self.list) }
    method one() { one(self.list) }
    method none() { none(self.list) }

    method at_key(|c) is rw {
        DEPRECATED('AT-KEY',|<2015.03 2016.03>);
        self.AT-KEY(|c);
    }

    # internals
    proto method AT-KEY(|) { * }
    multi method AT-KEY(Any:D: $key) is rw {
        fail "postcircumfix:<\{ \}> not defined for type {self.WHAT.perl}";
    }
    multi method AT-KEY(Any:U \SELF: $key) is rw {
        nqp::bindattr(my $v, Scalar, '$!whence',
            -> { SELF.defined || (SELF = Hash.new);
                 SELF.BIND-KEY($key, $v) });
        $v
    }

    method bind_key(|c) is rw {
        DEPRECATED('BIND-KEY',|<2015.03 2016.03>);
        self.BIND-KEY(|c);
    }

    proto method BIND-KEY(|) { * }
    multi method BIND-KEY(Any:D: \k, \v) is rw {
        fail X::Bind.new(target => self.^name);
    }
    multi method BIND-KEY(Any:U \SELF: $key, $BIND ) is rw {
        SELF = Hash.new;
        SELF.BIND-KEY($key, $BIND);
        $BIND
    }

    method assign_key(|c) {
        DEPRECATED('ASSIGN-KEY',|<2015.03 2016.03>);
        self.ASSIGN-KEY(|c);
    }

    proto method ASSIGN-KEY(|) { * }
    multi method ASSIGN-KEY(\SELF: \key, Mu \assignee) {
        SELF.AT-KEY(key) = assignee;
    }

    method FLATTENABLE_LIST() {
        my $list := self.list;
        nqp::findmethod($list, 'FLATTENABLE_LIST')($list);
    }
    method FLATTENABLE_HASH() { nqp::hash() }

    method Set()     {     Set.new-from-pairs(self.list) }
    method SetHash() { SetHash.new-from-pairs(self.list) }
    method Bag()     {     Bag.new-from-pairs(self.list) }
    method BagHash() { BagHash.new-from-pairs(self.list) }
    method Mix()     {     Mix.new-from-pairs(self.list) }
    method MixHash() { MixHash.new-from-pairs(self.list) }

    method Supply() { self.list.Supply }

    method print-nl() { self.print("\n") }
}
Metamodel::ClassHOW.exclude_parent(Any);

# builtin ops
proto sub infix:<===>(Mu $?, Mu $?) is pure { * }
multi sub infix:<===>($?)    { Bool::True }
multi sub infix:<===>($a, $b) {
    nqp::p6bool(nqp::iseq_s(nqp::unbox_s($a.WHICH), nqp::unbox_s($b.WHICH)))
}

proto sub infix:<before>(Mu $, Mu $?)  is pure { * }
multi sub infix:<before>($?)      { Bool::True }
multi sub infix:<before>(\a, \b)   { (a cmp b) < 0 }

proto sub infix:<after>(Mu $, Mu $?) is pure { * }
multi sub infix:<after>($x?)       { Bool::True }
multi sub infix:<after>(\a, \b)    { (a cmp b) > 0 }

# XXX: should really be '$a is rw' (no \) in the next four operators
proto prefix:<++>(|)             { * }
multi prefix:<++>(Mu:D \a is rw) { a = a.succ }
multi prefix:<++>(Mu:U \a is rw) { a = 1 }
proto prefix:<-->(|)             { * }
multi prefix:<-->(Mu:D \a is rw) { a = a.pred }
multi prefix:<-->(Mu:U \a is rw) { a = -1 }

proto postfix:<++>(|)             { * }
multi postfix:<++>(Mu:D \a is rw) { my $b = a; a = a.succ; $b }
multi postfix:<++>(Mu:U \a is rw) { a = 1; 0 }
proto postfix:<-->(|)             { * }
multi postfix:<-->(Mu:D \a is rw) { my $b = a; a = a.pred; $b }
multi postfix:<-->(Mu:U \a is rw) { a = -1; 0 }

# builtins
proto sub infix:<min>(|) is pure { * }
multi sub infix:<min>(Mu:D \a, Mu:U) { a }
multi sub infix:<min>(Mu:U, Mu:D \b) { b }
multi sub infix:<min>(Mu:D \a, Mu:D \b) { (a cmp b) < 0 ?? a !! b }
multi sub infix:<min>(*@args) { @args.min }
# XXX the multi version suffers from a multi dispatch bug
# where the mandatory named is ignored in the presence of a slurpy
#proto sub min(|)     { * }
#multi sub min(*@args) { @args.min() }
#multi sub min(*@args, :&by!) { @args.min(&by) }
sub min(*@args, :&by = &infix:<cmp>) { @args.min(&by) }

proto sub infix:<max>(|) is pure { * }
multi sub infix:<max>(Mu:D \a, Mu:U) { a }
multi sub infix:<max>(Mu:U, Mu:D \b) { b }
multi sub infix:<max>(Mu:D \a, Mu:D \b) { (a cmp b) > 0 ?? a !! b }
multi sub infix:<max>(*@args) { @args.max }
#proto sub max(|) { * }
#multi sub max(*@args) { @args.max() }
#multi sub max(*@args, :&by!) { @args.max(&by) }
sub max(*@args, :&by = &infix:<cmp>) { @args.max(&by) }

proto sub infix:<minmax>(|) is pure { * }
multi sub infix:<minmax>(**@args) { @args.minmax }
#proto sub minmax(|) { * }
#multi sub minmax(*@args) { @args.minmax() }
#multi sub minmax(*@args, :&by!) { @args.minmax(&by) }
sub minmax(**@args, :&by = &infix:<cmp>) { @args.minmax(&by) }

proto sub map(|) {*}
# fails integration/99problems-21-to-30, test 12/13
#multi sub map(&code, @values) { @values.map(&code) }
multi sub map(&code, *@values) { @values.map(&code) }
multi sub map(Whatever, \a)    { a }
multi sub map(&code, Whatever) { (1..Inf).map(&code) }

proto sub grep(|) {*}
multi sub grep(Mu $test, @values) { @values.grep($test) }
multi sub grep(Mu $test, *@values) { @values.grep($test) }
multi sub grep(Bool:D $t, *@v) { fail X::Match::Bool.new( type => 'grep' ) }

proto sub grep-index(|) {*}
multi sub grep-index(Mu $test, @values) { @values.grep-index($test) }
multi sub grep-index(Mu $test, *@values) { @values.grep-index($test) }
multi sub grep-index(Bool:D $t, *@v) {
    fail X::Match::Bool.new(type => 'grep-index');
}

proto sub first(|) {*}
multi sub first(Mu $test, @values) { @values.first($test) }
multi sub first(Mu $test, *@values) { @values.first($test) }
multi sub first(Bool:D $t, *@v) { fail X::Match::Bool.new( type => 'first' ) }

proto sub first-index(|) {*}
multi sub first-index(Mu $test, @values) { @values.first-index($test) }
multi sub first-index(Mu $test, *@values) { @values.first-index($test) }
multi sub first-index(Bool:D $t,*@v) {
    fail X::Match::Bool.new(type => 'first-index');
}

proto sub last-index(|) {*}
multi sub last-index(Mu $test, @values) { @values.last-index($test) }
multi sub last-index(Mu $test, *@values) { @values.last-index($test) }
multi sub last-index(Bool:D $t, *@v) {
    fail X::Match::Bool.new(type => 'last-index');
}

proto sub join(|) { * }
multi sub join($sep = '', *@values) { @values.join($sep) }

proto sub pick(|) { * }
multi sub pick($n, @values) { @values.pick($n) }
multi sub pick($n, *@values) { @values.pick($n) }

proto sub roll(|) { * }
multi sub roll($n, @values) { @values.roll($n) }
multi sub roll($n, *@values) { @values.roll($n) }

proto sub keys(|) { * }
multi sub keys($x) { $x.keys }

proto sub values(|) { * }
multi sub values($x) { $x.values }

proto sub pairs(|) { * }
multi sub pairs($x) { $x.pairs }

proto sub kv(|) { * }
multi sub kv($x) { $x.kv }

proto sub elems(|) { * }
multi sub elems($a) { $a.elems }

proto sub end(|) { * }
multi sub end($a) { $a.end }

proto sub classify(|) { * }
multi sub classify( $test, *@items ) { Hash.^parameterize(Any,Any).new.classify-list( $test, @items ) }
#multi sub classify( $test, *@items, :$into! ) {   # problem in MMD
#    ( $into // $into.new).classify-list( $test, @items );
#}

proto sub categorize(|) { * }
multi sub categorize( $test, *@items ) { Hash.^parameterize(Any,Any).new.categorize-list( $test, @items ) }
#multi sub categorize( $test, *@items, :$into! ) {   # problem in MMD
#    ( $into // $into.new).categorize-list( $test, @items );
#}

proto sub uniq(|) { * }
multi sub uniq(*@values, |c) {
    DEPRECATED('unique', |<2014.12 2015.11>);
    @values.unique(|c)
}

proto sub unique(|) { * }
multi sub unique(*@values, |c) { @values.unique(|c) }

proto sub squish(|) { * }
multi sub squish(*@values, |c) { @values.squish(|c) }

proto sub sort(|) {*}
multi sub sort(*@values)      {
    nqp::istype(@values.AT-POS(0), Callable)
        ?? SEQ(my $cmp := @values.shift; @values.sort($cmp) )
        !! @values.sort;
}

proto sub item(|) is pure   { * }
multi sub item(\x)    { my $ = x }
multi sub item(*@a)   { my $ = nqp::p6parcel(nqp::p6argvmarray(), nqp::null()) }
multi sub item(Mu $a) { $a }

my $default= [];       # so that we can check missing parameters
sub RWPAIR(\k, \v) {   # internal fast pair creation
    my \p := nqp::create(Pair);
    nqp::bindattr(p, Enum, '$!key', k);
    nqp::bindattr(p, Enum, '$!value', v);
    p
}

sub OBJECT_HUH (\SELF) {
    my $huh := SELF.WHAT.perl;
    try { $huh ~= " {SELF.VAR.name}" };
    $huh;
}

sub SLICE_HUH ( \SELF, @nogo, Mu $d, %adv ) is hidden-from-backtrace {
    @nogo.unshift('delete')  # recover any :delete if necessary
      if @nogo && @nogo[0] ne 'delete' && %adv.EXISTS-KEY('delete');
    for <delete exists kv p k v> -> $valid { # check all valid params
        if nqp::existskey($d,nqp::unbox_s($valid)) {
            nqp::deletekey($d,nqp::unbox_s($valid));
            @nogo.push($valid);
        }
    }

    if nqp::elems($d) -> $elems {
        my @keys;
        my Mu $iter := nqp::iterator($d);
        @keys.push: nqp::p6box_s(nqp::iterkey_s(nqp::shift($iter))) while $iter;

        $elems > 1
          ?? fail "$elems unexpected named parameters (@keys.join(', ')) passed to {OBJECT_HUH(SELF)}"
          !! fail "Unexpected named parameter '@keys[0]' passed to {OBJECT_HUH(SELF)}";
    }

    else {
        fail "Unsupported combination of named parameters (@nogo.join(', ')) passed to {OBJECT_HUH(SELF)}";
    }
} #SLICE_HUH

sub DELETEKEY(Mu \d, str $key) {
    if nqp::existskey(d,$key) {
        my Mu $value := nqp::atkey(d,$key);
        nqp::deletekey(d,$key);
        $value;
    }
    else {
        Mu;
    }
} #DELETEKEY


sub dd (|) {
    my Mu $args := nqp::p6argvmarray();
    while $args {
        my $var  := nqp::shift($args);
        my $name := $var.VAR.?name;
        note $name ?? "$name = $var.perl()" !! $var.perl
    }
}
# vim: ft=perl6 expandtab sw=4
