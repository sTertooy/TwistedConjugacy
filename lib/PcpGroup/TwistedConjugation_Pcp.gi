###############################################################################
##
## RepTwistConjToIdByFiniteCoin( hom1, hom2, g, M )
##
RepTwistConjToIdByFiniteCoin@ := function ( hom1, hom2, g, M )
	local N, p, q, hom1HN, hom2HN, qh1, Coin, h1, tc, m, hom1N, hom2N, qh2, h2,
		n;
	N := IntersectionPreImage@( hom1, hom2, M );
	p := NaturalHomomorphismByNormalSubgroupNC( Range( hom1 ), M );
	q := NaturalHomomorphismByNormalSubgroupNC( Source( hom1 ), N );
	hom1HN := InducedHomomorphism( q, p, hom1 );
	hom2HN := InducedHomomorphism( q, p, hom2 );
	qh1 := RepTwistConjToId( hom1HN, hom2HN, g^p );
	if qh1 = fail then
		return fail;
	fi;
	Coin := CoincidenceGroup( hom1HN, hom2HN );
	if not IsFinite( Coin ) then
		TryNextMethod();
	fi;
	h1 := PreImagesRepresentative( q, qh1 );
	tc := TwistedConjugation( hom1, hom2 );
	m := tc( g, h1 );
	hom1N := RestrictedHomomorphism( hom1, N, M );
	hom2N := RestrictedHomomorphism( hom2, N, M );
	for qh2 in Coin do
		h2 := PreImagesRepresentative( q, qh2 );
		n := RepTwistConjToId( hom1N, hom2N, tc( m, h2 ) );
		if n <> fail then
			return h1*h2*n;
		fi;
	od;
	return fail;
end;


###############################################################################
##
## RepTwistConjToIdByCentre( hom1, hom2, g )
##
RepTwistConjToIdByCentre@ := function ( hom1, hom2, g ) 
	local G, M, N, p, q, hom1HN, hom2HN, qh1, h1, tc, m, Coin, delta, h2;
	G := Range( hom1 );
	M := Centre( G );
	N := IntersectionPreImage@( hom1, hom2, M );
	p := NaturalHomomorphismByNormalSubgroupNC( G, M );
	q := NaturalHomomorphismByNormalSubgroupNC( Source ( hom1 ), N );
	hom1HN := InducedHomomorphism( q, p, hom1 );
	hom2HN := InducedHomomorphism( q, p, hom2 );
	qh1 := RepTwistConjToId( hom1HN, hom2HN, g^p );
	if qh1 = fail then
		return fail;
	fi;
	h1 := PreImagesRepresentative( q, qh1 );
	tc := TwistedConjugation( hom1, hom2 );
	m := tc( g, h1 );
	Coin := PreImage( q, CoincidenceGroup( hom1HN, hom2HN ) );
	delta := DifferenceGroupHomomorphisms@ (
		RestrictedHomomorphism( hom1, Coin, G ),
		RestrictedHomomorphism( hom2, Coin, G )
	);
	if not m in Image( delta ) then
		return fail;
	fi;
	h2 := PreImagesRepresentative( delta, m );
	return h1 * h2 * RepTwistConjToId(
		RestrictedHomomorphism( hom1, N, M ),
		RestrictedHomomorphism( hom2, N, M ),
		tc( m, h2 )
	);
end;


###############################################################################
##
## RepTwistConjToId( hom1, hom2, g )
##
InstallMethod(
	RepTwistConjToId,
	"for infinite polycyclic source and finite range",
	[ IsGroupHomomorphism, IsGroupHomomorphism,
	  IsMultiplicativeElementWithInverse ],
	4,
	function ( hom1, hom2, g )
		local G;
		G := Range( hom1 );
		if (
			not IsPcpGroup( Source( hom1 ) ) or
			not IsFinite( G )
		) then
			TryNextMethod();
		fi;
		return RepTwistConjToIdByFiniteCoin@(
			hom1, hom2,
			g,
			TrivialSubgroup( G )
		);
	end
);

InstallMethod(
	RepTwistConjToId,
	"for infinite polycyclic source and infinite abelian range", 
	[ IsGroupHomomorphism, IsGroupHomomorphism,
	  IsMultiplicativeElementWithInverse ],
	3,
	function ( hom1, hom2, g )
		local G, diff;
		G := Range( hom1 );
		if (
			not IsPcpGroup( Source( hom1 ) ) or
			not IsPcpGroup( G ) or
			not IsAbelian( G )
		) then
			TryNextMethod();
		fi;
		diff := DifferenceGroupHomomorphisms@( hom1, hom2 );
		if not g in Image( diff ) then
			return fail;
		fi;
		return PreImagesRepresentative( diff, g );
	end
);

InstallMethod(
	RepTwistConjToId,
	"for infinite polycyclic source and infinite nilpotent range",
	[ IsGroupHomomorphism, IsGroupHomomorphism,
	  IsMultiplicativeElementWithInverse ],
	2,
	function ( hom1, hom2, g )
		local G;
		G := Range( hom1 );
		if (
			not IsPcpGroup( Source( hom1 ) ) or
			not IsPcpGroup( G ) or
			not IsNilpotent( G )
		) then
			TryNextMethod();
		fi;
		return RepTwistConjToIdByCentre@( hom1, hom2, g );
	end
);

InstallMethod(
	RepTwistConjToId,
	"for infinite polycyclic source and infinite nilpotent-by-finite range",
	[ IsGroupHomomorphism, IsGroupHomomorphism,
	  IsMultiplicativeElementWithInverse ],
	1,
	function ( hom1, hom2, g )
		local G;
		G := Range( hom1 );
		if (
			not IsPcpGroup( Source( hom1 ) ) or
			not IsPcpGroup( G ) or
			not IsNilpotentByFinite( G )
		) then
			TryNextMethod();
		fi;
		return RepTwistConjToIdByFiniteCoin@( 
			hom1, hom2,
			g,
			FittingSubgroup( G )
		);
	end
);

InstallMethod(
	RepTwistConjToId,
	"for infinite polycyclic source and range",
	[ IsGroupHomomorphism, IsGroupHomomorphism,
	  IsMultiplicativeElementWithInverse ],
	0,
	function ( hom1, hom2, g )
		local G;
		G := Range( hom1 );
		if (
			not IsPcpGroup( Source( hom1 ) ) or
			not IsPcpGroup( G )
		) then
			TryNextMethod();
		fi;
		return RepTwistConjToIdByFiniteCoin@(
			hom1, hom2,
			g,
			DerivedSubgroup( G )
		);
	end
);