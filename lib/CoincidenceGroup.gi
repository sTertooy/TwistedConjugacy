###############################################################################
##
## CoincidenceGroup( hom1, hom2, ... )
##
InstallGlobalFunction(
	CoincidenceGroup,
	function ( hom1, hom2, arg... )
		local G, Coin, homi;
		G := Range( hom1 );
		Coin := CoincidenceGroup2( hom1, hom2 );
		for homi in arg do
			Coin := CoincidenceGroup2(
				RestrictedHomomorphism( hom1, Coin, G ),
				RestrictedHomomorphism( homi, Coin, G )
			);
		od;
		return Coin;
	end
);


###############################################################################
##
## CoincidenceGroupOp( hom1, hom2 )
##
InstallMethod(
	CoincidenceGroup2,
	"for trivial range",
	[ IsGroupHomomorphism, IsGroupHomomorphism ],
	7,
	function ( hom1, hom2 )
		local G, H;
		G := Range( hom1 );
		H := Source( hom1 );
		if not IsTrivial( G ) then
			TryNextMethod();
		fi;
		return H;
	end
);

InstallMethod(
	CoincidenceGroup2,
	"for finite source",
	[ IsGroupHomomorphism, IsGroupHomomorphism ],
	6,
	function ( hom1, hom2 )
		local G, H, tc;
		G := Range( hom1 );
		H := Source( hom1 );
		if not IsFinite( H ) then
			TryNextMethod();
		fi;
		tc := TwistedConjugation( hom1, hom2 );
		return Stabilizer( H, One( G ), tc );
	end
);


###############################################################################
##
## FixedPointGroup( endo )
##
InstallMethod(
	FixedPointGroup,
	[ IsGroupHomomorphism and IsEndoGeneralMapping ],
	0,
	function ( endo )
		local G;
		G := Range( endo );
		return CoincidenceGroup( endo, IdentityMapping( G ) );
	end
);

RedispatchOnCondition(
	FixedPointGroup,
	true,
	[ IsGroupHomomorphism ],
	[ IsEndoGeneralMapping ],
	0
);
