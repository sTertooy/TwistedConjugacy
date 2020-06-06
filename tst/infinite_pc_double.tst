gap> START_TEST( "Testing Double Twisted Conjugacy for infinite pc groups" );

#
gap> G := ExamplesOfSomePcpGroups( 5 );;
gap> gens := GeneratorsOfGroup( G );;
gap> imgs1 := [ G.1*G.4^-1, G.3, G.2*G.3^2*G.4^2, G.4^-1  ];;
gap> phi := GroupHomomorphismByImages( G, G, gens, imgs1 );;
gap> imgs2 := [ G.1, G.2^2*G.3*G.4^2, G.2*G.3*G.4, G.4  ];;
gap> psi := GroupHomomorphismByImages( G, G, gens, imgs2 );;
gap> tc := TwistedConjugation( phi, psi );;
gap> IsTwistedConjugate( phi, G.2, G.3^2 );
false
gap> g := RepresentativeTwistedConjugation( phi, psi, G.2, G.2*G.3^2 );
g3^2
gap> tc( G.2, g ) = G.2*G.3^2;
true
gap> tcc := ReidemeisterClass( phi, psi, G.3 );;
gap> Representative( tcc );
g3
gap> Random( tcc ) in tcc;
true
gap> ActingDomain( tcc ) = G;
true
gap> TwistedConjugacyClasses( phi, psi );
[ id^G, g1*g2^G, g1^G, g2^G ]

#
gap> STOP_TEST( "infinite_pc_double.tst" );