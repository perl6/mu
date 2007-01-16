use v6-alpha;

class KindaPerl6::Traverse {

    sub visit ( $visitor, $node, $node_name, $data ) {
        # say "visit " ~ $node_name;
        
        if $node.isa('Array') {
            my $result := [ ];
            my $i := 0;
            for @($node) -> $subitem {
                $result[ $i ] := $subitem.emit( $visitor );
                $i := $i + 1;
            };
            return $result;
        };

        if $node.isa('Hash') {
            my $result := { };
            for keys %($node) -> $subitem {
                $result{ $subitem } := ($node{$subitem}).emit( $visitor );
            };
            return $result;
        };

        if $node.isa('Str') {
            return $node;
        };

        my $result := $visitor.visit( $node, $node_name, $data );
        if ( $result ) {
            return $result;
        };
        
        my $result := { };
        for keys %($data) -> $item {            
            $result{$item} := visit( 
                $visitor, 
                $data{$item}
            );
        };
        return $node_name.new(%$result);
        
    };

}

class CompUnit {
    has $.name;
    has %.attributes;
    has %.methods;
    has @.body;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'CompUnit',
            { 
                name    => $.name,
                attributes => %.attributes,
                methods => %.methods,
                body    => @.body,
            }
        );
    }
}

class Val::Int {
    has $.int;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Int',
            { 
                int    => $.int,
            }
        );
    }
}

class Val::Bit {
    has $.bit;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Bit',
            { 
                bit    => $.bit,
            }
        );
    }
}

class Val::Num {
    has $.num;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Num',
            { 
                num    => $.num,
            }
        );
    }
}

class Val::Buf {
    has $.buf;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Buf',
            { 
                buf    => $.buf,
            }
        );
    }
}

class Val::Undef {
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Undef',
            { 
            }
        );
    }
}

class Val::Object {
    has $.class;
    has %.fields;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Val::Object',
            { 
                class  => $.class,
                fields => %.fields,
            }
        );
    }
}

class Lit::Seq {
    has @.seq;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lit::Seq',
            { 
                seq  => @.seq,
            }
        );
    }
}

class Lit::Array {
    has @.array;    
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lit::Array',
            { 
                array  => @.array,
            }
        );
    }
}

class Lit::Hash {
    has @.hash;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lit::Hash',
            { 
                hash  => @.hash,
            }
        );
    }
}

class Lit::Code {
    # XXX
    1;
}

class Lit::Object {
    has $.class;
    has @.fields;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lit::Object',
            { 
                class  => $.class,
                fields => %.fields,
            }
        );
    }
}

class Index {
    has $.obj;
    has $.index;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Index',
            { 
                obj   => $.obj,
                index => $.index,
            }
        );
    }
}

class Lookup {
    has $.obj;
    has $.index;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Lookup',
            { 
                obj   => $.obj,
                index => $.index,
            }
        );
    }
}

class Var {
    has $.sigil;
    has $.twigil;
    has $.name;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Var',
            { 
                sigil   => $.sigil,
                twigil  => $.twigil,
                name    => $.name,
            }
        );
    }
}

class Bind {
    has $.parameters;
    has $.arguments;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Bind',
            { 
                parameters   => $.parameters,
                arguments    => $.arguments,
            }
        );
    }
}

class Assign {
    has $.parameters;
    has $.arguments;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Assign',
            { 
                parameters   => $.parameters,
                arguments    => $.arguments,
            }
        );
    }
}

class Proto {
    has $.name;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Proto',
            { 
                name   => $.name,
            }
        );
    }
}

class Call {
    has $.invocant;
    has $.hyper;
    has $.method;
    has @.arguments;
    #has $.hyper;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Call',
            { 
                invocant   => $.invocant,
                hyper      => $.hyper,
                method     => $.method,
                arguments  => @.arguments,
            }
        );
    }
}

class Apply {
    has $.code;
    has @.arguments;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Apply',
            { 
                code       => $.code,
                arguments  => @.arguments,
            }
        );
    }
}

class Return {
    has $.result;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Return',
            { 
                result    => $.result,
            }
        );
    }
}

class If {
    has $.cond;
    has @.body;
    has @.otherwise;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'If',
            { 
                cond       => $.cond,
                body       => @.body,
                otherwise  => @.otherwise,
            }
        );
    }
}

class For {
    has $.cond;
    has @.body;
    has @.topic;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'For',
            { 
                cond       => $.cond,
                body       => @.body,
                topic      => @.topic,
            }
        );
    }
}

class Decl {
    has $.decl;
    has $.type;
    has $.var;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Decl',
            { 
                decl       => $.decl,
                type       => @.type,
                var        => @.var,
            }
        );
    }
}

class Sig {
    has $.invocant;
    has $.positional;
    has $.named;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Sig',
            { 
                invocant   => $.invocant,
                positional => @.positional,
                named      => @.named,
            }
        );
    }
}

class Method {
    has $.name;
    has $.sig;
    has @.block;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Method',
            { 
                name    => $.name,
                sig     => $.sig,
                block   => @.block,
            }
        );
    }
}

class Sub {
    has $.name;
    has $.sig;
    has @.block;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Sub',
            { 
                name    => $.name,
                sig     => $.sig,
                block   => @.block,
            }
        );
    }
}

class Do {
    has @.block;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Do',
            { 
                block   => @.block,
            }
        );
    }
}

class Use {
    has $.mod;
    method emit( $visitor ) {
        KindaPerl6::Traverse::visit( 
            $visitor, 
            self,
            'Use',
            { 
                mod    => $.mod,
            }
        );
    }
}

=begin

=head1 NAME 

MiniPerl6::Traverse - Tree traverser for MiniPerl6 AST

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 homepage at L<http://dev.perl.org/perl6>.

The Pugs homepage at L<http://pugscode.org/>.

=head1 COPYRIGHT

Copyright 2006 by Flavio Soibelmann Glock, Audrey Tang and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end
