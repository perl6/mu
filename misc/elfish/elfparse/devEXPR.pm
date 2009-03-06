package STD { #XXX
# Porting gimme5 EXPR to elf.
# Derived from <pugs>/src/perl6/STD.pm r25030 .
#my $LOOSEST; my %terminator; my $item_assignment_prec;
#
method EXPR ($preclvl)
{
#ELF
#    temp $CTX = self.callm if $*DEBUG +& DEBUG::trace_call;
#    if self.peek {
#        return self._AUTOLEXpeek('EXPR', $retree);
#    }
#   my $preclim = $preclvl ?? $preclvl.<prec> // $LOOSEST !! $LOOSEST; #ELFBUG
    my $preclim; if $preclvl { $preclim = $preclvl.<prec> }; #ELFFIX
    if not(defined($preclim)) { $preclim = $LOOSEST }; #ELFFIX
    my $inquote is context = 0;
    my $SIGIL is context<rw> = '';
    my $termstack = [];
    my $opstack = [];
    my $termish = 'termish';

#    push @opstack, { 'O' => item %terminator, 'sym' => '' };         # (just a sentinel value)#ELFBUG
    my $sentinel = {}; $sentinel<O> = %terminator; $sentinel<sym> = ''; #ELFFIX
    $opstack.push($sentinel); #ELFFIX

    my $here = self;
    my $S = $here.pos();
    self.deb("In EXPR, at $S") if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
    my $self_pos = self.pos;#ELF# self.pos for below

    my $reduce = sub {
        self.deb("entering reduce, termstack == ", +$termstack, " opstack == ", +$opstack) if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
        my $op = $opstack.pop;
        my $sym = $op<sym>;
#       given $op<O><assoc> // 'unary' {
        my $assoc = $op<O><assoc> || 'unary';
#            when 'chain' {
        if $assoc eq 'chain' {
                self.deb("reducing chain") if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
                my $chain = [];
                $chain.push($termstack.pop);
                $chain.push($op);
                while $opstack {
                    if $op<O><prec> ne $opstack[-1]<O><prec> {last;} #ELF#STDBUG last if (fixed in HEAD)
                    $chain.push($termstack.pop);
                    $chain.push($opstack.pop);
                }
                $chain.push($termstack.pop);
                $chain = $chain.reverse if $chain.elems > 1;
#               my $startpos = $chain[0].pos;
                my $startpos = $chain[0].match_to;
#               my $nop = $op.cursor_fresh();
                my $nop = $.new_Match;
                $nop<chain> = $chain.clone;
                $nop<_arity> = 'CHAIN';
                $termstack.push($nop._REDUCE($startpos, 'EXPR'));
            }
#            when 'list' {
        elsif $assoc eq 'list' {
                self.deb("reducing list") if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
                my $list = [];
                my $delims = [$op];
                $list.push($termstack.pop);
                while $opstack {
                    self.deb($sym ~ " vs " ~ $opstack[-1]<sym>) if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
                    if $sym ne $opstack[-1]<sym> {last;}  #ELF#STDBUG last if
                    if $termstack and defined $termstack[0] {
                        $list.push($termstack.pop);
                    }
                    else {
                        self.worry("Missing term in " ~ $sym ~ " list");
                    }
                    $delims.push($opstack.pop);
                }
                if $termstack and defined $termstack[0] {
                    $list.push($termstack.pop);
                }
                elsif $sym ne ',' {
                    self.worry("Missing final term in '" ~ $sym ~ "' list");
                }
                $list = $list.reverse if $list.elems > 1;
#               my $startpos = $list[0].pos;
                my $startpos = $list[0].match_to;
                $delims = $delims.reverse if $delims.elems > 1;
#               my $nop = $op.cursor_fresh();
                my $nop = $.new_Match;
                $nop<sym> = $sym;
                $nop<O> = $op<O>;
                $nop<list> = $list.clone;
                $nop<delims> = $delims.clone;
                $nop<_arity> = 'LIST';
                $termstack.push($nop._REDUCE($startpos, 'EXPR'));
            }
#            when 'unary' {
        elsif $assoc eq 'unary' {
                self.deb("reducing") if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
                #my $list = []; #ELF# unused - removed r25717.
                self.deb("Termstack size: ", +$termstack) if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;

#                self.deb($op.dump) if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
                $op<arg> = ($termstack.pop);
                if ($op<arg>.match_from < $op.match_from) {
                    $op.match_from = $op<arg>.match_from;
                }
                if ($op<arg>.match_to > $op.match_to) {
                    $op.match_to = $op<arg>.match_to;
                }
                $op<_arity> = 'UNARY';
                $termstack.push($op._REDUCE($op.match_from, 'EXPR'));
            }
#            default {
        else {
                self.deb("reducing") if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
                #my $list = []; #ELF# unused - removed r25717.
                self.deb("Termstack size: ", +$termstack) if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;

                $op<right> = ($termstack.pop);
                $op<left> = ($termstack.pop);
                $op.match_from = $op<left>.match_from;
                $op.match_to = $op<right>.match_to;
                $op<_arity> = 'BINARY';
#                self.deb($op.dump) if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
                $termstack.push($op._REDUCE($op.match_from, 'EXPR'));
            }
    };

    while 1 {
        self.deb("In loop, at ", $here.pos) if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
        my $oldpos = $here.pos;
#       $here = $here.cursor_fresh();
        $SIGIL = ''; if $opstack[-1]<O><prec> gt $item_assignment_prec { $SIGIL = '@' }
#       my @t = $here.$termish;
        my $M = $here.advance_by_rule($termish);#

#        if not @t or not $here = @t[0] or ($here.pos == $oldpos and $termish eq 'termish') {
        if not($M) or ($M.match_to == $oldpos and $termish eq 'termish') {
            return undef; #ELF# failed match
            # $here.panic("Failed to parse a required term");
        }
        $termish = 'termish';

        # interleave prefix and postfix, pretend they're infixish
#       my $M = $here;

        # note that we push loose stuff onto opstack before tight stuff
#       my @pre;
#       my $tmp;
#       @pre = @$tmp if $tmp = ( $M<PRE> :delete );
#       my @post;
#       @post = @$tmp.reverse() if $tmp = ( $M<POST> :delete );
        my $pre = [];
        my $post = [];
        if $M<PRE> { $pre = $M<PRE>.clone; $M.match_hash.delete('PRE'); }
        if $M<POST> { $post = $M<POST>.reverse(); $M.match_hash.delete('POST'); }
        while $pre and $post {
            my $postO = $post[0]<O>;
            my $preO = $pre[0]<O>;
            if $postO<prec> lt $preO<prec> {
                $opstack.push($post.shift);
            }
            elsif $postO<prec> gt $preO<prec> {
                $opstack.push($pre.shift);
            }
            elsif $postO<uassoc> eq 'left' {
                $opstack.push($post.shift);
            }
            elsif $postO<uassoc> eq 'right' {
                $opstack.push($pre.shift);
            }
            else {
                $here.panic('"' ~ $pre[0]<sym> ~ '" and "' ~ $post[0]<sym> ~ '" are not associative');
            }
        }
        $opstack.push($pre.flatten,$post.flatten);

#       @termstack.push($here);
        $termstack.push($M);#
        self.deb("after push: " ~ (+$termstack)) if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;

        my $last_TERM = undef;
        while 2 {     # while we see adverbs
            $oldpos = $here.pos;
#           if (@+MEMOS[$oldpos]<endstmt> // 0) == 2 { $last_TERM = 1; last; }
            my $memos = @+MEMOS; $memos = [] if not defined $memos; #ELF# @+MEMOS got smashed elsewhere.
            my $memo = $memos[$oldpos];
            if $memo && $memo<endstmt> && $memo<endstmt> == 2 { $last_TERM = 1; last; }
#           $here = $here.cursor_fresh.ws;
            $here.advance_by_rule("ws");#
#           my @infix = $here.cursor_fresh.infixish();
            my $infix = $here.advance_by_rule("infixish");#
#           last TERM unless @infix;
            if not $infix { $last_TERM = 1; last; } #
#           my $infix = @infix[0];
#           last TERM unless $infix.pos > $oldpos;
            if not $infix.match_to > $oldpos { $last_TERM = 1; last; } #
            
            if not $infix<sym> {
#                die $infix.dump if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
            }

            my $inO = $infix<O>;
#           my Str $inprec = $inO<prec>;
            my $inprec = $inO<prec>;
            if not defined $inprec {
                self.deb("No prec given in infix!") if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
#                die $infix.dump if $*DEBUG ;#ELFSPEED# +& $DEBUG::EXPR;
                $inprec = %terminator<prec>;
            }

#           last TERM unless $inprec gt $preclim;
            if not $inprec gt $preclim { $last_TERM = 1; last; }

#           $here = $infix.cursor_fresh.ws();
            $here.advance_by_rule("ws");

            # substitute precedence for listops
            $inO<prec> = $inO<sub> if $inO<sub>;

            # Does new infix (or terminator) force any reductions?
            while $opstack[-1]<O><prec> gt $inprec {
                $reduce.();
            }

            # Not much point in reducing the sentinels...
            if $inprec lt $LOOSEST {last;} #ELF#STDBUG last if

            if $infix<fake> {
#             my $adverbs = @termstack[*-1]<ADV> ||= [];
              my $adverbs = $termstack[-1]<ADV>;
              if not defined $adverbs { $termstack[-1]<ADV> = []; $adverbs = $termstack[-1]<ADV>; }
                $adverbs.push($infix<colonpair>);
                next;  # not really an infix, so keep trying
            }

            # Equal precedence, so use associativity to decide.
            if $opstack[-1]<O><prec> eq $inprec {
#                given $inO<assoc> {
              my $assoc = $inO<assoc>;
#                    when 'non'   { $here.panic('"' ~ $infix.text ~ '" is not associative') }
              if $assoc eq 'non' { $here.panic('"' ~ $infix.text ~ '" is not associative') }
#                    when 'left'  { reduce() }   # reduce immediately
              elsif $assoc eq 'left' { $reduce.() }
#                    when 'right' { }            # just shift
              elsif $assoc eq 'right' { }
#                    when 'chain' { }            # just shift
              elsif $assoc eq 'chain' { }
#                    when 'unary' { }            # just shift
              elsif $assoc eq 'unary' { }
#                    when 'list'  {              # if op differs reduce else shift
              elsif $assoc eq 'list' {
#                       reduce() if $infix<sym> !eqv @opstack[*-1]<sym>;
                        $reduce.() if not($infix<sym> eq $opstack[-1]<sym>);
                    }
#                    default { $here.panic('Unknown associativity "' ~ $_ ~ '" for "' ~ $infix<sym> ~ '"') }
              else { $here.panic('Unknown associativity "' ~ $assoc ~ '" for "' ~ $infix<sym> ~ '"') }
            }

            $termish = $inO<nextterm> if $inO<nextterm>;
            $opstack.push($infix);              # The Shift
            last;
        } ;#ELF# end of inner loop {}
        if $last_TERM {last;}#
    } ;#ELF# end of outer TERM: loop {}
    $reduce.() while $opstack.elems > 1;
    if $termstack {
        #@termstack.elems == 1 or $here.panic("Internal operator parser error, termstack == " ~ (+@termstack));
        if $termstack.elems != 1 { $here.panic("Internal operator parser error, termstack == " ~ (+$termstack)); }
        $termstack[0].match_from = $self_pos;
        $termstack[0].match_to = $here.pos;
    }
#   self._MATCHIFYr($S, "EXPR", @termstack);
    if $termstack {
      $termstack[0]._REDUCE($S, "EXPR");
    } else {
      return undef; #ELF# failed match
    }    
}


1;}; #XXX
